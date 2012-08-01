/* Copyright (c) 2003-2008                                           */
/*   Interactive Speech Technology Consortium (ISTC)                 */
/*   All rights reserved                                             */
/*                                                                   */
/*   The code is developed by Yamashita-lab, Ritsumeikan University  */
/*                                                                   */
/* $Id: main.c,v 1.34 2009/02/25 01:27:50 sako Exp $                                                              */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#ifdef WIN32
#include <windows.h>
#else
#include <unistd.h>
#include <sys/wait.h>
#endif
#include <setjmp.h>
#include "synthesis.h"
#include "command.h"
#include "confpara.h"

#include "misc.h"
#include "model.h"
#include "tree.h"
#include "defaults.h"
#include "hmmsynth.h"
#include "mlpg.h"
#include "tag.h"

#define INIT_SLOT_TABLE
#include "slot.h"

#define YesNoSlot(s)  ( ( (s==1) ? "YES" : "NO" ) )

char *moduleVersion = "GalateaTalk Ver. 1.5.1 (gtalk-090225)";
char *protocolVersion = "Protocol Ver. 1.0";

/* synthesis.h グローバル変数の定義 */
MORPH *mphead;
MORPH *mptail;
PHONEME *phhead;
PHONEME *phtail;
MORA *mrhead;
MORA *mrtail;
APHRASE *ahead;
APHRASE *atail;
BREATH *bhead;
BREATH *btail;
SENTENCE *shead;
SENTENCE *stail;
SENTENCE *sentence;
WAVE wave;
PARAM power;
PARAM f0;
PARAM alpha;
/*******↓for server mode ********/
int s_mode = 0;
int nPort = 10600;
/********↑***********************/

PROS prosBuf;	/* 韻律データの一時格納用 */

/* confpara.h グローバル変数の定義 */
char *phlist_file;
char *chasen_bin;
char *chasen_dll;
char *chaone_xsl;
char *chasen_rc;
char *chaone_bin;
char *chaone_xsl;
char *read_number;
char *read_alphabet;
char *read_date;
char *read_time;
int n_speaker;	/* 登録された話者数 */
int spid;	/* 現在の話者ID */
FILE *logfp;
SPEAKER speaker[MAX_SPEAKER];
char *dic_file;
char *conf_audiodev = NULL;  /* 実行時に指定されるオーディオデバイス */

/* hmmsynth.h グローバル変数定義 */
int nstate;
int pitchstream;
int mcepvsize;
ModelSet mset[MAX_SPEAKER];
double **mcep;  /* generated mel-cepstrum */
double **coeff; /* mlsa filter coefficients */
int totalframe;

/* mlpg.h */
PStream pitchpst;
PStream mceppst;
Boolean *voiced;

/* model.h */
Model *mhead;
Model *mtail;
FILE *durmodel;
FILE *pitchmodel;
FILE *mcepmodel;

/* tag.h */
TAG *tag[MAX_TAG];
int n_tag;

/* slot.h */
SlotProp prop_Run;
SlotProp prop_ModuleVersion;
SlotProp prop_ProtocolVersion;
SlotProp prop_SpeakerSet;
SlotProp prop_Speaker;
SlotProp prop_SpeechFile;
SlotProp prop_ProsFile;
SlotProp prop_Text;
SlotProp prop_Text_text;
SlotProp prop_Text_pho;
SlotProp prop_Text_dur;
SlotProp prop_Speak;
SlotProp prop_Speak_text;
SlotProp prop_Speak_pho;
SlotProp prop_Speak_dur;
SlotProp prop_Speak_utt;
SlotProp prop_Speak_len;
SlotProp prop_Speak_stat;
SlotProp prop_Speak_syncinterval;

/* slots */
char slot_Run[20];
char slot_Speak_stat[20];
char input_text[MAX_TEXT_LEN];  /* 入力されたテキスト(タグつき) */
char spoken_text[MAX_TEXT_LEN]; /* 音声出力された発話のテキスト */
char slot_Log_file[256];
char slot_Err_file[256];
char slot_Speech_file[512];
char slot_Pros_file[512];
int slot_Auto_play;
int slot_Auto_play_delay;
int slot_n_phonemes;
int slot_total_dur;
int slot_Log_chasen;
int slot_Log_tag;
int slot_Log_phoneme;
int slot_Log_mora;
int slot_Log_morph;
int slot_Log_aphrase;
int slot_Log_breath;
int slot_Log_conf;
int slot_Log_text;
int slot_Log_arranged_text;
int slot_Log_sentence;
int slot_Speak_syncinterval;

/* chaone */
#ifdef WIN32
#include "chaone.h"
#endif

void setRun( char*, char* );
void init_conf();
void read_conf(char *);
int speakerID(char *);
void set_default_conf();
void init_text_analysis();
void init_hmmsynth();
void set_da_signal();
void read_phonemes(char *);
void read_dic(char *);
void init_tag();
void init_mora();
void init_morph();
void init_aphrase();
void init_breath();
void init_phoneme();
void init_sentence();
void refresh_text_analysis();
void refresh_tag();
void refresh_mora();
void refresh_morph();
void refresh_aphrase();
void refresh_breath();
void refresh_phoneme();
void refresh_sentence();
void refresh_hmmsynth();
void refresh_vocoder();
int RepMsg(char *, ...);
int TmpMsg(char *, ...);
int ErrMsg(char *, ...);
void init_parameter();
void make_duration();
void make_parameter();
void unknown_com();
void restart(int);
void text_analysis();
void send_speakerset();
void send_speaker();
void send_text(char *);
void send_phonemes(char *);
void send_duration(char *);
void send_talked_phonemes();
void send_talked_duration();
void do_synthesis();
void do_output(char *);
void do_output_WAVfile(char *);
void do_output_pros(char *);
void read_speech_file(char *, SPEECHFILETYPE);
int read_pros_file(char *);
int set_f0_and_power(char *);
void update_duration();
void abort_output();
void text_analysis_file();
void reset_output();
void parameter_generation();
void modify_duration();
void make_cumul_time();
void modify_f0();
void modify_power();
void modify_voice();
int make_sleep_time(char *, long *);
void sig_wait_da();
int gtalk_getline( char *buf, int MAX_LENGTH );
/*******↓for server mode ********/
void refresh_server ( void );
int server_init ( int port );
void server_close_client ( void );
int server_getline ( char *buf, int buf_size );
void server_destroy ( void );
/********↑***********************/

extern FILE *fp_err;

void init_slot_prop()
{
	prop_Run = AutoOutput;
	prop_ModuleVersion = AutoOutput;
	prop_ProtocolVersion = AutoOutput;
	prop_SpeakerSet = AutoOutput;
	prop_Speaker = AutoOutput;
	prop_SpeechFile = AutoOutput;
	prop_ProsFile = AutoOutput;
	prop_Text = AutoOutput;
	prop_Text_text = AutoOutput;
	prop_Text_pho = AutoOutput;
	prop_Text_dur = AutoOutput;
	prop_Speak = AutoOutput;
	prop_Speak_text = AutoOutput;
	prop_Speak_pho = AutoOutput;
	prop_Speak_dur = AutoOutput;
	prop_Speak_utt = AutoOutput;
	prop_Speak_len = AutoOutput;
	prop_Speak_stat = AutoOutput;
	prop_Speak_syncinterval = AutoOutput;
}

/* 初期化: プログラム起動時に一度だけ実行 */
void initialize()
{
	void setRun();

	/*******↓for server mode *******/
	if (s_mode) {
	        server_init( nPort );
	}
	/*******↑***********************/
	
#ifndef WIN32
	setpgrp();
#endif
	set_da_signal();

	init_slot_prop();
	init_text_analysis();
	init_hmmsynth();
	read_phonemes( phlist_file );
	read_dic( dic_file );
	init_tag();
	init_mora();
	init_morph();
	init_aphrase();
	init_breath();
	init_phoneme();
	init_sentence();
	strcpy( slot_Speak_stat, "IDLE" );
	setRun( "=", "LIVE" );
	strcpy( slot_Log_file, "NO" );   logfp = NULL;
	slot_Log_chasen= slot_Log_tag = slot_Log_phoneme = 0;
	slot_Log_mora = slot_Log_morph = slot_Log_aphrase = 0;
	slot_Log_breath = slot_Log_sentence = 0;
	strcpy( slot_Err_file, "CONSOLE" );
	slot_Speech_file[0] = '\0';
	slot_Pros_file[0] = '\0';
	prosBuf.nPhoneme = 0;
	slot_Speak_syncinterval = 1000;
}

void refresh_prosBuf()
{
	if( prosBuf.nPhoneme == 0 )  return;

	free( prosBuf.ph_name );
	free( prosBuf.ph_dur );
	free( prosBuf.fr_power );
	free( prosBuf.fr_f0 );
	prosBuf.nPhoneme = prosBuf.nFrame = 0;
}

/* 初期化: 合成を行うたびに実行 */
void refresh()
{
	refresh_text_analysis();
	refresh_tag();
	refresh_mora();
	refresh_morph();
	refresh_aphrase();
	refresh_breath();
	refresh_phoneme();
	refresh_sentence();
	refresh_hmmsynth();
	refresh_prosBuf();
	refresh_server();
}

int commandID( char *com )
{
	int 	i;
	for( i=0; i<NUM_COMMAND; ++i )  {
		if( strcmp(com,commandTable[i].name)==0 )  return commandTable[i].id;
	}
	return -1;
}

int slotID( char *slot )
{
	int 	i;
	for( i=0; i<NUM_SLOT; ++i )  {
		if( strcmp(slot,slotTable[i].name)==0 )  return slotTable[i].id;
	}
	return -1;
}

#define MAX_COMMAND_LEN 8192  /* 入力コマンドの最大文字数 */
static char cline[MAX_COMMAND_LEN];

int read_command( char **args )
{
	int 	n=0, p=0;
	char	*c;

	if( s_mode ) {
	        if (server_getline( cline, MAX_COMMAND_LEN ) <= 0) {
  		        args[0] = "";
   		        return 0;
		}
	} else {
	        if( gtalk_getline( cline, MAX_COMMAND_LEN ) < 0)
		        setRun( "=", "EXIT" );
		if( ! strlen( cline) > 0) return 0;
	}
	c = cline;

/* to skip space */
	while( *c==' ' || *c=='\t' )  { ++c; };

/* to get a command name */
	*(args++) = c;
	while( *c!=' ' && *c!='\t' && *c!='\n' && *c!= EOF )  {
		c++;
	}
	*(c++) = '\0';  ++n;

/* to skip space */
	while( *c==' ' || *c=='\t' )  { ++c; };

/* to get a slot name */
	*(args++) = c;
	while( *c!=' ' && *c!='\t' && *c!='=' && *c!='<' && *c!='\n' && *c!= EOF )  {
		c++;
	};
	*(c++) = '\0';  ++n;

/* to skip space */
	while( *c==' ' || *c=='\t' )  { ++c; };

/* to get relation */
	*(args++) = c;
	if( *c=='=' || *c=='<' )  {
		c++;
		if( *(c-1)=='<' && *c=='<' )  {
			c++;
		}
		*(c++) = '\0';  ++n;
	}

/* to skip space */
	while( *c==' ' || *c=='\t' )  { ++c; };

/* to get a value */
	*(args++) = c;
	while( *c!='\n' && *c!='\0' && *c!= EOF )  {
		c++;
	};
	*c = '\0';  ++n;

	return n;
}


/*---------------------------------------------------------*/
/*      inq command                                        */
/*---------------------------------------------------------*/

void inqRun()
{
	RepMsg( "rep Run = %s\n", slot_Run );
}

void inqModuleVersion()
{
	RepMsg( "rep ModuleVersion = \"%s\"\n", moduleVersion );
}

void inqProtocolVersion()
{
	RepMsg( "rep ProtocolVersion = \"%s\"\n", protocolVersion );
}

void inqSpeakerSet()
{
	send_speakerset();
}

void inqSpeaker()
{
	send_speaker();
}

void inqSpeechFile()
{
	RepMsg( "rep SpeechFile = %s\n", slot_Speech_file );
}

void inqProsFile()
{
	RepMsg( "rep ProsFile = %s\n", slot_Pros_file );
}

void inqAutoPlay()
{
	if( slot_Auto_play )  {
		RepMsg( "rep AutoPlay = YES\n" );
	} else {
		RepMsg( "rep AutoPlay = NO\n" );
	}
}

void inqAutoPlayDelay()
{
	RepMsg( "rep AutoPlayDelay = \"%d\"\n", slot_Auto_play_delay );
}

void inqTextText()
{
//	send_text( "Text.text" );
	RepMsg( "rep Text.text = %s\n", input_text );
}

void inqTextPho()
{
	send_phonemes( "Text.pho" );
}

void inqTextDur()
{
	send_duration( "Text.dur" );
}

void inqSpeakText()
{
//	send_text( "Speak.text" );
	RepMsg( "rep Speak.text = %s\n", spoken_text );
}

void inqSpeakPho()
{
	send_phonemes( "Speak.pho" );
}

void inqSpeakDur()
{
	send_duration( "Speak.dur" );
}

void inqSpeakUtt()
{
	send_talked_phonemes();
}

void inqSpeakLen()
{
	send_talked_duration();
}

void inqSpeakStat()
{
	RepMsg( "rep Speak.stat = %s\n", slot_Speak_stat );
}

void inqSpeakSyncinterval()
{
	RepMsg( "rep Speak.syncinterval = %d\n", slot_Speak_syncinterval );
}

/*---------------------------------------------------------*/
/*      set command                                        */
/*---------------------------------------------------------*/

void setRun( char *rel, char *val )
{
	if( strcmp(rel,"=")!=0 )  { unknown_com();  return; }

	if( strcmp(val,"EXIT")==0 )  {
		strcpy( slot_Run, "EXIT" );
		if( prop_Run == AutoOutput )  inqRun();
#ifdef WIN32
		Sleep(3000);
#else
		sleep(3);
#endif
		if( s_mode ) {
   		        server_destroy();
		}
		exit(0);
	} else if( s_mode && strcmp(val,"CLOSE")==0 )  {
	        server_close_client();
	} else if( strcmp(val,"LIVE")==0 )  {
		strcpy( slot_Run, "LIVE" );
		if( prop_Run == AutoOutput )  inqRun();
	} else {
		unknown_com();
	}
}

void setSpeaker( char *rel, char *val )
{
	int s;

	if( strcmp(rel,"=")!=0 )  { unknown_com();  return; }

	s = speakerID( val );
	if( s >= 0 )  {
		spid = s;
		if( prop_Speaker == AutoOutput )  inqSpeaker();
	}
}

/* その時に選択されている話者 spid のαをセットする。*/
void setAlpha( char *rel, char *val )
{
	double a;

	if( strcmp(rel,"=")!=0 )  { unknown_com();  return; }

	a = atof( val );
	if( a >= 0.0 )  {
		speaker[spid].alpha = a;
	}
}

/* その時に選択されている話者 spid のポストフィルタ係数をセットする。*/
void setPostfilter_coef( char *rel, char *val)
{
	double a;

	if( strcmp(rel,"=")!=0 )  { unknown_com();  return; }

	a = atof( val );
	if( a >= 0.0 )  {
		speaker[spid].postfilter_coef = a;
	}
}

void setText( char *rel, char *val )
{
	strcpy( slot_Speak_stat, "PROCESSING" );
	if( prop_Speak_stat == AutoOutput )  inqSpeakStat();

	if( strcmp(rel,"=")==0 )  {
		refresh();
		text_analysis( val );	/* テキスト解析 */
		if( prop_Text_text == AutoOutput )  inqTextText();
		if( prop_Speak_text == AutoOutput )  inqSpeakText();

		parameter_generation();	/* パラメータ生成(F0,MLSAフィルタ係数,継続長) */
		do_synthesis();		/* 合成波形の生成 */
#ifdef PRINTDATA
		TmpMsg( "Synthesis Done.\n" );
#endif
/*	} else if( strcmp(rel,"<")==0 )  {
	} else if( strcmp(rel,"<<")==0 )  {
*/		
	} else {
		unknown_com();
	}		
	strcpy( slot_Speak_stat, "READY" );
	if( prop_Speak_stat == AutoOutput )  inqSpeakStat();
}

void setSpeak( char *rel, char *val )
{
	int error;
	long sleep_ms;

	if( strcmp(rel,"=")!=0 )  { unknown_com();  return; }

	if( strcmp(val,"NOW")==0 )  {
		strcpy( slot_Speak_stat, "SPEAKING" );
		if( prop_Speak_stat == AutoOutput )  inqSpeakStat();
		do_output(NULL);	/* 音声出力 */

	} else if( strcmp(val,"STOP")==0 )  {
		abort_output();

	} else {
		/* val = "12:34:56.789" or "+1000" */
		error = make_sleep_time( val, &sleep_ms );
		if( error )  {
			unknown_com();
		} else {
#ifdef PRINTDATA
			TmpMsg( "sleep_ms: %d\n", sleep_ms );
#endif
			if( sleep_ms > 0 ) {
#ifdef WIN32
			        Sleep( sleep_ms );
#else
			        usleep( 1000*sleep_ms );
#endif
			}
			strcpy( slot_Speak_stat, "SPEAKING" );
			if( prop_Speak_stat == AutoOutput )  inqSpeakStat();
			do_output(NULL);	/* 音声出力 */
		}
	}
/*	strcpy( slot_Speak_stat, "IDLE" );
	if( prop_Speak_stat == AutoOutput )  inqSpeakStat();
*/
}

void setSpeakSyncinterval( char *rel, char *val )
{
        int interval;
	
	if( strcmp(rel,"=")!=0 )  { unknown_com();  return; }
	
	interval = atoi( val );

	if( interval >= 0) {
	        slot_Speak_syncinterval = interval;
	        if( prop_Speak_syncinterval == AutoOutput )  inqSpeakSyncinterval();
	}
}

/*-------------------*/

void setSave( char *rel, char *filename )
{
	if( strcmp(rel,"=")==0 )  {
		do_output( filename );
	} else {
		unknown_com();
	}
}

void setSaveWAV( char *rel, char *filename )
{
	if( strcmp(rel,"=")==0 )  {
		do_output_WAVfile( filename );
	} else {
		unknown_com();
	}
}

/* 韻律情報の書き出し */
void setSavePros( char *rel, char *filename )
{
	if( strcmp(rel,"=")==0 )  {
		do_output_pros( filename );
	} else {
		unknown_com();
	}
}

/* 音声データの読み込み */
void setSpeechFile( char *rel, char *filename, SPEECHFILETYPE type )
{
	strcpy( slot_Speak_stat, "PROCESSING" );
	if( prop_Speak_stat == AutoOutput )  inqSpeakStat();

	if( strcmp(rel,"=")==0 )  {
		refresh();
		strcpy( slot_Speech_file, filename );
		if( prop_SpeechFile == AutoOutput )  inqSpeechFile();

		read_speech_file( filename, type );
	
		if( prop_Text_pho == AutoOutput )  inqTextPho();
		if( prop_Speak_pho == AutoOutput )  inqSpeakPho();
		if( prop_Text_dur == AutoOutput )  inqTextDur();
		if( prop_Speak_dur == AutoOutput )  inqSpeakDur();
	} else {
		unknown_com();
	}
	strcpy( slot_Speak_stat, "READY" );
	if( prop_Speak_stat == AutoOutput )  inqSpeakStat();
}

/* 韻律情報の読み込み */
void setProsFile( char *rel, char *filename )
{
	int error;

	strcpy( slot_Speak_stat, "PROCESSING" );
	if( prop_Speak_stat == AutoOutput )  inqSpeakStat();

	if( strcmp(rel,"=")==0 )  {
		strcpy( slot_Pros_file, filename );
		if( prop_ProsFile == AutoOutput )  inqProsFile();

		refresh();
		/* prosBuf に各種パラメータを読み込む */
		error = read_pros_file( filename );
		if( ! error )  {

			text_analysis( input_text );	/* テキスト解析 */
			if( prop_Text_text == AutoOutput )  inqTextText();
			if( prop_Speak_text == AutoOutput )  inqSpeakText();

/*		parameter_generation();		*/

			init_parameter(); /* パラメータ生成の準備 */
			make_duration(); /* 素のテキストから状態継続長を生成 */
			modify_duration(); /* 継続長の修正(タグ処理) */

			/* 音素継続長が修正されている場合は、状態継続長を
			   計算しなおす */
			update_duration();
			
			/* ここで、prosBuf のデータで音素時間長を設定する。 */

			make_cumul_time(); /* 音素時間長の累積を計算 */
			modify_voice(); /* 話者のスイッチ、αパラメータの変更(タグ処理) */

			if( prop_Text_pho == AutoOutput )  inqTextPho();
			if( prop_Speak_pho == AutoOutput )  inqSpeakPho();
			if( prop_Text_dur == AutoOutput )  inqTextDur();
			if( prop_Speak_dur == AutoOutput )  inqSpeakDur();

			make_parameter(); /* パラメータ生成を実行 */

			modify_f0(); /* F0の修正(タグ処理) */
			modify_power(); /* パワーの修正(タグ処理) */

/*		parameter_generation();	 ここまで	*/

			/* 生成されたパラメータに対してF0とc0を更新 */
			error = set_f0_and_power( filename );
			if( ! error )  {
				do_synthesis();		/* 合成波形の生成 */
			}
		}
	} else {
		unknown_com();
	}
	strcpy( slot_Speak_stat, "READY" );
	if( prop_Speak_stat == AutoOutput )  inqSpeakStat();
}

/* 茶筌の結果をファイルから読み込み */
void setParsedText( char *rel, char *filename )
{
	if( strcmp(rel,"=")==0 )  {
		refresh();
		text_analysis_file( filename );	/* テキスト解析 */
		parameter_generation();	/* パラメータ生成(F0,MLSAフィルタ係数,継続長) */
		do_synthesis();		/* 合成波形の生成 */
#ifdef PRINTDATA
		TmpMsg( "Synthesis Done.\n" );
#endif
	} else {
		unknown_com();
	}		
}

void setLog( char *rel, char *filename )
{
	if( strcmp(rel,"=")==0 )  {
		if( logfp && strcmp(slot_Log_file,"CONSOLE")!=0 )  {
			fclose( logfp );
			logfp = NULL;
		}
		strcpy( slot_Log_file, filename );
		if( strcmp(filename,"NO")==0 )  return;
		if( strcmp(filename,"CONSOLE")==0 ) {
			logfp = stderr;
		} else {
			logfp = fopen( filename, "a" );
			if( logfp == NULL )   {
			  ErrMsg( "log file open error ... '%s'\n", filename );
			}
		}
	} else {
		unknown_com();
	}
}

int setLogYesNo( char *rel, char *val )
{
	if( strcmp(rel,"=")==0 )  {
	  if( strcmp( val, "YES" )==0 ) {
		return 1;
	  } else {
		return 0;
	  }
	} else {
		unknown_com();
		return 0;
	}
}

void setErr( char *rel, char *filename )
{
	if( strcmp(rel,"=")==0 )  {
		if( fp_err && strcmp(slot_Err_file,"CONSOLE")!=0 )  fclose( fp_err );
		strcpy( slot_Err_file, filename );
		if( strcmp(filename,"CONSOLE")==0 ) {
			fp_err = stderr;
		} else {
			fp_err = fopen( filename, "a" );
			if( fp_err == NULL )   {
			  ErrMsg( "error log file open error ... '%s'\n", filename );
			}
		}
	} else {
		unknown_com();
	}
}

/*---------------------------------------------------------*/

void parameter_generation()
{
/* 音声合成の初期設定 */
	init_parameter();

/* 音素継続長の決定 */
	make_duration();
/* 音素継続長の変更 */
	modify_duration();
	make_cumul_time();
	modify_voice();

	if( prop_Text_pho == AutoOutput )  inqTextPho();
	if( prop_Speak_pho == AutoOutput )  inqSpeakPho();
	if( prop_Text_dur == AutoOutput )  inqTextDur();
	if( prop_Speak_dur == AutoOutput )  inqSpeakDur();

/* パラメータ生成 F0,MLSAフィルタ係数 */
	make_parameter();

/* F0, ゲイン b(0) の変更 */
	modify_f0();
	modify_power();
}

/*---------------------------------------------------------*/

int 	n_arg;
char	*v_arg[10];

void unknown_com()
{
	int 	i;
	ErrMsg( "* Unknown command line ... \n" );
	for( i=0; i<n_arg; ++i )  { ErrMsg( "%s ", v_arg[i] ); }
	ErrMsg( "\n" );
}

void usage( char* com )
{
	fprintf( stderr, "%s [-v] [-p port-num] [-C conf-file]\n", com );
	fprintf( stderr, "   -v: print version and exit\n" );
	fprintf( stderr, "   -p port-num: to set port number in server mode\n" );
	fprintf( stderr, "   -C conf-gile: to set configuration file\n" );
	exit(1);
}

extern int chasen_process;
static jmp_buf ebuf;

void restart( int val )
{
	RepMsg( "rep Speak.stat = ERROR\n" );
	longjmp( ebuf, val );
	refresh();
}

int main( int argc, char **argv )
{
	int n, i;
	char *com;

	fp_err = stderr;

	init_conf();

	com = argv[0];
	--argc;  ++argv;
	while( argc > 0 && argv[0][0] == '-' )  {
		switch( argv[0][1] )  {
		case 'C':
			if( argc < 2 )  usage( com );
			read_conf( argv[1] );
			--argc;  ++argv;
			break;
		/*******↓for server mode *******/
		case 'p':
   		        /* 引数が不正な場合はエラー出力 */
			if( argc < 2 )  usage( com );
			/* ポート番号の読み込み */
			i = atoi( argv[1] );
			if (i > 1024) {
			        nPort = i;
			}
			s_mode = 1;
			--argc;  ++argv;
			break;
		/*******↑***********************/
		case 'v':
			printf( "%s\n", moduleVersion );
			printf( "%s\n", protocolVersion );
			exit(0);
		default:
			usage( com );
		}
		--argc;  ++argv;
	}
	set_default_conf();

	initialize();

	n = setjmp( ebuf );

	if( n > 0 )  chasen_process = 0;	/* to restart 'chasen' process */

	for( ;; )  {
#ifdef PRINTDATA
		TmpMsg( "> " );
#endif
		n_arg = read_command( v_arg );

#ifdef PRINTDATA
		{
			int i;
			TmpMsg( "command is \n" );
			for( i=0; i<n_arg; ++i )  {
				TmpMsg( "  %d: %s\n", i+1, v_arg[i] );
			}
		}
#endif

		/* 「o」 で set Speak = NOW のショートカット */
		if( strcmp(v_arg[0],"o")==0 )  {
			setSpeak( "=", "NOW" );
			continue;
		}

		if( n_arg < 2 )  { unknown_com();  continue; }

		switch( commandID( v_arg[0] ) )  {
		  case C_set:
			if( n_arg < 4 )  { unknown_com();  break; }
			switch( slotID( v_arg[1] ) )  {
			  case S_Run:   setRun( v_arg[2], v_arg[3] );  break;
			  case S_Speaker:  setSpeaker( v_arg[2], v_arg[3] );  break;
			  case S_Alpha: setAlpha( v_arg[2], v_arg[3] );  break;
			  case S_Postfilter_coef: setPostfilter_coef( v_arg[2], v_arg[3] );  break;
			  case S_Text:  setText( v_arg[2], v_arg[3] );  break;
			  case S_Speak: setSpeak( v_arg[2], v_arg[3] );  break;

			  case S_SaveRAW: setSave( v_arg[2], v_arg[3] );  break;
			  case S_Save:    setSave( v_arg[2], v_arg[3] );  break;
			  case S_LoadRAW: setSpeechFile( v_arg[2], v_arg[3], RAW );  break;
			  case S_SpeechFile: setSpeechFile( v_arg[2], v_arg[3], RAW );  break;
			  case S_SaveWAV: setSaveWAV( v_arg[2], v_arg[3] );  break;
			  case S_LoadWAV: setSpeechFile( v_arg[2], v_arg[3], WAV );  break;

			  case S_SavePros:  setSavePros( v_arg[2], v_arg[3] );  break;
			  case S_LoadPros:  setProsFile( v_arg[2], v_arg[3] );  break;
			  case S_ProsFile:  setProsFile( v_arg[2], v_arg[3] );  break;

			  case S_ParsedText: setParsedText( v_arg[2], v_arg[3] );  break;
			  case S_Speak_syncinterval: setSpeakSyncinterval( v_arg[2], v_arg[3] );  break;
			  case S_AutoPlay: 
				slot_Auto_play = setLogYesNo( v_arg[2], v_arg[3] ); break;
			  case S_AutoPlayDelay: 
				slot_Auto_play_delay = atoi( v_arg[3] ); break;
			  case S_Log:   setLog( v_arg[2], v_arg[3] ); break;
			  case S_Log_conf:
				slot_Log_conf = setLogYesNo( v_arg[2], v_arg[3] ); break;
			  case S_Log_text:
				slot_Log_text = setLogYesNo( v_arg[2], v_arg[3] ); break;
			  case S_Log_arranged_text:
				slot_Log_arranged_text = setLogYesNo( v_arg[2], v_arg[3] ); break;
			  case S_Log_chasen:
				slot_Log_chasen = setLogYesNo( v_arg[2], v_arg[3] ); break;
			  case S_Log_tag:
				slot_Log_tag = setLogYesNo( v_arg[2], v_arg[3] ); break;
			  case S_Log_phoneme:
				slot_Log_phoneme = setLogYesNo( v_arg[2], v_arg[3] ); break;
			  case S_Log_mora:
				slot_Log_mora = setLogYesNo( v_arg[2], v_arg[3] ); break;
			  case S_Log_morph:
				slot_Log_morph = setLogYesNo( v_arg[2], v_arg[3] ); break;
			  case S_Log_aphrase:
				slot_Log_aphrase = setLogYesNo( v_arg[2], v_arg[3] ); break;
			  case S_Log_breath:
				slot_Log_breath = setLogYesNo( v_arg[2], v_arg[3] ); break;
			  case S_Log_sentence:
				slot_Log_sentence = setLogYesNo( v_arg[2], v_arg[3] ); break;
			  case S_Err:          setErr( v_arg[2], v_arg[3] ); break;
			  default:
				unknown_com();
			}
			break;
		  case C_inq:
			switch( slotID( v_arg[1] ) ) {
			  case S_Run:        inqRun();  break;
			  case S_ModuleVersion: inqModuleVersion();  break;
			  case S_ProtocolVersion: inqProtocolVersion();  break;
			  case S_SpeakerSet: inqSpeakerSet();  break;
			  case S_Speaker:    inqSpeaker();  break;
			  case S_SpeechFile: inqSpeechFile();  break;
			  case S_ProsFile:   inqProsFile();  break;
			  case S_AutoPlay:   inqAutoPlay();  break;
			  case S_AutoPlayDelay:   inqAutoPlayDelay();  break;
			  case S_Text_text:  inqTextText();  break;
			  case S_Text_pho:   inqTextPho();  break;
			  case S_Text_dur:   inqTextDur();  break;
			  case S_Speak_text: inqSpeakText();  break;
			  case S_Speak_pho:  inqSpeakPho();  break;
			  case S_Speak_dur:  inqSpeakDur();  break;
			  case S_Speak_utt:  inqSpeakUtt();  break;
			  case S_Speak_len:  inqSpeakLen();  break;
			  case S_Speak_stat: inqSpeakStat();  break;
			  case S_Speak_syncinterval: inqSpeakSyncinterval();  break;
			  case S_Log:
				RepMsg( "rep Log = %s\n", slot_Log_file );  break;
			  case S_Log_conf:
				RepMsg( "rep Log.conf = %s\n", YesNoSlot(S_Log_conf) );  break;
			  case S_Log_text:
				RepMsg( "rep Log.text = %s\n", YesNoSlot(S_Log_text) );  break;
			  case S_Log_arranged_text:
				RepMsg( "rep Log.arranged_text = %s\n", YesNoSlot(S_Log_arranged_text) );  break;
			  case S_Log_chasen:
				RepMsg( "rep Log.chasen = %s\n", YesNoSlot(S_Log_chasen) );  break;
			  case S_Log_tag:
				RepMsg( "rep Log.tag = %s\n", YesNoSlot(S_Log_tag) );  break;
			  case S_Log_phoneme:
				RepMsg( "rep Log.phoneme = %s\n", YesNoSlot(S_Log_phoneme) );  break;
			  case S_Log_mora:
				RepMsg( "rep Log.mora = %s\n", YesNoSlot(S_Log_mora) );  break;
			  case S_Log_morph:
				RepMsg( "rep Log.morph = %s\n", YesNoSlot(S_Log_morph) );  break;
			  case S_Log_aphrase:
				RepMsg( "rep Log.aphrase = %s\n", YesNoSlot(S_Log_aphrase) );  break;
			  case S_Log_breath:
				RepMsg( "rep Log.breath = %s\n", YesNoSlot(S_Log_breath) );  break;
			  case S_Log_sentence:
				RepMsg( "rep Log.sentence = %s\n", YesNoSlot(S_Log_sentence) );  break;
			  case S_Err:
				RepMsg( "rep Err = %s\n", slot_Err_file );  break;
			  default:
				unknown_com();
			}
			break;
		  case C_prop:
			{ SlotProp prop;
			if( strcmp(v_arg[2],"=")!=0 )  { unknown_com(); break; }
			if( strcmp(v_arg[3],"AutoOutput")==0 )  {
				prop = AutoOutput;
			} else if(strcmp(v_arg[3],"NoAutoOutput")==0 )  {
				prop = NoAutoOutput;
			} else {
				unknown_com(); break;
			}
			switch( slotID( v_arg[1] ) ) {
			  case S_Run:        prop_Run = prop;  break;
			  case S_ModuleVersion: prop_ModuleVersion = prop;  break;
			  case S_ProtocolVersion: prop_ProtocolVersion = prop;  break;
			  case S_SpeakerSet: prop_SpeakerSet = prop;  break;
			  case S_Speaker:    prop_Speaker = prop;  break;
			  case S_SpeechFile: prop_SpeechFile = prop;  break;
			  case S_ProsFile:   prop_ProsFile = prop;  break;
			  case S_Text:       prop_Text = prop;  break;
			  case S_Text_text:  prop_Text_text = prop;  break;
			  case S_Text_pho:   prop_Text_pho = prop;  break;
			  case S_Text_dur:   prop_Text_dur = prop;  break;
			  case S_Speak:      prop_Speak = prop;  break;
			  case S_Speak_text: prop_Speak_text = prop;  break;
			  case S_Speak_pho:  prop_Speak_pho = prop;  break;
			  case S_Speak_dur:  prop_Speak_dur = prop;  break;
			  case S_Speak_utt:  prop_Speak_utt = prop;  break;
			  case S_Speak_len:  prop_Speak_len = prop;  break;
			  case S_Speak_stat: prop_Speak_stat = prop;  break;
			  case S_Speak_syncinterval: prop_Speak_syncinterval = prop;  break;
			  default:
				unknown_com();
			}
			}
			break;
		  default:
			unknown_com();
		}
	}
	
	if( s_mode ) {
	        server_destroy ();
	}
	exit(0);
}
