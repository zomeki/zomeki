/* Copyright (c) 2000-2006                  */
/*   Yamashita Lab., Ritsumeikan University */
/*   All rights reserved                    */
/*                                          */
/* $Id: make_mora.c,v 1.19 2006/10/19 03:27:08 sako Exp $                                     */

#include	<stdio.h>
#include	<stdlib.h>
#include	<string.h>
#include	"synthesis.h"
#include	"pos.h"

#ifdef WIN32
#include "strings_sjis.h"
#else
#include "strings_eucjp.h"
#endif

int LogMsg(char *,...);
int ErrMsg(char *,...);
void restart(int);
char *malloc_char( char *, char * );

/* 最初に一度だけ */
void init_mora()
{
	mrhead = mrtail = NULL;
}

/* 入力文ごとに */
/* 使っているモーラのセルの開放 */
void refresh_mora()
{
	MORA *mora, *next;

	mora = mrhead;
	while( mora )  {
		next = mora->next;
		free( mora->yomi );
		free( mora );
		mora = next;
	}
	mrhead = mrtail = NULL;
}

MORA *new_mora()
{
	MORA *mora;

	mora = (MORA*) malloc( sizeof(MORA) );
	if( ! mora )  {
		ErrMsg( "* malloc error for 'mora'\n" );
		restart(1);
	}

/* 作ったモーラセルをチェーンの中に入れる */
	if( mrhead == NULL )  {
		/* 一つめのセル */
		mrhead = mrtail = mora;
		mora->prev = mora->next = NULL;
	} else {
		/* tail の後ろに追加 */
		mrtail->next = mora;
		mora->prev = mrtail;
		mora->next = NULL;
		mrtail = mora;
	}
	mora->parent = NULL;

	mora->yomi = NULL;
	mora->position = -1;
	mora->acdist = -1;
	mora->chouonka = NO;
	mora->silence = NON;
	mora->phead = mora->ptail = NULL;

	return mora;
}

/* 仮名表記からモーラのデータを作り、モーラ数を返す */
int make_mora_data( MORPH *morph, char *yomi )
{
	int 	hinshi, nmora, len;
	short 	c1, c2;
	MORA	*mora=NULL;
	char	*p;
	APHRASE *ap;

	ap = morph->parent;
	hinshi = morph->hinshiID;

/* カタカナで書かれているかどうかチェックしておく */
	p = yomi;
	while( *p )  {
		if( strcmp(KUTEN,p)==0 )  break;
		if( strcmp(TOUTEN,p)==0 )  break;
		if( strcmp(GIMONFU,p)==0 )  break;

		/* カタカナでなければエラー。 0xA1,0xBC は「ー」*/
		c1 = (*p)&0xFF;
		c2 = (*(p+1))&0xFF;
		if(
#ifdef WIN32
		   !( c1==0x83 && (c2>=0x3f && c2<=0x96) ) &&
		   !( c1==0x81 && c2==0x5b )
#else
		   !( c1==0xA5 && (c2>=0xA1 && c2<=0xF6) ) &&
		   !( c1==0xA1 && c2==0xBC )
#endif
		    )  {
			ErrMsg( "* yomi is NOT katakana ... %s (%x,%x)\n", 
				yomi, c1, c2 );
			return 0;
		}
		p += 2;
	}

	nmora = 0;
	while( *yomi )  {
		mora = new_mora();
		mora->parent = morph;
		if( nmora == 0 )  morph->mrhead = mora;

		++(ap->nmora);
		mora->position = ap->nmora;	/* アクセント句中でのモーラ位置 */
		/* アクセント句中でのアクセント核からの相対位置 */
		mora->acdist = ap->nmora - ap->accentType;

		p = yomi+2;
		if( strncmp(KATAKANA_SMALL_A,p,2)==0 ||
			strncmp(KATAKANA_SMALL_I,p,2)==0 ||
			strncmp(KATAKANA_SMALL_U,p,2)==0 ||
			strncmp(KATAKANA_SMALL_E,p,2)==0 ||
			strncmp(KATAKANA_SMALL_O,p,2)==0 ||
			strncmp(KATAKANA_SMALL_YA,p,2)==0 ||
			strncmp(KATAKANA_SMALL_YU,p,2)==0 ||
			strncmp(KATAKANA_SMALL_YO,p,2)==0 )  {
				len = 4;
		} else {
				len = 2;
		}

		mora->yomi = (char *) malloc( sizeof(char) * (len+1) );
		if( ! mora->yomi )  {
			ErrMsg( "* malloc error for 'mora.yomi'\n" );
			restart(1);
		}
		memcpy( mora->yomi, yomi, len );
		mora->yomi[len] = '\0';

		if( strcmp(mora->yomi,ZENKAKU_CHOUON)==0 )  mora->chouonka = YES;
		++nmora;
		yomi += len;
	}
	morph->mrtail = mora;

	return nmora;
}

void make_silence_mora( MORPH *morph )
{
	MORA *mora;

	/* 、の後の 「 や 、の前の 」 では、ポーズを作らない。*/
	if( morph->hinshiID == H_SONOTA_KAKKO_HIRAKU &&   /* 「 など */
		morph->prev && morph->prev->silence != NON )  return;
	if( morph->hinshiID == H_SONOTA_KAKKO_TOJIRU &&	/* 」など */
		morph->next && morph->next->silence != NON )  return;

	mora = new_mora();

	if( morph->silence == PAU )  {
		mora->yomi = malloc_char( "pau", "mora.yomi of SILENCE" );
	} else if( morph->silence == SILB )  {
		mora->yomi = malloc_char( "silB", "mora.yomi of SILENCE" );
	} else if( morph->silence == SILE )  {
		mora->yomi = malloc_char( "silE", "mora.yomi of SILENCE" );
	} else {
		ErrMsg( "* Unknown silence in make_silence_mora\n" );
		mora->yomi = malloc_char( "pau", "mora.yomi of SILENCE" );
/*		restart(1);	*/
	}
	mora->parent = morph;
	morph->mrhead = morph->mrtail = mora;
	mora->silence = morph->silence;

	  	/* ++(morph->parent->nmora); サイレンスはモーラ数をカウントしない */
}

void make_mora()
{
	MORPH *morph;

	for( morph=mphead; morph; morph=morph->next )  {
		if( morph->silence == NON )  {
			morph->nmora = make_mora_data( morph, morph->pron );
			if( morph->nmora == 0 )  {
				morph->silence = PAU;
				make_silence_mora( morph );
			}
		} else {
			make_silence_mora( morph );
			morph->nmora = 0;	/* ポーズ、無音のモーラ数は 0 に */
		}
	}
}

void print_mora()
{
	MORA *mora;

	LogMsg( "* mora data\n" );
	for( mora=mrhead; mora; mora=mora->next )  {
		LogMsg( "%s", mora->yomi );
		if( mora->devoiced == YES )  LogMsg( "*" );
/*		if( mora->silence == SILB )  LogMsg( "SB" );
		if( mora->silence == SILE )  LogMsg( "SE" );
		if( mora->silence == PAU )  LogMsg( "P" );
*/
		LogMsg( " " );
	}
	LogMsg( "\n" );
}
