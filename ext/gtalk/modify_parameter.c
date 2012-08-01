/* Copyright (c) 2000-2006                             */
/*   Yamashita Lab.                                    */
/*   (Ritsumeikan University)                          */
/*   Takao Kobayashi, Takashi Masuko, Masatsune Tamura */
/*   (Tokyo Institute of Technology)                   */
/*   Keiichi Tokuda, Takayoshi Yoshimura, Heiga Zen    */
/*   (Nagoya Institute of Technology)                  */
/*   All rights reserved                               */
/* $Id: modify_parameter.c,v 1.20 2007/07/12 06:10:45 sako Exp $                                                */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "synthesis.h"
#include "tag.h"
#include "defaults.h"
#include "confpara.h"
#include "misc.h"
#include "tree.h"
#include "hmmsynth.h"
#include "model.h"
#include "slot.h"

int TmpMsg(char *,...);
int ErrMsg(char *,...);
int speakerID(char *);
void restart(int);

void mod_dur_morph( MORPH* morph, int attrID, double rate )
{
	PHONEME *phoneme, *last, *head;
	Model *m,*mh;
	int state;
	double rho,x,diffdur,data;

	if( morph->nmora == 0 )  return;	/* 「」など。*/

	if( rate < 0.2 )  rate = 0.2;

	head = morph->mrhead->phead;
	last = morph->mrtail->ptail;
	phoneme = head;

	mh = mhead;
	while( mh->phoneme != phoneme)mh = mh->next;
	m = mh;
	rho = 0;
	x = 0;

	while(1){
		switch(attrID) {
			case TA_SPEED:
			   rho += m->phoneme->time * rate / FRAME_RATE;
			   for(state=2;state <= nstate+1; state++){
			      rho -= m->durmean[state];
			      x += m->durvariance[state];
                           }
			   break;
                }
		if(phoneme == last)break;
		phoneme = phoneme->next;
		m = m->next;
	}

        rho /= x;
	phoneme = head;
	m = mh; 
	diffdur = 0;

	while(1) {
		switch( attrID )  {
			case TA_SPEED:
				m->totalduration = 0;
				for(state=2;state <= nstate +1; state++) {
				        data = m->durmean[state] + rho * m->durvariance[state];
					m->duration[state] = (int)(data + diffdur + 0.5);
					if( m->duration[state] < 0) m->duration[state] = 0;
					m->totalduration += m->duration[state];
					diffdur += data - (float) m->duration[state];
                                }
				phoneme->time = m->totalduration * FRAME_RATE;
				break;
			case TA_ABSSPEED:
			case TA_MORASEC:
				break;
		}
		if(phoneme == last)break;
		phoneme = phoneme->next;
		m = m->next;
	}
}

void mod_dur_silence( PHONEME *ph, int attrID, double dur )
{
	Model *m,*mh;
	int state;
	double rho,x,diffdur,data;

	if( dur < 0 )  dur = 0.0;

	mh = mhead;
	while( mh->phoneme != ph)mh = mh->next;
	m = mh;
	rho = 0;
	x = 0;
	switch(attrID) {
		case TA_MSEC:
			rho = dur / FRAME_RATE;
			for(state=2;state <= nstate+1; state++){
			   rho -= m->durmean[state];
			   if( rho < 0.0 )  rho = 0.0;
			   x += m->durvariance[state];
                        }
                        rho /= x;
	                m = mh; 
	                diffdur = 0;
			m->totalduration = 0;
			for(state=2;state <= nstate +1; state++) {
			        data = m->durmean[state] + rho * m->durvariance[state];
				m->duration[state] = (int)(data + diffdur + 0.5);
				if( m->duration[state] < 0) m->duration[state] = 0;
				m->totalduration += m->duration[state];
				diffdur += data - (float) m->duration[state];
			}
			ph->time = m->totalduration * FRAME_RATE;
			break;
	}	
}

void modify_duration()
{
	MORPH *morph;
	int i, len;
	double	rate, dur;
	PHONEME *p;

	/* 一番外側のタグから順に処理するよう、逆順に実行する */
	for( i=n_tag-1; i>=0; --i )  {
	  if( tag[i]->id == T_RATE )  {
		morph = mphead;
		len = 0;	/* 累積文字数 */
		sscanf( tag[i]->options[0].val, "%lf", &rate );
		while( morph )  {
			if( tag[i]->start <= len && len+(morph->nbyte) <= tag[i]->end )  {
				mod_dur_morph( morph, tag[i]->options[0].attrID, rate );
			}
			len += morph->nbyte;
			morph = morph->next;
		}
	  } else if( tag[i]->id == T_SILENCE )  {
		if( tag[i]->n_op > 0 )  {
			sscanf( tag[i]->options[0].val, "%lf", &dur );
			if( tag[i]->start_morph->mrhead == NULL ) {
				p = tag[i]->start_morph->next->mrhead->phead;
			} else {
				p = tag[i]->start_morph->mrhead->phead;
			}
			mod_dur_silence( p, tag[i]->options[0].attrID, dur );
		}
	  }
	}
	if( phhead->parent->silence != NON )  phhead->time = SILENCE_LENGTH;
	if( phtail->parent->silence != NON )  phtail->time = SILENCE_LENGTH;
}

void make_cumul_time()
{
	PHONEME *phoneme;
	double	ctime;
	int n;

	ctime = 0.0;
	n = 0;
	for( phoneme = phhead; phoneme; phoneme = phoneme->next )  {
		phoneme->ctime = ctime;
		ctime += phoneme->time;
		++n;
	}
	slot_n_phonemes = n;
	slot_total_dur = (int)ctime;
}

void mod_f0_morph( MORPH* m1, MORPH* m2, int attrID, double rate )
{
	double	time1, time2, lograte;
	int i, i1, i2, shift_sil;
	MORA *mora1, *mora2;

	if( m1->mrhead == NULL )  {		/* 「」など。*/
		mora1 = m1->next->mrhead;
	} else {
		mora1 = m1->mrhead;
	}
	if( m2->mrtail == NULL )  {		/* 「」など。*/
		mora2 = m2->prev->mrtail;
	} else {
		mora2 = m2->mrtail;
	}
	time1 = mora1->phead->ctime;
	time2 = mora2->ptail->ctime + mora2->ptail->time;

	shift_sil = mhead->totalduration - (SILENCE_LENGTH/FRAME_RATE);
	i1 = (int)( time1 / (double)(FRAME_RATE) ) + shift_sil;
	i2 = (int)( time2 / (double)(FRAME_RATE) ) + shift_sil;

	switch( attrID )  {
		case TA_LEVEL:
			if( rate < 0.1 )  rate = 0.1;
			lograte = log( rate );
			for( i=i1; i<=i2; i++ )  {
				if( f0.data[i] <= 0.000001 )  continue;
				f0.data[i] += lograte;
			}
			break;
		case TA_ABSLEVEL:
			break;
		case TA_RANGE:
		{
			double ave;
			int n;
			ave = 0.0;  n = 0;
			for( i=0; i<=totalframe; ++i )  {
				if( f0.data[i] <= 0.000001 )  continue;
				ave += f0.data[i];  ++n;
			}
			ave /= (double)n;
			if( rate < 0.0 )  rate = 0.0;
			for( i=i1; i<=i2; i++ )  {
				if( f0.data[i] <= 0.000001 )  continue;
				f0.data[i] += ( f0.data[i]-ave ) * rate;
			}
		}
	}
}

void modify_f0()
{
	MORPH *morph, *m1, *m2=NULL;
	int i, len;
	double	rate;

	/* 一番外側のタグから順に処理するよう、逆順に実行する */
	for( i=n_tag-1; i>=0; --i )  {
		if( tag[i]->id != T_PITCH )  continue;

		morph = mphead;
		len = 0;	/* 累積文字数 */
		sscanf( tag[i]->options[0].val, "%lf", &rate );
		m1 = NULL;
		while( morph )  {
			if( m1 == NULL && tag[i]->start <= len )  m1 = morph;
			if( len+(morph->nbyte) <= tag[i]->end )  m2 = morph;
			len += morph->nbyte;
			morph = morph->next;
		}
		mod_f0_morph( m1, m2, tag[i]->options[0].attrID, rate );
	}
}

void mod_power_morph( MORPH* m1, MORPH* m2, int attrID, double rate )
{
	double	time1, time2, lograte;
	int i, i1, i2, shift_sil;
	MORA *mora1, *mora2;
	
	if( m1->mrhead == NULL )  {		/* 「」など。*/
		mora1 = m1->next->mrhead;
	} else {
		mora1 = m1->mrhead;
	}
	if( m2->mrtail == NULL )  {		/* 「」など。*/
		mora2 = m2->prev->mrtail;
	} else {
		mora2 = m2->mrtail;
	}
	time1 = mora1->phead->ctime;
	time2 = mora2->ptail->ctime + mora2->ptail->time;

	shift_sil = mhead->totalduration - (SILENCE_LENGTH/FRAME_RATE);
	i1 = (int)( time1 / (double)(FRAME_RATE) ) + shift_sil;
	i2 = (int)( time2 / (double)(FRAME_RATE) ) + shift_sil;

	if( rate < 0.01 )  rate = 0.01;

	switch( attrID )  {
		case TA_LEVEL:
			lograte = log( rate );
			for( i=i1; i<=i2; i++ )  {
				power.data[i] += lograte;
				if( power.data[i] < 0.0 )  power.data[i] = 0.0;
			}
			break;
	}
}

void modify_power()
{
	MORPH *morph, *m1, *m2=NULL;
	int i, len;
	double	rate;

	/* 一番外側のタグから順に処理するよう、逆順に実行する */
	for( i=n_tag-1; i>=0; --i )  {
		if( tag[i]->id != T_VOLUME )  continue;

		morph = mphead;
		len = 0;	/* 累積文字数 */
		sscanf( tag[i]->options[0].val, "%lf", &rate );
		m1 = NULL;
		while( morph )  {
			if( m1 == NULL && tag[i]->start <= len )  m1 = morph;
			if( len+(morph->nbyte) <= tag[i]->end )  m2 = morph;
			len += morph->nbyte;
			morph = morph->next;
		}
		mod_power_morph( m1, m2, tag[i]->options[0].attrID, rate );
	}
}

/*
void refresh_speaker()
{
	int i;

	for( i=0; i<n_speaker; ++i )  {
		if( speaker[i].alpha_saved >= 0 )  {
			speaker[i].alpha = speaker[i].alpha_saved;
			speaker[i].alpha_saved = -1.0;
		}
	}
}
*/

void mod_voice_morph( MORPH* morph, int attrID, char* val )
{
	PHONEME *phoneme, *last;
	int s;
	double	a;

	if( morph->mrhead == NULL )  {	/* 「」など。*/
		phoneme = morph->next->mrhead->phead;
	} else {
		phoneme = morph->mrhead->phead;
	}
	if( morph->mrtail == NULL )  {	/* 「」など。*/
		last = morph->prev->mrtail->ptail;
	} else {
		last = morph->mrtail->ptail;
	}

	while(1){
		switch(attrID) {
		case TA_OPTIONAL:
			s = speakerID( val );
			if( s >= 0 )  phoneme->sid = s;
			break;
		case TA_REQUIRED:
			break;
		case TA_ALPHA:
			a = atof( val );
			if( a >= 0.0 )  {
/*
				s = phoneme->sid;
				if( speaker[s].alpha_saved < 0 )  {
					speaker[s].alpha_saved = speaker[s].alpha;
				}
				speaker[s].alpha = a;
*/
				phoneme->alpha = a;
			}
			break;
		}
		if(phoneme == last)break;
		phoneme = phoneme->next;
	}
}

void modify_voice()
{
	MORPH *morph;
	int i, len, j;
	char *val_speaker, *val_alpha;

	/* 一番外側のタグから順に処理するよう、逆順に実行する */
	for( i=n_tag-1; i>=0; --i )  {
		if( tag[i]->id != T_VOICE )  continue;

		val_speaker = val_alpha = NULL;
		for( j=0; j<tag[i]->n_op; ++j )  {
			switch( tag[i]->options[j].attrID ) {
			case TA_OPTIONAL:
				val_speaker = tag[i]->options[j].val;
				break;
			case TA_REQUIRED:
				break;
			case TA_ALPHA:
				val_alpha = tag[i]->options[j].val;
				break;
			}
		}
		
		len = 0;	/* 累積文字数 */
		for( morph = mphead; morph; morph = morph->next )  {
			if( tag[i]->start <= len && len+(morph->nbyte) <= tag[i]->end )  {
				/* αの変更より、話者の変更を先に。 */
				if( val_speaker )  {
					mod_voice_morph( morph, TA_OPTIONAL, val_speaker );
				}
				if( val_alpha )  {
					mod_voice_morph( morph, TA_ALPHA, val_alpha );
				}
			}
			len += morph->nbyte;
		}
	}
}

/* prosBufの音素時間長にあわせて状態継続長を決定する */
void update_duration(){
	Model *m;
	int state, p_index;
	double rho,x,diffdur,data;

	m = mhead;
	p_index = 0;

	while(1){
	  rho = 0;
	  x = 0;
	  /* 音素時間長をチェック(同じなら修正なし) */
	  if( m->phoneme->time != prosBuf.ph_dur[p_index]){ 
	    rho = prosBuf.ph_dur[p_index] / FRAME_RATE;

	    for(state=2;state <= nstate+1; state++){
	      rho -= m->durmean[state];
	      x += m->durvariance[state];
	    }
	    rho /= x;
	    diffdur = 0;
	    m->totalduration = 0; /* 0にもどす */
	    for(state=2;state <= nstate +1; state++) {
	      data = m->durmean[state] + rho * m->durvariance[state];
	      m->duration[state] = (int)(data + diffdur + 0.5);
	      if( m->duration[state] < 0) m->duration[state] = 0;
	      m->totalduration += m->duration[state];
	      diffdur += data - (float) m->duration[state];
	    }
	    m->phoneme->time = m->totalduration * FRAME_RATE;
	  }

	  if( m == mtail) break;	  /* 最後まで繰り返す */

	  m = m->next;
	  p_index +=1; 
	}
}	
