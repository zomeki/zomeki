/* Copyright (c) 2000-2006                  */
/*   Yamashita Lab., Ritsumeikan University */
/*   All rights reserved                    */
/*                                          */
/*   $Id: fileIO.c,v 1.8 2009/02/12 17:43:42 sako Exp $                                   */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>

#include "synthesis.h"
#include "defaults.h"
#include "slot.h"
#include "misc.h"
#include "model.h"

extern int totalframe;

int ErrMsg(char *,...);
int TmpMsg(char *,...);
void restart(int);
int xfwrite( void *, int, int, FILE *);
int xfwrite_LE( void *, int, int, FILE *);
int xfread( void *, int, int, FILE *);
int xfread_LE( void *, int, int, FILE *);
PHONEME *new_phoneme();
char *get_phoneme(char *);

/*---------------------------------------------------------------------*/

void do_output_info(char *sfile)
{
	FILE *fp;
	char dfile[256];
	int dur;
	PHONEME *phoneme;
	MORPH *morph;

	sprintf( dfile, "%s.info", sfile );
	fp = fopen( dfile, "w" );
	if( fp == NULL )  {
		ErrMsg( "* File Open Error ... %s\n", dfile );
		return;
	}
	if( input_text[0] )  {
		fprintf( fp, "input_text: %s\n", input_text );
		fprintf( fp, "spoken_text: %s\n", spoken_text );
	} else {
		/* ParsedText での入力のとき */
		for( morph=mphead; morph; morph=morph->next )  {
			if( strncmp(morph->kanji,"sil",3)==0 )  continue;
			fprintf( fp, "%s", morph->kanji );
		}
		fprintf( fp, "\n" );
	}
	fprintf( fp, "-----\n" );
	phoneme = phhead;
	while( phoneme )  {
		dur = (int)(phoneme->time);
		fprintf( fp, "%s [%d]\n", phoneme->phoneme, dur );
		phoneme = phoneme->next;
	}
	fprintf( fp, "-----\n" );
	fclose( fp );
}

void do_output_file(char *sfile)
{
	FILE *fp;

	fp = fopen( sfile, "wb" );
	if( fp == NULL )  {
		ErrMsg( "* File Open Error ... %s\n", sfile );
		return;
	}
	xfwrite( wave.data, sizeof(short), wave.nsample, fp );
	fclose( fp );

	do_output_info(sfile);
}

void do_output_WAVfile(char *sfile)
{
	FILE *fp;
	char s[4];
	long var_long;
	short var_short;

	fp = fopen( sfile, "wb" );
	if( fp == NULL )  {
		ErrMsg( "* File Open Error ... %s\n", sfile );
		return;
	}
	strncpy( s, "RIFF", 4 );
	xfwrite_LE( s, 1, 4, fp );
	var_long = wave.nsample*2 + 36;
	xfwrite_LE( &var_long, 4, 1, fp );
	strncpy( s, "WAVE", 4 );
	xfwrite_LE( s, 1, 4, fp );
	strncpy( s, "fmt ", 4 );
	xfwrite_LE( s, 1, 4, fp );
	var_long = 16;
	xfwrite_LE( &var_long, 4, 1, fp );
	var_short = 1;  /* PCM */
	xfwrite_LE( &var_short, 2, 1, fp );
	var_short = 1;  /* monoral */
	xfwrite_LE( &var_short, 2, 1, fp );
	var_long = 16000;	/* sampling rate (16kHz) */
	xfwrite_LE( &var_long, 4, 1, fp );
	var_long = 16000*2;	/* byte/sec (monoral, 16kHz, 2byte/sample) */
	xfwrite_LE( &var_long, 4, 1, fp );
	var_short = 2;  /* channel*byte/sample (16bit, monoral) */
	xfwrite_LE( &var_short, 2, 1, fp );
	var_short = 16;  /* bit/sample (16bit) */
	xfwrite_LE( &var_short, 2, 1, fp );
	strncpy( s, "data", 4 );
	xfwrite_LE( s, 1, 4, fp );
	var_long = wave.nsample*2;
	xfwrite_LE( &var_long, 4, 1, fp );

	xfwrite_LE( wave.data, sizeof(short), wave.nsample, fp );
	fclose( fp );

	do_output_info(sfile);
}


/*---------------------------------------------------------------------*/

#define WAVE_HEADER  44  /* byte */

void read_speech_file( char *sfile, SPEECHFILETYPE type )
{
	FILE *fp;
	struct stat buf;
	static int nsample;
	char dfile[256], tbuf[MAX_TEXT_LEN];
	int dur;
	PHONEME *phoneme;

	if( stat( sfile, &buf ) != 0 )  {
		ErrMsg( "* File Open Error ... %s\n", sfile );
		return;
	}
	if( type == WAV )  {
		nsample = ( buf.st_size - WAVE_HEADER ) / sizeof(short);
	} else {
		nsample = buf.st_size / sizeof(short);
	}
	free( wave.data );
	wave.data = (short *) calloc( nsample, sizeof(short) );
	if( wave.data == NULL )  {
		ErrMsg( "Memory allocation error !\n" );
		restart(1);
	}

	fp = fopen( sfile, "rb" );
	if( fp == NULL )  {
		ErrMsg( "* File Open Error ... %s\n", sfile );
		return;
	}
	if( type == WAV )  {
		fseek( fp, WAVE_HEADER, SEEK_SET );
		xfread_LE( wave.data, sizeof(short), nsample, fp );
	} else {
		xfread( wave.data, sizeof(short), nsample, fp );
	}
	fclose( fp );

	wave.nsample = nsample;
	wave.rate = SAMPLE_RATE;

	sprintf( dfile, "%s.info", sfile );
	fp = fopen( dfile, "r" );
	if( fp == NULL )  {
		ErrMsg( "* File Open Error ... %s\n", dfile );
		return;
	}
	fscanf( fp, "input_text: %s\n", input_text );
	fscanf( fp, "spoken_text: %s\n", spoken_text );
	do {
		fscanf( fp, "%s\n", tbuf );
	} while( tbuf[0] != '-' );
	while( 1 )  {
		fscanf( fp, "%s [%d]\n", tbuf, &dur );
		if( tbuf[0] == '-' )  break;
		phoneme = new_phoneme();
		phoneme->phoneme = get_phoneme( tbuf );
		phoneme->time = dur;
	}
	fclose( fp );
}


/*---------------------------------------------------------------------*/

void do_output_pros(char *ffile)
{
	FILE *fp;
	int dur;
	PHONEME *phoneme;
	MORPH *morph;
	int i;
	int shift_start;
	
	shift_start = mhead->totalduration - 
	  ((int )(SILENCE_LENGTH / FRAME_RATE));
	
	fp = fopen( ffile, "w" );
	if( fp == NULL )  {
		ErrMsg( "* File Open Error ... %s\n", ffile );
		return;
	}
	if( input_text[0] )  {
		fprintf( fp, "input_text: %s\n", input_text );
		fprintf( fp, "spoken_text: %s\n", spoken_text );
	} else {
		/* ParsedText での入力のとき */
		for( morph=mphead; morph; morph=morph->next )  {
			if( strncmp(morph->kanji,"sil",3)==0 )  continue;
			fprintf( fp, "%s", morph->kanji );
		}
		fprintf( fp, "\n" );
	}
	fprintf( fp, "number_of_phonemes: %d\n", slot_n_phonemes );
	fprintf( fp, "total_duration: %d\n", slot_total_dur );
	fprintf( fp, "-----\n" );
	phoneme = phhead;
	while( phoneme )  {
		dur = (int)(phoneme->time);
		fprintf( fp, "%s [%d]\n", phoneme->phoneme, dur );
		phoneme = phoneme->next;
	}
	fprintf( fp, "-----\n" );
	fprintf( fp, "total_frame: %d\n", totalframe );
	fprintf( fp, "-----\n" );
	for( i=0; i<totalframe; ++i )  {
		fprintf( fp, "%d: %lf %lf\n", i, f0.data[i+shift_start], power.data[i+shift_start] );
	}
	fprintf( fp, "-----\n" );
	fclose( fp );
}

/*---------------------------------------------------------------------*/

int read_pros_file( char *ffile )
{
	FILE *fp;
	char tbuf[MAX_TEXT_LEN], phname[128];
	int i, j, nph, nfr;

	fp = fopen( ffile, "r" );
	if( fp == NULL )  {
		ErrMsg( "* File Open Error ... %s\n", ffile );
		return -1;
	}
	fscanf( fp, "input_text: %s\n", input_text );
	fscanf( fp, "spoken_text: %s\n", spoken_text );
	fscanf( fp, "number_of_phonemes: %d\n", &nph );
	do {
		fscanf( fp, "%s\n", tbuf );
	} while( tbuf[0] != '-' );

	prosBuf.ph_name = (char **)malloc( nph * sizeof(char *));
	if( prosBuf.ph_name == NULL )  {
		ErrMsg( "* malloc error in 'prosBuf.ph_name'\n" );
		restart(1);
	}
	prosBuf.ph_dur = (int *)malloc( nph * sizeof(int));
	if( prosBuf.ph_dur == NULL )  {
		ErrMsg( "* malloc error in 'prosBuf.ph_dur'\n" );
		restart(1);
	}

	for( i=0; i<nph; ++i )  {
		fscanf( fp, "%s [%d]\n", phname, &(prosBuf.ph_dur[i]) );
		prosBuf.ph_name[i] = get_phoneme( phname );
	}

	fscanf( fp, "%s\n", tbuf );  /* to skip '----' */
	fscanf( fp, "total_frame: %d\n", &nfr );
	do {
		fscanf( fp, "%s\n", tbuf );
	} while( tbuf[0] != '-' );

	prosBuf.fr_power = (double *)malloc( (nfr+1) * sizeof(double));
	if( prosBuf.fr_power == NULL )  {
		ErrMsg( "* malloc error in 'prosBuf.fr_power'\n" );
		restart(1);
	}
	prosBuf.fr_f0 = (double *)malloc( (nfr+1) * sizeof(double));
	if( prosBuf.fr_f0 == NULL )  {
		ErrMsg( "* malloc error in 'prosBuf.fr_f0'\n" );
		restart(1);
	}

	for( i=0; i<=nfr; ++i )  {
		fscanf( fp, "%d: %lf %lf\n", 
			&j, &(prosBuf.fr_f0[i]), &(prosBuf.fr_power[i]) );
	}
	fclose( fp );

/* エラーがなければ、音素数、フレー無数をセット */
	prosBuf.nPhoneme = slot_n_phonemes = nph;
	prosBuf.nFrame = nfr;

	return 0;
}

int set_f0_and_power( char *ffile )
{
	PHONEME *phoneme;
	int i;
	int shift_start;

	/* 長さをそろえる */
	shift_start = mhead->totalduration - 
	  ((int )(SILENCE_LENGTH / FRAME_RATE));

	phoneme = phhead;
	i = 0;
	while( phoneme )  {
		if( phoneme->phoneme != prosBuf.ph_name[i] )  {
			ErrMsg( "* Phoneme sequence does not match ... %s\n", ffile );
			return -1;
		}
		phoneme->time = prosBuf.ph_dur[i];
		phoneme = phoneme->next;
		++i;
	}

	if( prosBuf.nFrame > totalframe )  {
		f0.data = realloc( f0.data, (prosBuf.nFrame+1)*sizeof(double) );
		if( f0.data == NULL )  {
			ErrMsg("Memory allocation error !  (in read_pros_file)\n");
			restart(1);
		}
		power.data = realloc( power.data, (prosBuf.nFrame+1)*sizeof(double) );
		if( power.data == NULL )  {
			ErrMsg("Memory allocation error !  (in read_pros_file)\n");
			restart(1);
		}
	}
	for( i=0; i<=prosBuf.nFrame; ++i )  {
		f0.data[i+shift_start] = prosBuf.fr_f0[i];
		power.data[i+shift_start] = prosBuf.fr_power[i];
	}
/*
	printf( "totalframe: %d\n", prosBuf.nFrame );
	for( i=0; i<=10; ++i )  {
		printf( "%d: %lf %lf\n", i, f0.data[i], power.data[i] );
	}
*/
	return 0;
}

