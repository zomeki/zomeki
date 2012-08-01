/* Copyright (c) 2000-2006                  */
/*   Yamashita Lab., Ritsumeikan University */
/*   All rights reserved                    */
/*                                          */
/* $Id: tag.c,v 1.18 2006/10/19 03:27:08 sako Exp $                                     */

#include	<stdio.h>
#include	<stdlib.h>
#include	<string.h>
/*#include	<unistd.h>*/
#include	"synthesis.h"

#define INIT_TAG_TABLE
#include	"tag.h"

int LogMsg(char *, ...);
int ErrMsg(char *, ...);
void make_sil_morph(SILENCE);
char* malloc_char(char *, char *);
void restart(int);

#define LASTTAG (n_opentag - 1)

#define MAX_TAGSTACK 20

TAG *tagstack[MAX_TAGSTACK];

int n_opentag;

void init_tag()
{
	n_tag = n_opentag = 0;
}

void refresh_tag()
{
	int i, j;

	for( i=0; i<n_tag; ++i )  {
		for( j=0; j<tag[i]->n_op; ++j )  {
			free( tag[i]->options[j].val );
		}
		free( tag[i] );
	}
	n_tag = 0;

	/* 前回にエラーがなければ n_opentag は 0 のはず。 */
	for( i=0; i<n_opentag; ++i )  {
		for( j=0; j<tag[i]->n_op; ++j )  {
			free( tagstack[i]->options[j].val );
		}
		free( tagstack[i] );
	}
	n_opentag = 0;
}

int attributeID( char *attr )
{
	int 	i;
	for( i=0; i<NUM_ATTRIBUTE; ++i )  {
		if( strcmp( attr, attributeTable[i].name )==0 )  return attributeTable[i].id;
	}
	return -1;
}

/*
XMLタグからタグ名とオプションを取りだし、オプション数を返す。
	str の先頭から > までを解析。
	<W orth="音声" pron="オンセイ" ... info="accent=1">音声</W>
から
	タグ名: W, オプション: orth = 音声, ...
などの取りだし。
	<RATE SPEED="2.0">
から
	タグ名: RATE, オプション: SPEED = 2.0
などの取りだし。
	<SILENCE/>
のように、単独のタグの時には、alone = 1 とする。
*/

int parse_XMLtag( char *str, char *tagname, TAGOPTIONS *op, int *alone )
{
	int 	n_op, i;

	*alone = 0;
	while( *str==' ' || *str=='\t' )  { ++str; }	/* スペースの読みとばし */

	if( *str == '<' )  ++str;
	i = 0;
	if( *str == '/' )  {
		tagname[i++] = *(str++);	/* 終了タグの時 */
	}
	while( *str!=' ' && *str!='>' && *str!='/' )  { tagname[i++] = *(str++); }
	tagname[i] = '\0';
	if( *str != ' ' )  {	/* タグ終了 */
		if( *str == '/' )  *alone = 1;
		return 0;
	}

	while( *str == ' ' )  { ++str; }	/* スペースの読みとばし */

	n_op = 0;
	while( *str != '>' && *str != '\0' && *str != '/' )  {
		i = 0;
		while( *str != '=' && *str != ' ' )  {
			op[n_op].attr[i++] = *(str++);
			if( i>=TAG_ATTR_SIZE-1 )  i = TAG_ATTR_SIZE-1;
		}
		op[n_op].attr[i] = '\0';

		while( *str == '=' || *str == ' ' )  { ++str; }
		++str;		/* " の読みとばし */

		i = 0;
/*		op[n_op].val[i++] = *(str++);	*//* " のコピー */

		while( *str != '"' && *str != ' ' )  {
			op[n_op].val[i++] = *(str++);
			if( i>=TAG_VAL_SIZE-1 )  i = TAG_VAL_SIZE-1;
		}
/*		op[n_op].val[i++] = *(str++);	*//* " のコピー */
		op[n_op].val[i] = '\0';

/*		++str;		*//* " の読みとばし */
		if( *str == '"' )  ++str;		/* " の読みとばし */
		while( *str == ' ' )  { ++str; }	/* スペースの読みとばし */

		++n_op;
		if( n_op >= TAG_MAX_OP )  return n_op;
	}
	if( *str == '/' )  *alone = 1;
	return n_op;
}

/* tag ID の取り出し */
int tagID( char *t )
{
	int 	i;
	for( i=0; i<NUM_TAG; ++i )  {
		if( strcmp( t, tagTable[i].name )==0 )  return tagTable[i].id;
	}
	ErrMsg( "Unknown tag ... '%s'\n", t );
	return -1;
}

/* 属性 ID の取り出し */
int attrID( char *a )
{
	int 	i;
	for( i=0; i<NUM_ATTR; ++i )  {
		if( strcmp( a, attrTable[i].name )==0 )  return attrTable[i].id;
	}
	ErrMsg( "Unknown attribute of tag ... '%s'\n", a );
	return -1;
}

TAG *new_tag( int tid, int n, TAGOPTIONS *op )
{
	int i, aid;
	TAG *tg;

	tg = (TAG *) malloc( sizeof(TAG) );
	if( ! tg )  {
		ErrMsg( "* malloc error for 'tg' in new_tag\n" );
		restart(1);
	}
	tg->id = tid;
	tg->n_op = n;

	for( i=0; i<n; ++i )  {
		aid = attrID( op[i].attr );
		if( aid >= 0 )  	{
			tg->options[i].attrID = aid;
			tg->options[i].val = malloc_char( op[i].val, "tg->val" );
		} else {
			ErrMsg( "* Unknown tag option ... %s\n", op[i].attr );
			tg->options[i].attrID = -1;
			tg->options[i].val = NULL;
		}
	}
	tg->prev_morph = mptail;

	return tg;
}

void make_silence_tag( int n_op, TAGOPTIONS options[] )
{
	TAG *t;

	if( n_tag >= MAX_TAG )  {
		ErrMsg( "* Too many speech controll tags.\n" );
		return;
	}
	t = new_tag( T_SILENCE, n_op, options );
	if( t == NULL )  return;

	make_sil_morph( PAU );
	t->start_morph = mptail;
	t->end_morph = mptail;
	t->start = t->end = -1;
	tag[n_tag] = t;
	++n_tag;
}

/* EMPH タグは、RATE, VOLUME, PITCH のタグの組合わせで実現 */
void make_emph_tag( int n, TAGOPTIONS op[], int position )
{
	TAG *t;

	if( n_tag+2 >= MAX_TAG )  {
		ErrMsg( "* Too many speech controll tags.\n" );
		return;
	}
	tag[n_tag] = tagstack[LASTTAG];
	tag[n_tag]->end = position;
	tag[n_tag]->start_morph = tag[n_tag]->prev_morph->next;
	tag[n_tag]->end_morph = mptail;
	tag[n_tag]->id = T_PITCH;
	tag[n_tag]->n_op = 1;
	tag[n_tag]->options[0].attrID = TA_LEVEL;
	tag[n_tag]->options[0].val = malloc_char( "1.3", "val of EMPH" );
	++n_tag;  --n_opentag;
/*
	t = new_tag( T_VOLUME, n, op );
	if( t == NULL )  return;
	tag[n_tag] = t;
	tag[n_tag]->end = position;
	tag[n_tag]->start_morph = tag[n_tag]->prev_morph->next;
	tag[n_tag]->end_morph = mptail;
	tag[n_tag]->id = T_VOLUME;
	tag[n_tag]->n_op = 1;
	tag[n_tag]->options[0].attrID = TA_LEVEL;
	tag[n_tag]->options[0].val = malloc_char( "1.2", "val of EMPH" );
	++n_tag;
*/
	t = new_tag( T_RATE, n, op );
	if( t == NULL )  return;
	tag[n_tag] = t;
	tag[n_tag]->end = position;
	tag[n_tag]->start_morph = tag[n_tag]->prev_morph->next;
	tag[n_tag]->end_morph = mptail;
	tag[n_tag]->id = T_RATE;
	tag[n_tag]->n_op = 1;
	tag[n_tag]->options[0].attrID = TA_SPEED;
	tag[n_tag]->options[0].val = malloc_char( "1.2", "val of EMPH" );
	++n_tag;

}

void proc_JEITA_tag( char *tagname, 
	int n_op, TAGOPTIONS *options, int position )
{
	int 	close_tag, tid, i;
	char	*tagname0;
	TAG 	*t;

	if( n_op > MAX_JEIDA_TAGOPTIONS )  {
		ErrMsg( "* Too many options in a tag ...\n%s\n", tagname );
		return;
	}

/*	
	printf( "tagname: %s  %d\n", tagname, n_op );
	if( n_op > 0 )  printf( "options: %s = %s\n",  
		options[0].attr, options[0].val );
*/
	if( tagname[0] == '/' )  {
		tagname0 = tagname+1;
		close_tag = 1;
	} else {
		tagname0 = tagname;
		close_tag = 0;
	}
	tid = tagID( tagname0 );
	if( tid < 0 )  	return;

	for( i=0; i<n_op; ++i )  {
		if( attrID(options[i].attr)==TA_END )  {
			close_tag = 1;
			break;
		}
	}

	if( tid == T_SILENCE )  {
		if( close_tag != 1 )  make_silence_tag( n_op, options );
		return;
	}

	if( close_tag == 1 )  {
		if( n_opentag<=0 || tagstack[LASTTAG]->id != tid )  {
			ErrMsg( "Tag error ... %s\n", tagname );
			return;
		}
		if( tid == T_EMPH )  {
			make_emph_tag( n_op, options, position );
			return;
		}
		if( n_tag >= MAX_TAG )  {
			ErrMsg( "* Too many speech controll tags.\n" );
			return;
		}
		tag[n_tag] = tagstack[LASTTAG];
		tag[n_tag]->end = position;
		tag[n_tag]->start_morph = tag[n_tag]->prev_morph->next;
		tag[n_tag]->end_morph = mptail;
		++n_tag;  --n_opentag;
		return;
	}

/* open tag */
	if( n_opentag >= MAX_TAGSTACK )  {
		ErrMsg( "* Too deep nesting of speech controll tag.\n" );
		return;
	}
	t = new_tag( tid, n_op, options );
	if( t == NULL )  return;

	t->start = position;
	t->prev_morph = mptail;
	tagstack[n_opentag] = t;
	++n_opentag;
}

/* tag の名前の取り出し */
char* tagName( int tid )
{
	int 	i;
	for( i=0; i<NUM_TAG; ++i )  {
		if( tagTable[i].id==tid )  return tagTable[i].name;
	}
	ErrMsg( "Unknown tag ID ... %d\n", tid );
	return NULL;
}

/* 属性の名前の取り出し */
char *attrName( int aid )
{
	int 	i;
	for( i=0; i<NUM_ATTR; ++i )  {
		if( attrTable[i].id==aid )  return attrTable[i].name;
	}
	ErrMsg( "Unknown attribute ID of tag ... %d\n", aid );
	return NULL;
}

void print_tag()
{
	int i, j;
	LogMsg( "* tag data\n" );
	for( i=0; i<n_tag; ++i )  {
		LogMsg( "%s ", tagName(tag[i]->id) );
		for( j=0; j<tag[i]->n_op; ++j )  {
			LogMsg( "%s = %s ", attrName(tag[i]->options[j].attrID), 
				tag[i]->options[j].val );
		}
		LogMsg( " %d->%d\n", tag[i]->start, tag[i]->end );
	}
	LogMsg( "- n_tag: %d\n", n_tag );
}
