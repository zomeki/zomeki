/* Copyright (c) 2000-2006                  */
/*   Yamashita Lab., Ritsumeikan University */
/*   All rights reserved                    */
/*                                          */
/* $Id: read_conf.c,v 1.18 2009/02/13 02:02:47 sako Exp $                                     */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "synthesis.h"
#include "confpara.h"
#include "slot.h"

int ErrMsg(char *, ...);
int TmpMsg(char *, ...);
int LogMsg(char *,...);
char* malloc_char(char *, char *);

static int flag_print_conf = 0;

int speakerID( char *name )
{
	int i;

	for( i=0; i<n_speaker; ++i )  {
		if( strcmp(name,speaker[i].code)==0 )  return i;
	}
	ErrMsg( "* Unknown speaker ... %s\n", name );
	return -1;
}

void check_speaker_conf( int sid )
{
	if( speaker[sid].gender == UNKNOWN )  {
		ErrMsg( "* GENDER of speaker '%s' is unknown.\n" );
		--n_speaker;
		return;
	}
	if( speaker[sid].dur_tree_file == NULL )  {
		ErrMsg( "* DUR-TREE-FILE for speaker '%s' is unknown.\n" );
		--n_speaker;
		return;
	}
	if( speaker[sid].pit_tree_file == NULL )  {
		ErrMsg( "* PIT-TREE-FILE for speaker '%s' is unknown.\n" );
		--n_speaker;
		return;
	}
	if( speaker[sid].mcep_tree_file == NULL )  {
		ErrMsg( "* MCEP-TREE-FILE for speaker '%s' is unknown.\n" );
		--n_speaker;
		return;
	}
	if( speaker[sid].dur_model_file == NULL )  {
		ErrMsg( "* DUR-MODEL-FILE for speaker '%s' is unknown.\n" );
		--n_speaker;
		return;
	}
	if( speaker[sid].pit_model_file == NULL )  {
		ErrMsg( "* PIT-MODEL-FILE for speaker '%s' is unknown.\n" );
		--n_speaker;
		return;
	}
	if( speaker[sid].mcep_model_file == NULL )  {
		ErrMsg( "* MCEP-MODEL-FILE for speaker '%s' is unknown.\n" );
		--n_speaker;
		return;
	}
}

void set_conf_para( char* cpara, char* val )
{
	int i;

	if( strcmp(cpara,"PHONEME-LIST")==0 )  {
		phlist_file = malloc_char( val, "phlist_file" );
	} else if( strcmp(cpara,"CHASEN")==0 )  {
		chasen_bin = malloc_char( val, "chasen_bin" );
	} else if( strcmp(cpara,"CHASEN-DLL")==0 )  {
		chasen_dll = malloc_char( val, "chasen_dll" );
	} else if( strcmp(cpara,"CHASEN-RC")==0 )  {
		chasen_rc = malloc_char( val, "chasen_rc" );
	} else if( strcmp(cpara,"CHAONE")==0 )  {
		chaone_bin = malloc_char( val, "chaone_bin" );
	} else if( strcmp(cpara,"NUMBER")==0 )  {
		read_number = malloc_char( val, "read_number" );
	} else if( strcmp(cpara,"ALPHABET")==0 )  {
		read_alphabet = malloc_char( val, "read_alphabet" );
	} else if( strcmp(cpara,"DATE")==0 )  {
		read_date = malloc_char( val, "read_date" );
	} else if( strcmp(cpara,"TIME")==0 )  {
		read_time = malloc_char( val, "read_time" );
	} else if( strcmp(cpara,"DICTIONARY")==0 )  {
		dic_file = malloc_char( val, "dic_file" );
	} else if( strcmp(cpara,"AUTO-PLAY")==0 )  {
		i = 0;
		while( val[i] )  { val[i] = tolower( val[i] ); ++i; }
		if( strcmp( val, "yes" )==0 )  {
			slot_Auto_play = 1;
		}
	} else if( strcmp(cpara,"AUTO-PLAY-DELAY")==0 )  {
		slot_Auto_play_delay = atoi( val );
	} else if( strcmp(cpara,"SYNC-INTERVAL")==0 )  {
	        slot_Speak_syncinterval = atoi( val );
	} else if( strcmp(cpara,"SPEAKER-ID")==0 )  {
		if( n_speaker > 0 )  check_speaker_conf( n_speaker-1 );
		speaker[n_speaker].code = malloc_char( val, "speaker.code" );
		speaker[n_speaker].gender = UNKNOWN;
		speaker[n_speaker].dur_tree_file = NULL;
		speaker[n_speaker].pit_tree_file = NULL;
		speaker[n_speaker].mcep_tree_file = NULL;
		speaker[n_speaker].dur_model_file = NULL;
		speaker[n_speaker].pit_model_file = NULL;
		speaker[n_speaker].mcep_model_file = NULL;
		speaker[n_speaker].alpha = DEF_ALPHA;
		speaker[n_speaker].alpha_saved = -1.0;
		speaker[n_speaker].postfilter_coef = DEF_POSTFILTER_COEF;
		spid = n_speaker;
		++n_speaker;
	} else if( strcmp(cpara,"GENDER")==0 )  {
		if( strcmp(val,"male")==0 )  {
			speaker[spid].gender = MALE;
		} else if( strcmp(val,"female")==0 )  {
			speaker[spid].gender = FEMALE;
		} else {
			speaker[spid].gender = UNKNOWN;
		}
	} else if( strcmp(cpara,"DUR-TREE-FILE")==0 )  {
		speaker[spid].dur_tree_file = malloc_char( val, "dur_tree_file" );
	} else if( strcmp(cpara,"PIT-TREE-FILE")==0 )  {
		speaker[spid].pit_tree_file = malloc_char( val, "pit_tree_file" );
	} else if( strcmp(cpara,"MCEP-TREE-FILE")==0 )  {
		speaker[spid].mcep_tree_file = malloc_char( val, "mcep_tree_file" );
	} else if( strcmp(cpara,"DUR-MODEL-FILE")==0 )  {
		speaker[spid].dur_model_file = malloc_char( val, "dur_model_file" );
	} else if( strcmp(cpara,"PIT-MODEL-FILE")==0 )  {
		speaker[spid].pit_model_file = malloc_char( val, "pit_model_file" );
	} else if( strcmp(cpara,"MCEP-MODEL-FILE")==0 )  {
		speaker[spid].mcep_model_file = malloc_char( val, "mcep_model_file" );
	} else if( strcmp(cpara,"PRINT-CONF")==0 )  {
		if( strcmp(val,"YES")==0 ) {
			flag_print_conf = 1;
		} else if( strcmp(val,"NO")==0 ) {
			flag_print_conf = 0;
		} else {
			ErrMsg( "* Unknown value for PRINT-CONF: %s\n", val );
			ErrMsg( "    reagal values are YES or NO.\n" );
		}
#if defined(WIN32) || defined(USE_CHASENLIB)
	} else if( strcmp(cpara,"CHAONE-XSL-FILE")==0 )  {
		chaone_xsl = malloc_char( val, "chaone_xsl" );
#endif
	} else if( strcmp(cpara,"AUDIODEV")==0 )  {
		conf_audiodev = malloc_char( val, "conf_audiodev" );
	} else {
		ErrMsg( "* Unknown configuration parameter: %s\n", cpara );
	}
}

void init_conf()
{
	phlist_file = NULL;
	chasen_bin = chasen_rc = chaone_bin = NULL;
	chasen_dll = chaone_xsl = NULL;
	n_speaker = 0;
	spid = 0;
	dic_file = NULL;
	slot_Auto_play = 0;
	slot_Auto_play_delay = 250;	/* msec */
}

#define MAX_LINE 256

void read_conf( char* cfile )
{
	FILE *fp;
	char line[MAX_LINE], cpara[MAX_LINE], val[MAX_LINE], *c;
	int p;

	fp = fopen( cfile, "r" );
	if( fp ==  NULL )  {
		ErrMsg( "* Conf file '%s' does not exist.\n", cfile );
		return;
	}

	while( fgets( line, MAX_LINE, fp )!=NULL )  {
		if( line[0] == '#' || line[0]=='\n' )  continue;
/*		printf( "%s\n", line );	*/

		c = line;
		p = 0;
		while( *c!=':' && *c!='\n' )  { cpara[p++] = *(c++); }
		cpara[p] = '\0';
		if( *c != ':' )  {
			ErrMsg( "* Unknown conf line ...\n%s" );
			continue;
		}
		--p;
		while( cpara[p]==' ' || cpara[p]=='\t' )  { cpara[p--]='\0'; }
			
		++c;
		while( *c==' ' || *c=='\t' )  { ++c; }
		if( *c=='\'' || *c=='"' )  { ++c; }

		p = 0;
/*
		while( *c!=' ' && *c!='\t' && *c!='\n' )  { val[p++] = *(c++); }
		if( val[p-1]=='\'' || val[p-1]=='"' )  { --p; }
*/
		while( *c!='\t' && *c!='\n' )  { val[p++] = *(c++); }
		if( p >= 1 )  {
			if( val[p-1]==' ' || val[p-1]=='\'' || val[p-1]=='"' )  { --p; }
		}
		val[p] = '\0';
		set_conf_para( cpara, val );
	}

	fclose( fp );
}

/*------------------------------------------------------------*/

char* gender_str( GENDER g )
{
	if( g == MALE )  return( "male" );
	if( g == FEMALE )  return( "female" );
	return "UNKNOWN";
}

void print_conf()
{
	int i;
	LogMsg( "PHONEME-LIST: \"%s\"\n", phlist_file );
#ifdef WIN32
	LogMsg( "CHASEN-DLL: \"%s\"\n", chasen_dll );
#else
	LogMsg( "CHASEN: \"%s\"\n", chasen_bin );
#endif
	LogMsg( "CHASEN-RC: \"%s\"\n", chasen_rc );
	LogMsg( "CHAONE: \"%s\"\n", chaone_bin );
	LogMsg( "NUMBER: \"%s\"\n", read_number );
	LogMsg( "ALPHABET: \"%s\"\n", read_alphabet );
	LogMsg( "DATE: \"%s\"\n", read_date );
	LogMsg( "TIME: \"%s\"\n", read_time );
	if( slot_Auto_play )  {
		LogMsg( "AUTO-PLAY: YES\n" );
	} else {
		LogMsg( "AUTO-PLAY: NO\n" );
	}
	LogMsg( "AUTO-PLAY-DELAY: \"%d\"[msec]\n", slot_Auto_play_delay );

	for( i=0; i<n_speaker; ++i )  {
		LogMsg( "\n" );
		LogMsg( "SPEKER-ID: \"%s\"\n", speaker[i].code );
		LogMsg( "GENDER: \"%s\"\n", gender_str( speaker[i].gender ) );
		LogMsg( "DUR-TREE-FILE: \"%s\"\n", speaker[i].dur_tree_file );
		LogMsg( "PIT-TREE-FILE: \"%s\"\n", speaker[i].pit_tree_file );
		LogMsg( "MCEP-TREE-FILE: \"%s\"\n", speaker[i].mcep_tree_file );
		LogMsg( "DUR-MODEL-FILE: \"%s\"\n", speaker[i].dur_model_file );
		LogMsg( "PIT-MODEL-FILE: \"%s\"\n", speaker[i].pit_model_file );
		LogMsg( "MCEP-MODEL-FILE: \"%s\"\n", speaker[i].mcep_model_file );
	}
}

/* conf ファイル読み込みの後で実行される。 */
void set_default_conf()
{
	if( phlist_file == NULL )  {
		phlist_file = malloc_char( DEF_PHLIST_FILE, "phlist_file" );
	}
	if( chasen_bin == NULL )  {
		chasen_bin = malloc_char( DEF_CHASEN_BIN, "chasen_bin" );
	}
	if( chasen_dll == NULL )  {
		chasen_dll = malloc_char( DEF_CHASEN_DLL, "chasen_dll" );
	}
	if( chasen_rc == NULL )  {
		chasen_rc = malloc_char( DEF_CHASEN_RC, "chasen_rc" );
	}
	if( chaone_bin == NULL )  {
		chaone_bin = malloc_char( DEF_CHAONE_BIN, "chaone_bin" );
	}
	if( read_number == NULL )  {
		read_number = malloc_char( DEF_READ_NUMBER, "read_number" );
	}
	if( read_alphabet == NULL )  {
		read_alphabet = malloc_char( DEF_READ_ALPHABET, "read_alphabet" );
	}
	if( read_date == NULL )  {
		read_date = malloc_char( DEF_READ_DATE, "read_date" );
	}
	if( read_time == NULL )  {
		read_time = malloc_char( DEF_READ_TIME, "read_time" );
	}
	if( n_speaker == 0 )  {
		speaker[0].code = malloc_char( DEF_SP_CODE, "speaker.code" );
		speaker[0].gender = DEF_SP_GENDER;
		speaker[0].dur_tree_file = malloc_char( DEF_DUR_TREE_FILE, "dur_tree_file" );
		speaker[0].pit_tree_file = malloc_char( DEF_PIT_TREE_FILE, "pit_tree_file" );
		speaker[0].mcep_tree_file = malloc_char( DEF_MCEP_TREE_FILE, "mcep_tree_file" );
		speaker[0].dur_model_file = malloc_char( DEF_DUR_MODEL_FILE, "dur_model_file" );
		speaker[0].pit_model_file = malloc_char( DEF_PIT_MODEL_FILE, "pit_model_file" );
		speaker[0].mcep_model_file = malloc_char( DEF_MCEP_MODEL_FILE, "mcep_model_file" );
		speaker[0].alpha = DEF_ALPHA;
		n_speaker = 1;
		spid = 0;
	}
	/* 最初の話者を初期話者に */
	spid = 0;

#if defined(WIN32) || defined(USE_CHASENLIB)
	if( chaone_xsl == NULL ) {
		chaone_xsl = malloc_char ( DEF_XSLT_FILE, "chaone_xsl" );
	}
#endif
	if( (logfp && slot_Log_conf) || flag_print_conf )  print_conf();
}
