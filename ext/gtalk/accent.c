/* Copyright (c) 2000-2006                  */
/*   Yamashita Lab., Ritsumeikan University */
/*   All rights reserved                    */
/*                                          */
/* $Id: accent.c,v 1.18 2006/10/19 03:27:08 sako Exp $                                     */

#include	<stdio.h>
#include	<stdlib.h>
#include	<string.h>
#include	"synthesis.h"

#define	INIT_ACON_DATA_TABLE
#include	"accent.h"

#ifdef WIN32
#include "strings_sjis.h"
#else
#include "strings_eucjp.h"
#endif

int TmpMsg(char *,...);
int ErrMsg(char *,...);
void restart(int);

/* アクセント結合型のID */
int getAccentFormID( char *aform )
{
	int 	i;
	for( i=0; i<NUM_AFORM; ++i )  {
		if( strcmp(aform,aformTable[i].name)==0 )  return aformTable[i].id;
	}
	return -1;
}

/* 結合型IDを様式名称 (F1 など) に変換する。*/
char * aformName( int acID )
{
	int 	i;
	if( acID == -1 )  return "-";		/* silB, silE など */
	for( i=0; i<NUM_AFORM; ++i )  {
		if( acID == aformTable[i].id )  return aformTable[i].name;
	}
	ErrMsg( "Unknown Accent Ketsugou ID ... '%d'\n", acID );
/*	restart( 1 );	*/
	return NULL;
}

int isNumber( char c )
{
	if( c == '-' )  return (1);
	if( c >= '0' && c <= '9' )  return(1);
	return( 0 );
}

int isNumberStr( char *str )
{
	while( *str )  {
		if( ! isNumber( *str ) )  return( 0 );
		++str;
	}
	return( 1 );
}

/* 文字列 p からデリミタ(あるいはNULL)までの文字を token に入れ、
次の場所を返す */
static char *get_token( char *p, char *token, char del )
{
	if( *p == '\0' || p == NULL )  return NULL;

/*	while( *p != del && *p != '\0' )  {	*/

	while( 1 )  {
		if( *p == '\0' )  break;
		if( *p == del )  {
			if( del != ',' )  {
				break;
			} else {
			/*  形容詞%F6@0,-2 などの処理 */
				if( ! isNumber( *(p+1) )  )  break;
			}
		}

		*(token++) = *(p++);
	}
	*token = '\0';
	if( *p != '\0' )  ++p;
	return p;
}


#define MAX_TOKENSTR 2048
static char tokenStr[MAX_TOKENSTR];
static char *tokenPos;

/* トークンを含む文字列をセットする。*/
static void setTokenStr( char *str )
{
	if( strlen(str)+1 > MAX_TOKENSTR )  {
		ErrMsg( "Too long string in setTokenStr()\n" );
		return;
	}
	strcpy( tokenStr, str );
	tokenPos = tokenStr;
}

static int isDelimiter( char c )
{
	if( c == '%' || c == '@' || c == ',' || c == '\0' )  {
		return( 1 );
	} else {
		return( 0 );
	}
}

/* トークンがあれば１、なくなれば０を返す。*/
static int getToken( char *token )
{
	if( *tokenPos == '\0' )  return( 0 );

	if( isDelimiter( *tokenPos ) )  {
		*(token++) = *(tokenPos++);
		*token = '\0';
		return( 1 );
	}

	for( ;; )  {
		*(token++) = *(tokenPos++);
		if( isDelimiter( *tokenPos ) )  {
			*token = '\0';
			return( 1 );
		}
	}
}	

/* アクセント接続情報
	動詞%F5,名詞%F1,形容詞%F6@0,-2
などから、必要な情報を取り出す。*/

void parse_aConType( char *acon_str, MORPH *morph )
{
	char token[128];
	enum {POS,ACON,NUM,NON} pre_token_type;
	char pre_del_type;
	int i, ctype_pos, afID;

	setTokenStr( acon_str );

	i = -1;		/* アクセント結合情報の数 */
	ctype_pos = 1;
	pre_token_type = NON;
	pre_del_type = ' ';

	while( getToken( token ) )  {
		if( strcmp(token,TOKEN_MEISHI)==0 || strcmp(token,TOKEN_DOUSHI)==0
				|| strcmp(token,TOKEN_KEIYOUSHI)==0 )  {
			++i;
			if( strcmp(token,TOKEN_MEISHI)==0 )  {
				morph->accent[i].prepos = 'N';
			} else if( strcmp(token,TOKEN_DOUSHI)==0 )  {
				morph->accent[i].prepos = 'V';
			} else if( strcmp(token,TOKEN_KEIYOUSHI)==0 )  {
				morph->accent[i].prepos = 'A';
			}
			pre_token_type = POS;
			morph->accent[i].ctype  = -999;
			morph->accent[i].ctype2 = -999;

		} else if( strcmp(token,"%")==0 )  {
			if( pre_token_type != POS )  {
				ErrMsg( "* irregal aConType ...\n%s\n", acon_str );
			}
			pre_del_type = '%';

		} else if( strcmp(token,"@")==0 )  {
			if( pre_token_type != ACON )  {
				ErrMsg( "* irregal aConType ...\n%s\n", acon_str );
			}
			pre_del_type = '@';

		} else if( strcmp(token,",")==0 )  {
			pre_del_type = ',';

		} else if( (afID = getAccentFormID(token)) >= 0 )  {
			if( pre_token_type == NON )  ++i;
			if( pre_token_type != POS )  {
				morph->accent[i].prepos = '*';
				morph->accent[i].ctype  = -999;
				morph->accent[i].ctype2 = -999;
			}
			morph->accent[i].form = afID;
			ctype_pos = 1;
			pre_token_type = ACON;

		} else if( isNumberStr(token) )  {
			if( ctype_pos == 1 )  {
				if( pre_token_type != ACON )  {
					ErrMsg( "* irregal aConType ...\n%s\n", acon_str );
				}
				morph->accent[i].ctype = atoi( token );
				ctype_pos = 2;
			} else {
				if( pre_token_type != NUM )  {
					ErrMsg( "* irregal aConType ...\n%s\n", acon_str );
				}
				morph->accent[i].ctype2 = atoi( token );
			}
			pre_token_type = NUM;
			
		} else {
			ErrMsg( "* Unknown token ... '%s' in %s\n", token, acon_str );
		}
	}
	morph->n_accent = i+1;
}

