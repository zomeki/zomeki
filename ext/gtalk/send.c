/* Copyright (c) 2000-2006                  */
/*   Yamashita Lab., Ritsumeikan University */
/*   All rights reserved                    */
/*                                          */
/* $Id: send.c,v 1.15 2006/10/19 03:27:08 sako Exp $                                     */

#include <stdio.h>
#include "synthesis.h"
#include "confpara.h"

void RepMsg( char *, ... );

/*******↓for server mode *******/
extern int s_mode;
/*******↑***********************/

void send_speakerset()
{
	int i;

	RepMsg( "rep SpeakerSet =" );
	for( i=0; i<n_speaker; ++i )  RepMsg( " %s", speaker[i].code );
	RepMsg( "\n" );
}

void send_speaker()
{
	RepMsg( "rep Speaker = %s\n", speaker[spid].code );
}

void send_text( char *slot )
{
	MORPH *morph;

	RepMsg( "rep %s = ", slot );
	for( morph = mphead; morph; morph = morph->next )  {
		if( morph->silence != SILB && morph->silence != SILE &&
			morph->silence != PAU )
			RepMsg( "%s", morph->kanji );
	}
	RepMsg( "\n" );
}

void send_phonemes( char *slot )
{
	PHONEME *phoneme;
	int dur;

	RepMsg( "rep %s =", slot );
	for( phoneme = phhead; phoneme; phoneme = phoneme->next )  {
		dur = (int)(phoneme->time);
		RepMsg( " %s[%d]", phoneme->phoneme, dur );
	}
	if (s_mode) {
	        RepMsg( "phoneme_end\n" );
	} else {
	        RepMsg( "\n" );
	}
}

void send_duration( char *slot )
{
	PHONEME *phoneme;
	int durTotal, dur, n;

	durTotal = n = 0;
	for( phoneme = phhead; phoneme; phoneme = phoneme->next )  {
		dur = (int)(phoneme->time);
		durTotal += dur;
		++n;
	}
	RepMsg( "rep %s = %d\n", slot, durTotal );
}

extern int talked_DA_msec;
extern int already_talked;

void send_talked_duration()
{
	if( already_talked == 1 )  {
		if( talked_DA_msec < 0 )  {
			send_duration( "Speak.len" );
		} else {
			RepMsg( "rep Speak.len = %d\n", talked_DA_msec );
		}
	} else {
		RepMsg( "rep Speak.len = %d\n", 0 );
	}
}

void send_talked_phonemes()
{
	PHONEME *phoneme;
	int dur;

	if( already_talked == 0 )  {
		RepMsg( "rep Speak.utt =\n" );
		return;
	}

	if( talked_DA_msec < 0 )  {
		send_phonemes( "Speak.utt" );
		return;
	}

	RepMsg( "rep Speak.utt =" );
	for( phoneme = phhead; phoneme; phoneme = phoneme->next )  {
		dur = (int)(phoneme->time);
		if( phoneme->ctime+phoneme->time >= talked_DA_msec )  {
			RepMsg( "\n" );
			return;
		} else {
			RepMsg( " %s[%d]", phoneme->phoneme, dur );
		}
	}
	if (s_mode) {
	        RepMsg( "phoneme_end\n" );
	} else {
	        RepMsg( "\n" );
	}
}
