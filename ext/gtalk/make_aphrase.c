/* Copyright (c) 2000-2006                  */
/*   Yamashita Lab., Ritsumeikan University */
/*   All rights reserved                    */
/*                                          */
/* $Id: make_aphrase.c,v 1.21 2006/10/19 03:27:08 sako Exp $                                     */

#include	<stdio.h>
#include	<stdlib.h>
#include	<string.h>
#include	"synthesis.h"
#include	"accent.h"
#include	"tag.h"

int TmpMsg(char *,...);
int LogMsg(char *,...);
int ErrMsg(char *,...);
void restart(int);
void print_aphrase_kanji(APHRASE *);
void print_aphrase_yomi(APHRASE *);
void print_morph_yomi(MORPH *);
int attributeID(char *);
void make_sil_aphrase( SILENCE );
void make_sil_morph( SILENCE );

/* 最初に一度だけ */
void init_aphrase()
{
	ahead = atail = NULL;
}

/* 入力文ごとに */
/* 使っているアクセント句のセルの開放 */
void refresh_aphrase()
{
	APHRASE *aphrase, *next;

	aphrase = ahead;
	while( aphrase )  {
		next = aphrase->next;
		free( aphrase );
		aphrase = next;
	}
	ahead = atail = NULL;
}

APHRASE *new_aphrase()
{
	APHRASE	*aphrase;

	aphrase = (APHRASE *) malloc( sizeof(APHRASE) );
	if( ! aphrase )  {
		ErrMsg( "* malloc error for 'aphrase'\n" );
		restart(1);
	}
/* 作ったアクセント句セルをチェーンの中に入れる */
	if( ahead == NULL )  {
		/* 一つめのセル */
		ahead = atail = aphrase;
		aphrase->prev = aphrase->next = NULL;
	} else {
		/* tail の後ろに追加 */
		atail->next = aphrase;
		aphrase->prev = atail;
		aphrase->next = NULL;
		atail = aphrase;
	}
	aphrase->parent = NULL;

	aphrase->nmora = 0;
	aphrase->accentType = -1;
	aphrase->position = -1;
	aphrase->interrogative = NO;
	aphrase->mphead = aphrase->mptail = NULL;

	return aphrase;
}

void open_AP( int n_op, TAGOPTIONS *op )
{
	int 	i;
	char	*attr, *val;
	APHRASE	*aphrase;

	for( i=0; i<n_op; ++i )  {
		if( attributeID( op[i].attr )==W_ORTH )  {
			if( op[i].val[0] == '\0' )  {
				return;
			} else {
				break;
			}
		}
	}

	if( atail->silence == SILE){
		make_sil_aphrase( SILB);
	}
	aphrase = new_aphrase();

	for( i=0; i<n_op; ++i )  {
		attr = op[i].attr;   val = op[i].val;
/*		TmpMsg( "%s='%s'\n", attr, val );	*/
		switch( attributeID( attr ) )  {
		case W_ORTH:
			break;
		case W_PRON:
			break;
		case W_A_TYPE:
			aphrase->accentType = ( val[0]=='\0' ) ? 0 : atoi( val );
			break;
		case W_SILENCE:
			if( strcmp(val,"PAU")==0 )  {
				aphrase->silence = PAU;
			} else if( strcmp(val,"SILB")==0 )  {
				aphrase->silence = SILB;
			} else if( strcmp(val,"SILE")==0 )  {
				aphrase->silence = SILE;
			} else {
				aphrase->silence = NON;
			}
			break;
		case W_INTERROGATIVE:
			if( strcmp(val,"YES")==0 )  {
				aphrase->interrogative = YES;
			} else {
				aphrase->interrogative = NO;
			}
			break;
		default:
/*			ErrMsg( "Unknown option ... %s='%s'\n", attr, val );	*/
			break;
		}
/*		if( strcmp("。",kanji)==0 )  break;	*/
	}
}

void close_AP()
{
}

/* 無音部のアクセント句を作成 */
void make_sil_aphrase( SILENCE sil )
{
	APHRASE *aphrase, *new_aphrase();

	aphrase = new_aphrase();
	aphrase->nmora = 0;
	aphrase->accentType = 0;
	aphrase->silence = sil;
	aphrase->interrogative = NO;

	make_sil_morph( sil );

	aphrase->mphead = mphead;
	aphrase->mptail = mptail;
}

void print_aphrase()
{
	int 	n;
	APHRASE	*a;

	LogMsg( "* aphrase data\n" );
	LogMsg( "(orth\tpron\t[accent]\tmora\tposition\tDEC/INT)\n" );
	n = 0;
	for( a=ahead; a; a=a->next )  {
		print_aphrase_kanji( a );
		LogMsg( "\t" );
		print_aphrase_yomi( a );
		LogMsg( "\t[%d]\t%d\t%d\t", a->accentType, a->nmora, a->position );
		if( a->interrogative == YES ) {
		  LogMsg( "INT" );
		} else {
		  LogMsg( "DEC" );
		}
		LogMsg( "\n" );
		++n;
	}
	LogMsg( "- n_aphrase: %d\n", n );
}

void print_aphrase_kanji( APHRASE *a )
{
	MORPH	*morph;

	for( morph=a->mphead; morph && morph->parent==a; morph=morph->next )  {
			LogMsg( "%s", morph->kanji );
	}
}

void print_aphrase_yomi( APHRASE *a )
{
	MORPH	*morph;

	for( morph=a->mphead; morph && morph->parent==a; morph=morph->next )  {
		print_morph_yomi( morph );
	}
}

