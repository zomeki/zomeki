/* Copyright (c) 2000-2006                  */
/*   Yamashita Lab., Ritsumeikan University */
/*   All rights reserved                    */
/*                                          */
/* $Id: make_breath.c,v 1.15 2006/10/19 03:27:08 sako Exp $                                     */

#include	<stdio.h>
#include	<stdlib.h>
#include	<string.h>
#include	"synthesis.h"
#include	"pos.h"

int TmpMsg(char *,...);
int LogMsg(char *,...);
int ErrMsg(char *,...);
void restart(int);
void print_breath_kanji(BREATH *);
void print_breath_yomi(BREATH *);
void print_aphrase_kanji(APHRASE *);
void print_aphrase_yomi(APHRASE *);


/* 最初に一度だけ */
void init_breath()
{
	bhead = btail = NULL;
}

/* 入力文ごとに */
/* 使っている呼気段落のセルの開放 */
void refresh_breath()
{
	BREATH *breath, *next;

	breath = bhead;
	while( breath )  {
		next = breath->next;
		free( breath );
		breath = next;
	}
	bhead = btail = NULL;
}

/* アクセント句 aphrase を呼気段落 breath に追加する */
void add_to_breath( APHRASE *aphrase, BREATH *breath )
{
	if( breath->ahead == NULL )  {
		/* 一つめの子供 */
		aphrase->position = 1;
		breath->ahead = breath->atail = aphrase;
	} else {
		/* 最後尾の子供に */
		aphrase->position = breath->atail->position + 1;
		breath->atail = aphrase;
	}
	if( aphrase->silence != NON )  aphrase->position = -1;
	breath->nmora += aphrase->nmora;
	aphrase->parent = breath;
}

BREATH *new_breath()
{
	BREATH	*breath;

	breath = (BREATH *) malloc( sizeof(BREATH) );
	if( ! breath )  {
		ErrMsg( "* malloc error for 'breath'\n" );
		restart(1);
	}
/* 作った呼気段落セルをチェーンの中に入れる */
	if( bhead == NULL )  {
		/* 一つめのセル */
		bhead = btail = breath;
		breath->prev = breath->next = NULL;
	} else {
		/* tail の後ろに追加 */
		btail->next = breath;
		breath->prev = btail;
		breath->next = NULL;
		btail = breath;
	}
	breath->parent = NULL;

	breath->nmora = 0;
	breath->position = -1;
	breath->silence = NON;
	breath->ahead = breath->atail = NULL;

	return breath;
}

void make_breath()
{
	APHRASE	*aphrase;
	BREATH	*breath=NULL;
	SILENCE pre_silence;
	int 	pre_hinshi, hinshi, position;

	pre_hinshi = 0;
	pre_silence = NON;
	position = -1;
	for( aphrase=ahead; aphrase; aphrase=aphrase->next )  {
		hinshi = aphrase->mptail->hinshiID;

		if( aphrase->silence != NON) {
			breath = new_breath();

		} else if( pre_silence != NON) {
			breath = new_breath();

		} else if( pre_hinshi == H_SONOTA_TOUTEN )  {
			/* 読点の後は別の呼気段落に */
			breath = new_breath();
		}
		add_to_breath( aphrase, breath );
		breath->silence = aphrase->silence;
		pre_hinshi = hinshi;
		pre_silence = aphrase->silence;
	}
}

void print_breath()
{
	int 	n;
	BREATH	*b;

	LogMsg( "* breath data\n" );
	LogMsg( "(orth\tpron\tmora\tposition)\n" );
	n = 0;
	for( b=bhead; b; b=b->next )  {
		print_breath_kanji( b );
		LogMsg( "\t" );
		print_breath_yomi( b );
		LogMsg( "\t%d\t%d\n", b->nmora, b->position );
		++n;
	}
	LogMsg( "- n_breath: %d\n", n );
}

void print_breath_kanji( BREATH *b )
{
	APHRASE	*a;

	for( a=b->ahead; a && a->parent==b; a=a->next )  {
		print_aphrase_kanji( a );
	}
}

void print_breath_yomi( BREATH *b )
{
	APHRASE	*a;

	for( a=b->ahead; a && a->parent==b; a=a->next )  {
		print_aphrase_yomi( a );
	}
}

