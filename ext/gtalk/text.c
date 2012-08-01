/* Copyright (c) 2000-2006                  */
/*   Yamashita Lab., Ritsumeikan University */
/*   All rights reserved                    */
/*                                          */
/*   add preprocess for numbers reading     */
/*                            by Studio ARC */
/*                             2003.08.10   */
/*               version as of 2003.08.18   */
/* $Id: text.c,v 1.30 2009/02/12 17:43:42 sako Exp $                                     */

#include	<stdio.h>
#include	<stdlib.h>
#include	<string.h>
#include	<ctype.h>
#ifdef WIN32
#include	<io.h>
#endif
#if defined(USE_SPLIB)
#include	<sp/spKanji.h>
#endif
#include	"synthesis.h"
#include	"confpara.h"
#include	"slot.h"
#include	"tag.h"

#ifdef WIN32
#include "strings_sjis.h"
#else
#include "strings_eucjp.h"
#endif

#define MAX_NUM_LEN 32

int TmpMsg(char *,...);
int LogMsg(char *,...);
int ErrMsg(char *,...);
void restart(int);
char *malloc_char( char *, char * );
int make_chasen_process( CHASEN_FD *, CHASEN_FD *);
int chasen_write_line( CHASEN_FD fd_out, char *text );
int chasen_read_line( CHASEN_FD fd, char *buf, int len );
void consult_dic( char *, int );
void arrange_text( char *, char * );
void proc_W1( int, TAGOPTIONS * );
int open_W2( int, TAGOPTIONS * );
void close_W2();
void open_AP( int, TAGOPTIONS * );
void close_AP();
void proc_JEITA_tag( char *, int, TAGOPTIONS *, int );
void make_sil_aphrase( SILENCE );
void print_aphrase();
void make_breath();
void print_breath();
void make_phoneme();
void print_phoneme();
void make_sentence();
void print_sentence();
void print_tag();
void make_mora();
void print_mora();
void print_morph();
int parse_XMLtag( char *, char *, TAGOPTIONS *, int * );

static CHASEN_FD fd_in, fd_out;

void init_text_analysis()
{
	int err;
	input_text[0] = spoken_text[0] = '\0';
	err = make_chasen_process( &fd_in, &fd_out );
	if( err )  exit(1);
}	

void refresh_text_analysis()
{
	input_text[0] = spoken_text[0] = '\0';
}	

#define MAX_CHASEN_LINE 2048  /* 茶筌の結果の一行の最大文字数 */

void make_morph( char *text )
{
	int p, n_op, alone;
	char buf[MAX_CHASEN_LINE], *line, tname[128];
	TAGOPTIONS	options[40];
	int in_PRON_TAG;

	chasen_write_line( fd_out, text );

	in_PRON_TAG = 0;
	p = 0;		/* 先頭から何文字目か */
	if( logfp && slot_Log_chasen )  LogMsg( "* chasen result\n" );
	make_sil_aphrase( SILB );
	while( chasen_read_line( fd_in, buf, sizeof(buf) ) != EOF )  {
		if( logfp && slot_Log_chasen )  LogMsg( "%s\n", buf );

		line = buf;
		while( *line == ' ' || *line == '\t' )  ++line;
		if( *line == '\0' )  continue;

		n_op = parse_XMLtag( line, tname, options, &alone );
/*		printf( "tagname: %s\n", tname );	*/

		if( strcmp(tname,"/S")==0 )  {
			break;
		} else if( strcmp(tname,"S")==0 )  {
			/* do nothing */
		} else if( strcmp(tname,"W1")==0 )  {
			/* donothing */
		} else if( strcmp(tname,"/W1")==0 )  {
			/* donothing */
		} else if( strcmp(tname,"W2")==0 )  {
			/* PRON タグの中は一つの形態素として PRON で処理済 */
			if( ! in_PRON_TAG )  {
				p += open_W2( n_op, options );
			}
		} else if( strcmp(tname,"/W2")==0 )  {
			if( ! in_PRON_TAG )  {
				close_W2();
			}
		} else if( strcmp(tname,"AP")==0 )  {
			open_AP( n_op, options );
		} else if( strcmp(tname,"/AP")==0 )  {
			close_AP();
		} else if( strcmp(tname,"PRON")==0 )  {
			in_PRON_TAG = 1;
			p += open_W2( n_op, options );
		} else if( strcmp(tname,"/PRON")==0 )  {
			close_W2();
			in_PRON_TAG = 0;
		} else {
			proc_JEITA_tag( tname, n_op, options, p );
		}
	}
	/* 「。」か「？」で終わっていないと SILE がついてない。*/
	if( mptail->silence != SILE )  make_sil_aphrase( SILE );
}

void text_analysis( char *text )
{
	char chasen_input[MAX_TEXT_LEN];

	if( logfp && slot_Log_text )  {
		LogMsg( "* text\n" );
		LogMsg( "%s\n", text );
	}
#if defined(USE_SPLIB)
	{
		spKanjiCode ocode;
	    
#if defined(_WIN32) && !defined(__CYGWIN32__)
		ocode = SP_KANJI_CODE_SJIS;
#else
		ocode = SP_KANJI_CODE_EUC;
#endif
		
		spConvertKanjiCode(text, input_text, MAX_TEXT_LEN, SP_KANJI_CODE_UNKNOWN, ocode);
	}
#else
	strcpy( input_text, text );
#endif

	consult_dic( input_text, MAX_TEXT_LEN );

	arrange_text( input_text, chasen_input );

	if( logfp && slot_Log_arranged_text )  {
		LogMsg( "* arranged_text\n" );
		LogMsg( "%s\n", chasen_input );
	}

	/* 形態素解析 */
	make_morph( chasen_input );
	if( logfp && slot_Log_tag )  print_tag();

	/* 読みの修正 */
/*	modify_morph();	*/

	/* モーラデータの作成 */
	make_mora();
	if( logfp && slot_Log_morph )  print_morph();
	if( logfp && slot_Log_mora )  print_mora();

	/* アクセント句の完成 */
/*	make_aphrase();	*/

	/* 呼気段落の作成 */
	make_breath();
	if( logfp && slot_Log_aphrase )  print_aphrase();

	/* 音素系列の決定 */
	make_phoneme();
	if( logfp && slot_Log_phoneme )  print_phoneme();

	/* 文章の作成 */
	make_sentence();
	if( logfp && slot_Log_breath )  print_breath();
	if( logfp && slot_Log_sentence )  print_sentence();
}

/*--------------------------------------------------------------*/
/* 開発用 */

/* ファイルから茶筌の解析結果を読み込む */
void read_morph( char *ifile )
{
	FILE *fp;
	char buf[MAX_TEXT_LEN], *line, tname[128];
	int p, n_op, alone;
	TAGOPTIONS	options[40];

	fp = fopen( ifile, "r" );
	if( fp == NULL )  {
		ErrMsg( "* Can't open ... %s\n", ifile );
		restart( 1 );
	}
	p = 0;		/* 先頭から何文字目か */
	if( logfp && slot_Log_chasen )  LogMsg( "* chasen result\n" );
	make_sil_aphrase( SILB );
	while( fgets( buf, MAX_TEXT_LEN, fp ) != NULL )  {
		if( buf[strlen(buf)-1] == '\n' )  {
			buf[strlen(buf)-1] = '\0';		/* 改行コードを削除 */
		}
        if( logfp && slot_Log_chasen )  LogMsg( "%s\n", buf );

		line = buf;
		while( *line == ' ' || *line == '\t' )  ++line;
		if( *line == '\0' )  continue;

		n_op = parse_XMLtag( line, tname, options, &alone );

		if( strcmp(tname,"/S")==0 )  {
			break;
		} else if( strcmp(tname,"S")==0 )  {
			/* do nothing */
		} else if( strcmp(tname,"W1")==0 )  {
			proc_W1( n_op, options );
		} else if( strcmp(tname,"W2")==0 )  {
			p += open_W2( n_op, options );
		} else if( strcmp(tname,"/W2")==0 )  {
			close_W2();
		} else if( strcmp(tname,"AP")==0 )  {
			open_AP( n_op, options );
		} else if( strcmp(tname,"/AP")==0 )  {
			close_AP();
		} else {
			proc_JEITA_tag( tname, n_op, options, p );
		}
	}
	fclose( fp );

	/* 「。」か「？」で終わっていないと SILE がついてない。*/
	if( mptail->silence != SILE )  make_sil_aphrase( SILE );
}

void text_analysis_file( char *file )
{
	/* 形態素解析結果の読み込み */
	read_morph( file );
	if( logfp && slot_Log_tag )  print_tag();

	/* 読みの修正 */
/*	modify_morph();	*/

	/* モーラデータの作成 */
	make_mora();
	if( logfp && slot_Log_morph )  print_morph();
	if( logfp && slot_Log_mora )  print_mora();

	/* アクセント句の完成 */
/*	make_aphrase();	*/

	/* 呼気段落の作成 */
	make_breath();
	if( logfp && slot_Log_aphrase )  print_aphrase();

	/* 音素系列の決定 */
	make_phoneme();
	if( logfp && slot_Log_phoneme )  print_phoneme();

	/* 文章の作成 */
	make_sentence();
	if( logfp && slot_Log_breath )  print_breath();
	if( logfp && slot_Log_sentence )  print_sentence();
}

/*-------------------------------------------------------------------*/
/*    テキスト前処理                                                 */
/*-------------------------------------------------------------------*/

#define SEN 0

const char *kansuuji[] = {
  KANSUUJI_ZERO, KANSUUJI_ICHI, KANSUUJI_NI, KANSUUJI_SAN, KANSUUJI_SHI,
  KANSUUJI_GO, KANSUUJI_ROKU, KANSUUJI_SHICHI, KANSUUJI_HACHI, KANSUUJI_KYUU,
};

const char *keta[] = {
  KANSUUJI_KETA_ZERO,
  KANSUUJI_KETA_ICHI, KANSUUJI_KETA_JUU, KANSUUJI_KETA_HYAKU, KANSUUJI_KETA_SEN,
  KANSUUJI_KETA_MAN, KANSUUJI_KETA_JUU, KANSUUJI_KETA_HYAKU, KANSUUJI_KETA_SEN,
  KANSUUJI_KETA_OKU, KANSUUJI_KETA_JUU, KANSUUJI_KETA_HYAKU, KANSUUJI_KETA_SEN,
  KANSUUJI_KETA_CHOU, KANSUUJI_KETA_JUU, KANSUUJI_KETA_HYAKU, KANSUUJI_KETA_SEN,
};

void zen2han(char *arb) {
  /* if arb is Zenkaku, trans to Hankaku */
  char	*buf,*p,*ptr;
  buf=(char *)calloc(strlen(arb)+1,sizeof(char));
  for(ptr=arb, p=buf; *ptr!='\0'; *ptr++) {
    if (strncmp(ptr,"！",2)==0) {*p='!';p++;ptr++;}
    else if (strncmp(ptr,ZENKAKU_DOUBLE_QUOTATION,2)==0) {*p='"';p++;ptr++;}
    else if (strncmp(ptr,ZENKAKU_SHARP,2)==0) {*p='#';p++;ptr++;}
    else if (strncmp(ptr,ZENKAKU_DOLLAR,2)==0) {*p='$';p++;ptr++;}
    else if (strncmp(ptr,ZENKAKU_PERCENT,2)==0) {*p='%';p++;ptr++;}
    else if (strncmp(ptr,ZENKAKU_AMPERSAND,2)==0) {*p='&';p++;ptr++;}
    else if (strncmp(ptr,ZENKAKU_QUOTATION,2)==0) {*p='\'';p++;ptr++;}
    else if (strncmp(ptr,ZENKAKU_LEFT_PARENTHESIS,2)==0) {*p='(';p++;ptr++;}
    else if (strncmp(ptr,ZENKAKU_RIGHT_PARENTHESIS,2)==0) {*p=')';p++;ptr++;}
    else if (strncmp(ptr,ZENKAKU_ASTERISK,2)==0) {*p='*';p++;ptr++;}
    else if (strncmp(ptr,ZENKAKU_PLUS,2)==0) {*p='+';p++;ptr++;}
    else if (strncmp(ptr,ZENKAKU_COMMA,2)==0) {*p=',';p++;ptr++;}
    else if (strncmp(ptr,ZENKAKU_CHOUON,2)==0) {*p='-';p++;ptr++;}
    else if (strncmp(ptr,ZENKAKU_PERIOD,2)==0) {*p='.';p++;ptr++;}
    else if (strncmp(ptr,ZENKAKU_SLASH,2)==0) {*p='/';p++;ptr++;}
    else if (strncmp(ptr,ZENKAKU_COLON,2)==0) {*p=':';p++;ptr++;}
    else if (strncmp(ptr,ZENKAKU_SEMICOLON,2)==0) {*p=';';p++;ptr++;}
    else if (strncmp(ptr,ZENKAKU_LT,2)==0) {*p='<';p++;ptr++;}
    else if (strncmp(ptr,ZENKAKU_EQUAL,2)==0) {*p='=';p++;ptr++;}
    else if (strncmp(ptr,ZENKAKU_GT,2)==0) {*p='>';p++;ptr++;}
    else if (strncmp(ptr,ZENKAKU_QUESTION,2)==0) {*p='?';p++;ptr++;}
    else if (strncmp(ptr,ZENKAKU_ATMARK,2)==0) {*p='@';p++;ptr++;}
    else if (strncmp(ptr,ZENKAKU_LEFT_BRACKET,2)==0) {*p='[';p++;ptr++;}
    else if (strncmp(ptr,ZENKAKU_EN,2)==0) {*p='\\';p++;ptr++;}
    else if (strncmp(ptr,ZENKAKU_RIGHT_BRACKET,2)==0) {*p=']';p++;ptr++;}
    else if (strncmp(ptr,ZENKAKU_HAT,2)==0) {*p='^';p++;ptr++;}
    else if (strncmp(ptr,ZENKAKU_UNDERSCORE,2)==0) {*p='_';p++;ptr++;}
    else if (strncmp(ptr,ZENKAKU_BACK_QUOTATION,2)==0) {*p='`';p++;ptr++;}
    else if (strncmp(ptr,ZENKAKU_LEFT_BRACE,2)==0) {*p='{';p++;ptr++;}
    else if (strncmp(ptr,ZENKAKU_VERTICAL_BAR,2)==0) {*p='|';p++;ptr++;}
    else if (strncmp(ptr,ZENKAKU_RIGHT_BRACE,2)==0) {*p='}';p++;ptr++;}
    else if ( *ptr == (char)ZENKAKU_ALPHABET_FIRST_BYTE ) {
      ptr++;
      if ( *ptr >= (char)ZENKAKU_NUMBER_SECOND_BYTE_MIN && *ptr <= (char)ZENKAKU_NUMBER_SECOND_BYTE_MAX ) {
	*p = *ptr - ZENKAKU_NUMBER_SECOND_BYTE_MIN + '0';
	p++;
      } else if ( *ptr >= (char)ZENKAKU_CAPITAL_ALPHABET_SECOND_BYTE_MIN && *ptr <= (char)ZENKAKU_CAPITAL_ALPHABET_SECOND_BYTE_MAX ) {
	*p = *ptr - ZENKAKU_CAPITAL_ALPHABET_SECOND_BYTE_MIN + 'A';
	p++;
      } else if ( *ptr >= (char)ZENKAKU_ALPHABET_SECOND_BYTE_MIN && *ptr <= (char)ZENKAKU_ALPHABET_SECOND_BYTE_MAX ) {
	*p = *ptr - ZENKAKU_ALPHABET_SECOND_BYTE_MIN + 'a';
	p++;
      } else { *p=*ptr; p++; }
    } else { *p=*ptr; p++; }
  }
  strcpy(arb, buf);
  free(buf);
}

void arabic2kansuuji(char *arb, char *knj, int kp) {
  int i, kt1, kt2, num, len, flag, zflag;
  *knj = '\0';
  flag = 0;
  len = strlen(arb);
  if ( kp == 1 ) {
    /* 位取り */
    if ( len < sizeof(keta) / sizeof(keta[0]) ) {
      zflag = 1;
      for ( i=0; i<len; i++ ) {
	num = *(arb+i) - '0'; /* 数字 */
	kt1 = len - i; /* 桁位置 */
	kt2 = kt1 % 4; /* ４桁区切り */
	if ( num && (num > 1 || kt2 == 1 
#if SEN
		     || kt2 == 0
#endif
		     )) {
	  strcat(knj, kansuuji[num]);
	  flag = 1;
	  zflag = 0;
	} else if ( zflag == 1 && num == 0 && kt1 == 1 ) {
	  strcat(knj, kansuuji[num]);
	}
	if (kt1 > 1 && (num || kt2 == 1)) {
	  if (flag || num == 1) {
	    strcat(knj, keta[kt1]);
	    flag = 1;
	    zflag = 0;
	  }
	}
	if (kt2 == 1) flag = 0;
      }
    }
  } else {
    for ( i=0; i<len; i++ ) {
      num = *(arb+i) - '0';
      strcat(knj, kansuuji[num]);
    }
  }
}

void a2k4number (char *cont, char *kcont, char pc, char kc) {
  /* 半角アラビア数字列を位取り読みした全角漢数字列に変換 */
  /* 1234 -> 千二百三十四 */
  /* 位取り区切り記号(kc)は読みとばす */
  /* 1,234 -> 千二百三十四 */
  /* 小数点(pc)を読む */
  /* 12.34 -> 十二．三四 */
  /* 数字以外の入力は読みとばす */
  char *tpt;
  char ktmp[MAX_NUM_LEN*4];
  char ttmp[MAX_NUM_LEN];
  int tcp = 0;
  int fst = 1;
  int p = 0;
  tpt = cont;
  while ( *tpt ) {
    while ( *tpt == kc || *tpt >= '0' && *tpt <= '9' && *tpt != '\0' ) {
      if (*tpt != kc) {
	ttmp[tcp++] = *tpt;
      }
      ++tpt;  if(tpt-cont >= MAX_NUM_LEN-1) break;
    }
    ttmp[tcp] = '\0';
    tcp = 0;
    if ( strcmp(ttmp, "0") == 0 ) { fst = 0; }
    arabic2kansuuji( ttmp, ktmp, fst );
    fst = 0;
    if ( *tpt == pc ) {
      strcat(ktmp, ZENKAKU_PERIOD);
      tpt++;
    } else if (*tpt != '\0') {
      /* 数字以外は読みとばす */
      tpt++;
    }
    strncpy( kcont+p, ktmp, strlen(ktmp) );
    p += strlen(ktmp);
  }
  kcont[p++] = ' ';
  kcont[p] = '\0';
}

void a2k4digit (char *cont, char *kcont) {
  /* 半角アラビア数字列を一文字ずつ全角漢数字列に変換 */
  /* 1234 -> 一二三四 */
  /* 数字以外の入力は読みとばす */
  char *tpt;
  char ktmp[MAX_NUM_LEN*4];
  char ttmp[MAX_NUM_LEN];
  int tcp = 0;
  int p = 0;
  tpt = cont;
  while ( *tpt ) {
    while ( *tpt >= '0' && *tpt <= '9' && *tpt != '\0' ) {
      ttmp[tcp++] = *tpt;
      ++tpt;  if(tpt-cont >= MAX_NUM_LEN-1) break;
    }
    ttmp[tcp] = '\0';
    tcp = 0;
    arabic2kansuuji( ttmp, ktmp, 0 );
    if (*tpt != '\0') {
      /* 数字以外は読みとばす */
      tpt++;
    }
    strncpy( kcont+p, ktmp, strlen(ktmp) );
    p += strlen(ktmp);
  }
  kcont[p++] = ' ';
  kcont[p] = '\0';
}

void a2k4date (char *cont, char *kcont, char *format, char dlm) {
  /* デリミタで区切られた半角アラビア数字列を日付をあらわす全角漢数字列に変換 */
  /* 2003-8-3 -> 二千三年八月三日 */
  /* 与えられた区切り記号(dlm)を用いる */
  /* 2003/8/3 (with delim = '/') */
  /* formatで年(Y)月(M)日(D)の順序を指定 */
  /* 8-3-2003 (with format = "MDY") */
  /* 数字以外の入力は読みとばす */
  /* dateに関して、暫定的な読み付与処理 */
  /* 語形撰択ができるまで */
  /* 対象: 1,2,3,4,5,6,7,8,9,10,20日 */
  char *tpt;
  char ktmp[MAX_NUM_LEN*4];
  char ttmp[MAX_NUM_LEN];
  char ytmp[MAX_NUM_LEN*2+2];
  char mtmp[MAX_NUM_LEN*2+2];
  char dtmp[MAX_NUM_LEN*4+2+30];
  int ord = 0;
  int tcp = 0;
  int p = 0;
  tpt = cont;
  while ( *tpt ) {
    while ( *tpt >= '0' && *tpt <= '9' ) {
      ttmp[tcp++] = *tpt;
      ++tpt;  if(tpt-cont >= MAX_NUM_LEN-1) break;
    }
    if ( *tpt == dlm || *tpt == '\0' ) {
      ttmp[tcp] = '\0';
      tcp = 0;
      if ( *tpt != '\0' ) { tpt++; }
      if ( (int)strlen(format) <= ord ) {
	arabic2kansuuji( ttmp, ktmp, 0 );
      } else if ( format[ord] == 'Y' ) {
	if ( strncmp(ttmp, "0", 1) == 0 ) {
	  arabic2kansuuji( ttmp, ytmp, 0 );
	} else {
	  arabic2kansuuji( ttmp, ytmp, 1 );
	}
	strcat(ytmp, KANJI_TIME_NEN);
      } else if ( format[ord] == 'M' ) {
	arabic2kansuuji( ttmp, mtmp, 1 );
	strcat(mtmp, KANJI_TIME_TSUKI);
      } else if ( format[ord] == 'D' ) {
	int yomi = 1;
	dtmp[0] = '\0';
	if ( strcmp(ttmp, "1") == 0 ||  strcmp(ttmp, "01") == 0 ) {
	  strcat(dtmp, PRON_SYM_TSUITACHI);
	} else if ( strcmp(ttmp, "2") == 0 ||  strcmp(ttmp, "02") == 0 ) {
	  strcat(dtmp, PRON_SYM_FUTSUKA);
	} else if ( strcmp(ttmp, "3") == 0 ||  strcmp(ttmp, "03") == 0 ) {
	  strcat(dtmp, PRON_SYM_MIKKA);
	} else if ( strcmp(ttmp, "4") == 0 ||  strcmp(ttmp, "04") == 0 ) {
	  strcat(dtmp, PRON_SYM_YOKKA);
	} else if ( strcmp(ttmp, "5") == 0 ||  strcmp(ttmp, "05") == 0 ) {
	  strcat(dtmp, PRON_SYM_ITSUKA);
	} else if ( strcmp(ttmp, "6") == 0 ||  strcmp(ttmp, "06") == 0 ) {
	  strcat(dtmp, PRON_SYM_MUIKA);
	} else if ( strcmp(ttmp, "7") == 0 ||  strcmp(ttmp, "07") == 0 ) {
	  strcat(dtmp, PRON_SYM_NANOKA);
	} else if ( strcmp(ttmp, "8") == 0 ||  strcmp(ttmp, "08") == 0 ) {
	  strcat(dtmp, PRON_SYM_YOUKA);
	} else if ( strcmp(ttmp, "9") == 0 ||  strcmp(ttmp, "09") == 0 ) {
	  strcat(dtmp, PRON_SYM_KOKONOKA);
	} else if ( strcmp(ttmp, "10") == 0 ) {
	  strcat(dtmp, PRON_SYM_TOUKA);
	} else if ( strcmp(ttmp, "20") == 0 ) {
	  strcat(dtmp, PRON_SYM_HATSUKA);
	} else {
	  yomi = 0;
	}
	arabic2kansuuji( ttmp, ktmp, 1 );
	strcat(dtmp, ktmp);
	strcat(dtmp, KANJI_TIME_NICHI);
	if ( yomi == 1 ) {
	  strcat(dtmp, "</PRON>");
	}
      }
      ord++;
    } else if (*tpt != '\0') {
      /* 数字以外は読みとばす */
      tpt++;
    }
  }
  strncpy( kcont+p, ytmp, strlen(ytmp) );
  p += strlen(ytmp);
  strncpy( kcont+p, mtmp, strlen(mtmp) );
  p += strlen(mtmp);
  strncpy( kcont+p, dtmp, strlen(dtmp) );
  p += strlen(dtmp);
  kcont[p++] = ' ';
  kcont[p] = '\0';
}

void a2k4time (char *cont, char *kcont, char *format, char dlm) {
  /* デリミタで区切られた半角アラビア数字列を時刻をあらわす全角漢数字列に変換 */
  /* 12:34:56 -> 十二時三十四分五十六秒 */
  /* 与えられた区切り記号(dlm)を用いる */
  /* 12/34/56 (with delim = '/') */
  /* formatで時(h)分(m)秒(s)を指定 */
  /* 12:34 (with format = "hm") */
  /* 数字以外の入力は読みとばす */
  char *tpt;
  char ktmp[MAX_NUM_LEN*4+2];
  char ttmp[MAX_NUM_LEN];
  int ord = 0;
  int tcp = 0;
  int p = 0;
  tpt = cont;
  while ( *tpt ) {
    while ( *tpt >= '0' && *tpt <= '9' ) {
      ttmp[tcp++] = *tpt;
      ++tpt;  if(tpt-cont >= MAX_NUM_LEN-1) break;
    }
    if ( *tpt == dlm || *tpt == '\0' ) {
      ttmp[tcp] = '\0';
      tcp = 0;
      if ( *tpt != '\0' ) { tpt++; }
      if ( (int)strlen(format) <= ord ) {
	arabic2kansuuji( ttmp, ktmp, 0 );
      } else if ( format[ord] == 'h' ) {
	arabic2kansuuji( ttmp, ktmp, 1 );
	strcat(ktmp, KANJI_TIME_JI);
      } else if ( format[ord] == 'm' ) {
	arabic2kansuuji( ttmp, ktmp, 1 );
	strcat(ktmp, KANJI_TIME_FUN);
      } else if ( format[ord] == 's' ) {
	arabic2kansuuji( ttmp, ktmp, 1 );
	strcat(ktmp, KANJI_TIME_BYOU);
      }
      ord++;
      strncpy( kcont+p, ktmp, strlen(ktmp) );
      p += strlen(ktmp);
    } else if (*tpt != '\0') {
      /* 数字以外は読みとばす */
      tpt++;
    }
  }
  kcont[p++] = ' ';
  kcont[p] = '\0';
}

void a2k4phone (char *cont, char *kcont) {
  /* 電話番号をあらわす半角アラビア数字列を一文字ずつ全角漢数字列に変換 */
  /* (123)456-7890 -> 一二三、四五六、七八九〇 */
  /* デリミタは、に変換 */
  /* 数字以外の入力は読みとばす */
  char *tpt;
  char ktmp[MAX_NUM_LEN*4];
  char ttmp[MAX_NUM_LEN];
  int tcp = 0;
  int p = 0;
  tpt = cont;
  if ( *tpt == '(' ) { tpt++; }
  while ( *tpt ) {
    while ( *tpt >= '0' && *tpt <= '9' && *tpt != '\0' ) {
      ttmp[tcp++] = *tpt;
      ++tpt;  if(tpt-cont >= MAX_NUM_LEN-1) break;
    }
    ttmp[tcp] = '\0';
    tcp = 0;
    arabic2kansuuji( ttmp, ktmp, 0 );
    if ( *tpt == '(' || *tpt == ')' || *tpt == '-' ) {
      strcat(ktmp, ZENKAKU_TOUTEN);
      tpt++;  if(tpt-cont >= MAX_NUM_LEN-1) break;
    } else if (*tpt != '\0') {
      /* 数字以外は読みとばす */
      tpt++;
    }
    strncpy( kcont+p, ktmp, strlen(ktmp) );
    p += strlen(ktmp);
  }
  kcont[p++] = ' ';
  kcont[p] = '\0';
}

void spell_process (char *cont, char *kcont) {
  /* 文字列を一文字ずつスペース区切りされた全角文字列に変換 */
  /* ABC -> Ａ Ｂ Ｃ */
  char *tpt;
//  char ktmp[128];
  int p = 0;
  int c = 0;
  tpt = cont;
  while ( *tpt ) {
    if ( *tpt >= '0' && *tpt <= '9' ) {
      kcont[p++] = (char)(ZENKAKU_ALPHABET_FIRST_BYTE);
      kcont[p++] = ZENKAKU_NUMBER_SECOND_BYTE_MIN + *tpt - '0';
      kcont[p++] = ' ';
    } else if( 'A' <= *tpt && *tpt <= 'Z' )  {
      kcont[p++] = (char)(ZENKAKU_ALPHABET_FIRST_BYTE);
      kcont[p++] = ZENKAKU_CAPITAL_ALPHABET_SECOND_BYTE_MIN + *tpt - 'A';
      kcont[p++] = ' ';
    } else if( 'a' <= *tpt && *tpt <= 'z' )  {
      kcont[p++] = (char)(ZENKAKU_ALPHABET_FIRST_BYTE);
      kcont[p++] = ZENKAKU_ALPHABET_SECOND_BYTE_MIN + *tpt - 'a';
      kcont[p++] = ' ';
    } else if( *tpt == '!' )  {
      strncpy( kcont+p, ZENKAKU_EXCLAMATION, 2 );  p += 2;
    } else if( *tpt == '"' )  {
      strncpy( kcont+p, ZENKAKU_DOUBLE_QUOTATION, 2 );  p += 2;
    } else if( *tpt == '#' )  {
      strncpy( kcont+p, ZENKAKU_SHARP, 2 );  p += 2;
    } else if( *tpt == '$' )  {
      strncpy( kcont+p, ZENKAKU_DOLLAR, 2 );  p += 2;
    } else if( *tpt == '%' )  {
      strncpy( kcont+p, ZENKAKU_PERCENT, 2 );  p += 2;
    } else if( *tpt == '&' )  {
      strncpy( kcont+p, ZENKAKU_AMPERSAND, 2 );  p += 2;
    } else if( *tpt == '\'' )  {
      strncpy( kcont+p, ZENKAKU_QUOTATION, 2 );  p += 2;
    } else if( *tpt == '(' )  {
      strncpy( kcont+p, ZENKAKU_LEFT_PARENTHESIS, 2 );  p += 2;
    } else if( *tpt == ')' )  {
      strncpy( kcont+p, ZENKAKU_RIGHT_PARENTHESIS, 2 );  p += 2;
    } else if( *tpt == '*' )  {
      strncpy( kcont+p, ZENKAKU_ASTERISK, 2 );  p += 2;
    } else if( *tpt == '+' )  {
      strncpy( kcont+p, ZENKAKU_PLUS, 2 );  p += 2;
    } else if( *tpt == ',' )  {
      strncpy( kcont+p, ZENKAKU_TOUTEN, 2 );  p += 2;
    } else if( *tpt == '-' )  {
      strncpy( kcont+p, ZENKAKU_MINUS, 2 );  p += 2;
    } else if( *tpt == '.' )  {
      strncpy( kcont+p, ZENKAKU_KUTEN, 2 );  p += 2;
    } else if( *tpt == '/' )  {
      strncpy( kcont+p, ZENKAKU_SLASH, 2 );  p += 2;
    } else if( *tpt == '=' )  {
      strncpy( kcont+p, ZENKAKU_EQUAL, 2 );  p += 2;
    } else if( *tpt == '?' )  {
      strncpy( kcont+p, ZENKAKU_QUESTION, 2 );  p += 2;
    } else if( *tpt == ':' )  {
      strncpy( kcont+p, ZENKAKU_COLON, 2 );  p += 2;
    } else if( *tpt == ';' )  {
      strncpy( kcont+p, ZENKAKU_SEMICOLON, 2 );  p += 2;
    } else {
      kcont[p++] = *(tpt);
      if (c == 0) {
	c++;
      } else {
	c = 0;
	kcont[p++] = ' ';
      }
    }
    ++tpt;
  }
  kcont[p++] = ' ';
  kcont[p] = '\0';
}


void flushnbuf( char *buf, char *kcont, int nmode )
{
  if ( nmode == 1 ) { /* NUMBER mode */
    if ( strcmp(read_number, "DECIMAL") == 0 ) {
      a2k4number(buf, kcont, '.', ',');
    } else {
      a2k4digit(buf, kcont);
    }
  } else if ( nmode == 2 ) { /* DATE mode */
    if ( strcmp(read_date, "NO") == 0 ) {
      if ( strcmp(read_number, "DECIMAL") == 0 ) {
	a2k4number(buf, kcont, '.', '-');
      } else {
	a2k4digit(buf, kcont);
      }
    } else {
      a2k4date(buf, kcont, read_date, '-');
    }
  } else if ( nmode == 3 ) { /* TIME mode */
    if ( strcmp(read_time, "NO") == 0 ) {
      if ( strcmp(read_number, "DECIMAL") == 0 ) {
	a2k4number(buf, kcont, '.', '-');
      } else {
	a2k4digit(buf, kcont);
      }
    } else {
      a2k4time(buf, kcont, read_time, ':');
    }
  } else if ( nmode == 4 ) { /* ALPHABET mode */
    if ( strcmp(read_alphabet, "NO") == 0 ) {
      spell_process(buf, kcont);
    } else {
      strncpy(kcont, buf, strlen(buf));
      kcont[strlen(buf)] = '\0';
    }
  }
}

/* 半角スペースの除去。半角文字を全角文字に変換。*/
/* contextタグに関する前処理 (by Studio ARC 2003.08.03) */
void arrange_text( char *text, char *utterance )
{
	int p, tp, cp, in_context, in_spell;
	char buf[MAX_TEXT_LEN];
	char type[32];
	char format[32];
	char delim[32];
	char cont[64];
	char kcont[128];
//	char tcont[32];
	int nmode = 0;

	p = tp = cp = 0;
	in_context = in_spell = 0;

	while( *text )  {
	  if( *text == '<' )  { /* タグの始まり */
	    /* nmodeの処理 */
	    if ( nmode > 0 ) {
	      buf[tp] = '\0';
	      flushnbuf(buf, kcont, nmode);
	      strncpy( utterance+p, kcont, strlen(kcont) );
	      p += strlen(kcont);
	      nmode = tp = 0;
	    }
	    tp = 0;
	    buf[tp++] = *text;
	    ++text;
	    if ( *text == '/' ) { /* 終了タグの始まり */
	      buf[tp++] = *text;
	      ++text;
	      while ( *text != '>' ) {
		buf[tp++] = *text;
/*		buf[tp++] = toupper( *text );   タグ名は大文字に変換 */
		++text;
	      }
	      buf[tp++] = *text;
	      buf[tp] = '\0';
	      if ( strncmp(buf, "</CONTEXT>", 10) == 0) {
		if ( in_context == 1 ) { /* in_contextの終了処理 */
		  cont[cp] = '\0';
		  zen2han(cont);
		  if ( strcmp(type, "NUMBER") == 0 ) {
		    if ( strcmp(format, "ISO") == 0 ) {
		      a2k4number(cont, kcont, ',', ' ');
		    } else {
		      a2k4number(cont, kcont, '.', ',');
		    }
		    strncpy( utterance+p, kcont, strlen(kcont) );
		    p += strlen(kcont);
		  } else if ( strcmp(type, "DIGITS") == 0 ) {
		    a2k4digit(cont, kcont);
		    strncpy( utterance+p, kcont, strlen(kcont) );
		    p += strlen(kcont);
		  } else if ( strcmp(type, "DATE") == 0 ) {
		    char dlm;
		    if ( strlen(delim) > 0 ) {
		      dlm = delim[0];
		    } else {
		      dlm = '-';
		    }
		    if ( strlen(format) > 0 ) {
		      a2k4date(cont, kcont, format, dlm);
		    } else {
		      a2k4date(cont, kcont, "YMD", dlm);
		    }
		    strncpy( utterance+p, kcont, strlen(kcont) );
		    p += strlen(kcont);
		  } else if ( strcmp(type, "TIME") == 0 ) {
		    char dlm;
		    if ( strlen(delim) > 0 ) {
		      dlm = delim[0];
		    } else {
		      dlm = ':';
		    }
		    if ( strlen(format) > 0 ) {
		      a2k4time(cont, kcont, format, dlm);
		    } else {
		      a2k4time(cont, kcont, "hms", dlm);
		    }
		    strncpy( utterance+p, kcont, strlen(kcont) );
		    p += strlen(kcont);
		  } else if ( strcmp(type, "PHONE") == 0 ) {
		    a2k4phone(cont, kcont);
		    strncpy( utterance+p, kcont, strlen(kcont) );
		    p += strlen(kcont);
		  }
		  tp = cp = 0;
		  in_context = 0;
		} else { /* ERROR: CONTEXT終了タグがあるにもかかわらずin-contextでない */
		  strncpy( utterance+p, buf, strlen(buf) );
		  p += strlen(buf);
		  tp = cp = 0;
		}
	      } else if ( strncmp(buf, "</SPELL>", 8) == 0) {
		if ( in_spell == 1 ) { /* in_spellの終了処理 */
		  cont[cp] = '\0';
		  spell_process(cont, kcont);
		  strncpy( utterance+p, kcont, strlen(kcont) );
		  p += strlen(kcont);
		  in_spell = 0;
		} else { /* ERROR: SPELL終了タグがあるにもかかわらずin-spellでない */
		  strncpy( utterance+p, buf, strlen(buf) );
		  p += strlen(buf);
		  tp = cp = 0;
		}
	      } else { /* CONTEXT, SPELL以外の終了タグの処理 */
		strncpy( utterance+p, buf, strlen(buf) );
		p += strlen(buf);
		tp = cp = 0;
	      }
	    } else { /* 開始タグの始まり */
	      while ( *text != '>' ) {
		buf[tp++] = *text;
/*		buf[tp++] = toupper( *text );   大文字に変換 */
		++text;
	      }
	      buf[tp++] = *text;
	      buf[tp] = '\0';
	      if ( strncmp(buf, "<CONTEXT", 8) == 0) {
		type[0] = '\0';
		format[0] = '\0';
		delim[0] = '\0';
		if ( strstr(buf, "TYPE=\"") != NULL ) {
		  char *pb;
		  pb = strstr(buf, "TYPE=\"");
		  pb = pb + 6;
		  while (*pb != '"') {
		    type[cp++] = *pb;
		    ++pb;
		  }
		  type[cp] = '\0';
		  cp = 0;
		  in_context = 1;
		} else {
		  strncpy( utterance+p, buf, strlen(buf) );
		  p += strlen(buf);
		  tp = cp = 0;
		}
		if ( strstr(buf, "FORMAT=\"") != NULL ) {
		  char *pb;
		  pb = strstr(buf, "FORMAT=\"");
		  pb = pb + 8;
		  while (*pb != '"') {
		    format[cp++] = *pb;
		    ++pb;
		  }
		  format[cp] = '\0';
		  cp = 0;
		}
		if ( strstr(buf, "DELIM=\"") != NULL ) {
		  char *pb;
		  pb = strstr(buf, "DELIM=\"");
		  pb = pb + 7;
		  while (*pb != '"') {
		    delim[cp++] = *pb;
		    ++pb;
		  }
		  delim[cp] = '\0';
		  cp = 0;
		}
	      } else if ( strncmp(buf, "<SPELL", 6) == 0) { /* SPELLタグ */
		tp = cp = 0;
		in_spell = 1;
	      } else { /* CONTEXT, SPELL以外の開始タグ */
		strncpy( utterance+p, buf, strlen(buf) );
		p += strlen(buf);
		tp = cp = 0;
	      }
	    }
	  } else if ( in_context == 1 || in_spell == 1) { /* context, spellのコンテント */
	    cont[cp++] = *text;
	  } else if (strncmp(text,ZENKAKU_PERIOD,2)==0) {
	    if ( nmode == 4 ) {
	      buf[tp] = '\0';
	      flushnbuf(buf, kcont, nmode);
	      strncpy( utterance+p, kcont, strlen(kcont) );
	      p += strlen(kcont);
	      nmode = tp = 0;
	    }
	    if ( nmode == 1 ) {
	      buf[tp++] = '.';
	    } else {
	      strncpy( utterance+p, ZENKAKU_PERIOD, 2 );  p += 2;
	    }
	    text++;
	  } else if (strncmp(text,ZENKAKU_MINUS,2)==0) {
	    if ( nmode == 4 ) {
	      buf[tp] = '\0';
	      flushnbuf(buf, kcont, nmode);
	      strncpy( utterance+p, kcont, strlen(kcont) );
	      p += strlen(kcont);
	      nmode = tp = 0;
	    }
	    if ( nmode == 1 || nmode == 2 ) {
	      buf[tp++] = '-';
	    } else {
	      strncpy( utterance+p, ZENKAKU_MINUS, 2 );  p += 2;
	    }
	    text++;
	  } else if (strncmp(text,ZENKAKU_COLON,2)==0) {
	    if ( nmode == 4 ) {
	      buf[tp] = '\0';
	      flushnbuf(buf, kcont, nmode);
	      strncpy( utterance+p, kcont, strlen(kcont) );
	      p += strlen(kcont);
	      nmode = tp = 0;
	    }
	    if ( nmode == 1 || nmode == 3 ) {
	      buf[tp++] = ':';
	    } else {
	      strncpy( utterance+p, ZENKAKU_COLON, 2 );  p += 2;
	    }
	    text++;
	  } else if ( *text == '.' )  {
	    if ( nmode == 4 ) {
	      buf[tp] = '\0';
	      flushnbuf(buf, kcont, nmode);
	      strncpy( utterance+p, kcont, strlen(kcont) );
	      p += strlen(kcont);
	      nmode = tp = 0;
	    }
	    if ( nmode == 1 ) {
	      buf[tp++] = *text;
	    } else {
	      strncpy( utterance+p, ZENKAKU_KUTEN, 2 );  p += 2;
	    }
	  } else if ( *text == '-' )  {
	    if ( nmode == 4 ) {
	      buf[tp] = '\0';
	      flushnbuf(buf, kcont, nmode);
	      strncpy( utterance+p, kcont, strlen(kcont) );
	      p += strlen(kcont);
	      nmode = tp = 0;
	    }
	    if ( nmode == 1 || nmode == 2 ) {
	      buf[tp++] = *text;
	      nmode = 2;
	    } else {
	      strncpy( utterance+p, ZENKAKU_MINUS, 2 );  p += 2;
	    }
	  } else if ( *text == ':' )  {
	    if ( nmode == 4 ) {
	      buf[tp] = '\0';
	      flushnbuf(buf, kcont, nmode);
	      strncpy( utterance+p, kcont, strlen(kcont) );
	      p += strlen(kcont);
	      nmode = tp = 0;
	    }
	    if ( nmode == 1 || nmode == 3 ) {
	      buf[tp++] = *text;
	      nmode = 3;
	    } else {
	      strncpy( utterance+p, ZENKAKU_COLON, 2 );  p += 2;
	    }
	    /*	  } else if ( *text == (char)ZENKAKU_ALPHABET_FIRST_BYTE ) { */
	  } else if( is_ZENKAKU_ALPNUM( *text, *(text+1))){
	    text++;
	    if ( *text >= (char)ZENKAKU_NUMBER_SECOND_BYTE_MIN && *text <= (char)ZENKAKU_NUMBER_SECOND_BYTE_MAX ) {
	      char han;
	      han = *text - ZENKAKU_NUMBER_SECOND_BYTE_MIN + '0';
	      if ( nmode == 4 ) {
		buf[tp] = '\0';
		flushnbuf(buf, kcont, nmode);
		strncpy( utterance+p, kcont, strlen(kcont) );
		p += strlen(kcont);
		nmode = tp = 0;
	      }
	      buf[tp++] = han;
	      if ( nmode == 0 ) { nmode = 1; }
	    } else if ( *text >= (char)ZENKAKU_CAPITAL_ALPHABET_SECOND_BYTE_MIN && *text <= (char)ZENKAKU_CAPITAL_ALPHABET_SECOND_BYTE_MAX ) {
	      if ( nmode > 0 && nmode < 4 ) {
		buf[tp] = '\0';
		flushnbuf(buf, kcont, nmode);
		strncpy( utterance+p, kcont, strlen(kcont) );
		p += strlen(kcont);
		nmode = tp = 0;
	      }
	      buf[tp++] = (char)ZENKAKU_ALPHABET_FIRST_BYTE;
	      buf[tp++] = *text;
	      if ( nmode == 0 ) { nmode = 4; }
	    } else if ( *text >= (char)ZENKAKU_ALPHABET_SECOND_BYTE_MIN && *text <= (char)ZENKAKU_ALPHABET_SECOND_BYTE_MAX ) {
	      if ( nmode > 0 && nmode < 4 ) {
		buf[tp] = '\0';
		flushnbuf(buf, kcont, nmode);
		strncpy( utterance+p, kcont, strlen(kcont) );
		p += strlen(kcont);
		nmode = tp = 0;
	      }
	      buf[tp++] = (char)ZENKAKU_ALPHABET_FIRST_BYTE;
	      buf[tp++] = *text;
	      if ( nmode == 0 ) { nmode = 4; }
	    } else {
	      utterance[p++] = (char)ZENKAKU_ALPHABET_FIRST_BYTE;
	      //text--;
	      utterance[p++] = *(text);
	    }
	  } else if (
#ifdef WIN32
		     ( *text >= (char)0x81 && *text <= (char)0x9f )
		     || ( *text >= (char)0xe0 && *text <= (char)0xfc )
#else
		     *text >= (char)0xa1 && *text <= (char)0xf4
#endif
		     ) {
	    /* 2バイト文字 */
	    if ( nmode > 0 ) {
	      buf[tp] = '\0';
	      flushnbuf(buf, kcont, nmode);
	      /* 「人」の前のspaceはとる */
	      if (
#ifdef WIN32
		  *text == (char)0x90 && *(text + 1) == (char)0x6c
#else
		  *text == (char)0xbf && *(text + 1) == (char)0xcd
#endif
		  ) {
		kcont[strlen(kcont) - 1] = '\0';
	      }
	      strncpy( utterance+p, kcont, strlen(kcont) );
	      p += strlen(kcont);
	      nmode = tp = 0;
 	    }
	    if (
#ifdef WIN32
		*text == (char)0x81 && *( text + 1 ) == (char)0x40
#else
		*text == (char)0xa1 && *( text + 1 ) == (char)0xa1
#endif
		) {
	      // 全角スペースの除去
	      text++;
	    } else {
	      utterance[p++] = *text++;
	      utterance[p++] = *text;
	    }
	  } else if ( '0' <= *text && *text <= '9' ) {
	    if ( nmode == 4 ) {
	      buf[tp] = '\0';
	      flushnbuf(buf, kcont, nmode);
	      strncpy( utterance+p, kcont, strlen(kcont) );
	      p += strlen(kcont);
	      nmode = tp = 0;
	    }
	    buf[tp++] = *text;
	    if ( nmode == 0 ) { nmode = 1; }
	  } else if ( 'A' <= *text && *text <= 'Z' )  {
	    if ( nmode > 0 && nmode < 4 ) {
	      buf[tp] = '\0';
	      flushnbuf(buf, kcont, nmode);
	      strncpy( utterance+p, kcont, strlen(kcont) );
	      p += strlen(kcont);
	      nmode = tp = 0;
	    }
	    buf[tp++] = (char)(ZENKAKU_ALPHABET_FIRST_BYTE);
	    buf[tp++] = ZENKAKU_CAPITAL_ALPHABET_SECOND_BYTE_MIN + *text - 'A';
	    if ( nmode == 0 ) { nmode = 4; }
	  } else if ( 'a' <= *text && *text <= 'z' )  {
	    if ( nmode > 0 && nmode < 4 ) {
	      buf[tp] = '\0';
	      flushnbuf(buf, kcont, nmode);
	      strncpy( utterance+p, kcont, strlen(kcont) );
	      p += strlen(kcont);
	      nmode = tp = 0;
	    }
	    buf[tp++] = (char)(ZENKAKU_ALPHABET_FIRST_BYTE);
	    buf[tp++] = ZENKAKU_ALPHABET_SECOND_BYTE_MIN + *text - 'a';
	    if ( nmode == 0 ) { nmode = 4; }
	  } else {
	    if ( nmode > 0 ) {
	      buf[tp] = '\0';
	      flushnbuf(buf, kcont, nmode);
	      strncpy( utterance+p, kcont, strlen(kcont) );
	      p += strlen(kcont);
	      nmode = tp = 0;
	    }
	    if ( *text == '!' )  {
	      strncpy( utterance+p, ZENKAKU_EXCLAMATION, 2 );  p += 2;
	    } else if ( *text == '"' )  {
	      strncpy( utterance+p, ZENKAKU_DOUBLE_QUOTATION, 2 );  p += 2;
	    } else if ( *text == '#' )  {
	      strncpy( utterance+p, ZENKAKU_SHARP, 2 );  p += 2;
	    } else if ( *text == '$' )  {
	      strncpy( utterance+p, ZENKAKU_DOLLAR, 2 );  p += 2;
	    } else if ( *text == '%' )  {
	      strncpy( utterance+p, ZENKAKU_PERCENT, 2 );  p += 2;
	    } else if ( *text == '&' )  {
	      strncpy( utterance+p, ZENKAKU_AMPERSAND, 2 );  p += 2;
	    } else if ( *text == '\'' )  {
	      strncpy( utterance+p, ZENKAKU_QUOTATION, 2 );  p += 2;
	    } else if ( *text == '(' )  {
	      strncpy( utterance+p, ZENKAKU_LEFT_PARENTHESIS, 2 );  p += 2;
	    } else if ( *text == ')' )  {
	      strncpy( utterance+p, ZENKAKU_RIGHT_PARENTHESIS, 2 );  p += 2;
	    } else if ( *text == '*' )  {
	      strncpy( utterance+p, ZENKAKU_ASTERISK, 2 );  p += 2;
	    } else if ( *text == '+' )  {
	      strncpy( utterance+p, ZENKAKU_PLUS, 2 );  p += 2;
	    } else if ( *text == ',' )  {
	      strncpy( utterance+p, ZENKAKU_TOUTEN, 2 );  p += 2;
	    } else if ( *text == '/' )  {
	      strncpy( utterance+p, ZENKAKU_SLASH, 2 );  p += 2;
	    } else if ( *text == '=' )  {
	      strncpy( utterance+p, ZENKAKU_EQUAL, 2 );  p += 2;
	    } else if ( *text == '?' )  {
	      strncpy( utterance+p, ZENKAKU_QUESTION, 2 );  p += 2;
	    } else if ( *text == ';' )  {
	      strncpy( utterance+p, ZENKAKU_SEMICOLON, 2 );  p += 2;
//	      /* スペースは読み飛ばす。タグの適用範囲を文字数で決めるため。 */
//	    } else if ( *text == ' ' )  {
	      /* その他の文字はそのままコピー */
	    } else {
	      utterance[p++] = *(text);
	    }
	  }
	  ++text;
	} /* while文のおわり */
	if ( nmode > 0 ) {
	  buf[tp] = '\0';
	  flushnbuf(buf, kcont, nmode);
	  strncpy( utterance+p, kcont, strlen(kcont) );
	  p += strlen(kcont);
	  nmode = tp = 0;
	}
	utterance[p] = '\0';
}

