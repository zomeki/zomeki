/* Copyright (c) 2000-2006                  */
/*   Yamashita Lab., Ritsumeikan University */
/*   All rights reserved                    */
/*                                          */
/* $Id: make_phoneme.c,v 1.15 2006/10/19 03:27:08 sako Exp $                                     */

#include	<stdio.h>
#include	<stdlib.h>
#include	<string.h>
#include	"synthesis.h"
#include	"pronunciation.h"
#include	"confpara.h"

int TmpMsg(char *,...);
int LogMsg(char *,...);
int ErrMsg(char *,...);
void restart(int);
void print_mora();

static char **phonemeList;
static int n_phoneme;

#define is_unvoice(p) (( (p)==ph_k  || (p)==ph_s  || (p)==ph_sh || \
                         (p)==ph_t  || (p)==ph_ch || (p)==ph_ts || \
                         (p)==ph_h  || (p)==ph_f  || (p)==ph_p  || \
                         (p)==ph_ky || (p)==ph_hy || (p)==ph_py ))

#define is_voice(p) (( (p)==a  || (p)==i  || (p)==u || \
                       (p)==e  || (p)==o ))

static char *ph_i  = NULL, *ph_u  = NULL;
static char *ph_I  = NULL, *ph_U  = NULL;
static char *ph_k  = NULL, *ph_s  = NULL, *ph_sh = NULL;
static char *ph_t  = NULL, *ph_ch = NULL, *ph_ts = NULL;
static char *ph_h  = NULL, *ph_f  = NULL, *ph_p  = NULL;
static char *ph_ky = NULL, *ph_hy = NULL, *ph_py = NULL;
static char *ph_sil = NULL;

char *get_phoneme( char *phm )
{
	int i;

	for( i=0; i<n_phoneme; ++i )  {
		if( strcmp(phm,phonemeList[i])==0 )  {
			return phonemeList[i];
		}
	}
	ErrMsg( "* Unknown phoneme ... '%s'\n", phm );
	restart(1);
	return NULL;
}

void read_phonemes( char *pfile )
{
	FILE *fp;
	char line[256];
	int n;

	fp = fopen( pfile, "r" );
	if( fp == NULL )  {
		ErrMsg( "* Open error ... %s\n", pfile );
		return;
	}

/* 音素数の確認 */
	n = 0;
	while( fgets( line, 256, fp ) != NULL )  {
		++n;
	}
	rewind( fp );

/* 領域確保 */
	phonemeList = (char **) malloc( n*sizeof(char *) );
	if( ! phonemeList )  {
		ErrMsg( "* malloc error for 'phonemeList'\n" );
		return;
	}
	n = 0;
	while( fgets( line, 256, fp ) != NULL )  {
/*		phonemeList[n] = (char *) malloc( sizeof(char) * (strlen(line)+1) ); */
		/* 行末に '\n' があるので、(strlen(line)) バイトでよい */
		phonemeList[n] = (char *) malloc( sizeof(char) * (strlen(line)) );
		if( ! phonemeList[n] )  {
			ErrMsg( "* malloc error for 'phonemeList[%d]'\n", n );
			return;
		}
/*		strcpy( phonemeList[n], line );		*/
		sscanf( line, "%s\n", phonemeList[n] );
		++n;
	}
	n_phoneme = n;
#ifdef PRINTDATA
	TmpMsg( "# of phonemes: %d\n", n_phoneme );
#endif
	fclose( fp );

	ph_i  = get_phoneme( "i" );
	ph_u  = get_phoneme( "u" );
	ph_I  = get_phoneme( "I" );		/* 無声化母音 */
	ph_U  = get_phoneme( "U" );		/* 無声化母音 */
	ph_k  = get_phoneme( "k" );
	ph_s  = get_phoneme( "s" );
	ph_sh = get_phoneme( "sh" );
	ph_t  = get_phoneme( "t" );
	ph_ch = get_phoneme( "ch" );
	ph_ts = get_phoneme( "ts" );
	ph_h  = get_phoneme( "h" );
	ph_f  = get_phoneme( "f" );
	ph_p  = get_phoneme( "p" );
	ph_ky = get_phoneme( "ky" );
	ph_hy = get_phoneme( "hy" );
	ph_py = get_phoneme( "py" );
	ph_sil = get_phoneme( "sil" );
}

/* 最初に一度だけ */
void init_phoneme()
{
	phhead = phtail = NULL;
}

/* 入力文ごとに */
/* 使っている音素のセルの開放 */
void refresh_phoneme()
{
	PHONEME *phoneme, *next;

	phoneme = phhead;
	while( phoneme )  {
		next = phoneme->next;
		free( phoneme );
		phoneme = next;
	}
	phhead = phtail = NULL;
}

/* 文字列 p からデリミタまでの文字を data に入れ、次の場所を返す */
static char *get_token( char *p, char *data )
{
	if( *p == '\0' )  return NULL;

	while( *p != ' ' && *p != '\0' )  {
		*(data++) = *(p++);
	}
	*data = '\0';
	if( *p == ' ' )  ++p;
	return p;
}

void kana2phoneme( char *kana, char *phms )
{
	int 	i;

	if( strcmp(kana,"pau")==0 )  {
		strcpy( phms, "pau" );
		return;
	}

	for( i=0; i<NUM_KANA; ++i )  {
		if( strcmp(kana,prnTable[i].kana)==0 )  {
			strcpy( phms, prnTable[i].phonemes );
			return;
		}
	}
	ErrMsg( "* Unknown KANA ... %s\n", kana );
	strcpy( phms, "pau" );
	return;
/*	restart(1);	*/
}

/* 音素 phoneme をモーラ mora に追加する */
void add_to_phoneme( MORA *mora, PHONEME *phoneme )
{
	if( mora->phead == NULL )  {
		/* 一つめの子供 */
		mora->phead = mora->ptail = phoneme;
	} else {
		/* 最後尾の子供に */
		mora->ptail = phoneme;
	}
	phoneme->parent = mora;
}

PHONEME *new_phoneme()
{
	PHONEME	*phoneme;

	phoneme = (PHONEME *) malloc( sizeof(PHONEME) );
	if( ! phoneme )  {
		ErrMsg( "* malloc error for 'phoneme'\n" );
		restart(1);
	}
/* 作った音素セルをチェーンの中に入れる */
	if( phhead == NULL )  {
		/* 一つめのセル */
		phhead = phtail = phoneme;
		phoneme->prev = phoneme->next = NULL;
	} else {
		/* tail の後ろに追加 */
		phtail->next = phoneme;
		phoneme->prev = phtail;
		phoneme->next = NULL;
		phtail = phoneme;
	}
	phoneme->parent = NULL;

	phoneme->phoneme = NULL;
	phoneme->time = 0.0;
	phoneme->sid = spid;
	phoneme->alpha = speaker[spid].alpha;

	return phoneme;
}

void do_devoicing()
{
	MORPH *m;
	PHONEME	*p;

	/* ポーズの前の「ます」「です」を無声化させる。*/
	for( m=mphead; m->next; m=m->next )  {
		if( m->next->silence == NON )  continue;

		if( m->mrtail == NULL )  continue;		/* 「」など。*/

		if( strcmp(m->mrtail->yomi,"ス")==0 &&
			strcmp(m->mrtail->prev->yomi,"マ")==0 )  {
				m->mrtail->ptail->phoneme = ph_U;
				m->mrtail->devoiced = YES;
		} else if( strcmp(m->mrtail->yomi,"ス")==0 &&
			strcmp(m->mrtail->prev->yomi,"デ")==0 )  {
				m->mrtail->ptail->phoneme = ph_U;
				m->mrtail->devoiced = YES;
		}
	}

	/* 先行音素が無声音で、後続音素が無声音の /i/, /u/ は無声化母音 */

	for( p=phtail; p; p=p->prev )  {
/*  for( p=phhead; p; p=p->next )  { */

		/* 無声化する母音は /i/ と /u/ だけ */
		if( p->phoneme != ph_i && p->phoneme != ph_u )  continue;

		/* 先行音素のチェック */
		if( ! is_unvoice(p->prev->phoneme) )  continue;

		/* 後続音素のチェック */
		if( ! is_unvoice(p->next->phoneme) )  continue;

		/* 続けて無声化させない */
		if( p->parent->next->devoiced == YES )  continue;
/* 		if( p->parent->prev->devoiced == YES )  continue;	*/

		p->parent->devoiced = YES;
		if( p->phoneme == ph_i )  {
			p->phoneme = ph_I;
		} else if( p->phoneme == ph_u )  {
			p->phoneme = ph_U;
		}
	}
}

void make_phoneme()
{
	MORA *mora;
	PHONEME	*phoneme;
	char phms[16], phm[8], *p;

	for( mora=mrhead; mora; mora=mora->next )  {
		if( mora->silence == SILB || mora->silence == SILE) {
			phoneme = new_phoneme();
			add_to_phoneme(mora,phoneme);
			phoneme->phoneme = get_phoneme( "sil" );
		} else if( mora->chouonka == YES )  {
			phoneme = new_phoneme();
			add_to_phoneme( mora, phoneme );
			/* 一つ前の音素と同じ */
			phoneme->phoneme = phoneme->prev->phoneme;
		} else {
			kana2phoneme( mora->yomi, phms );
			p = phms;
			while( (p=get_token(p, phm)) )  {
				phoneme = new_phoneme();
				add_to_phoneme( mora, phoneme );
				phoneme->phoneme = get_phoneme( phm );
			}
		}
	}
	do_devoicing();
/*	print_mora();	*/
}

void print_phoneme()
{
	PHONEME	*p;

	LogMsg( "* phoneme data\n" );
	for( p=phhead; p; p=p->next )  {
		LogMsg( "%s ", p->phoneme );
	}
	LogMsg( "\n" );
}
