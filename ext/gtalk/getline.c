/* Copyright (c) 2000-2006                  */
/*   Yamashita Lab., Ritsumeikan University */
/*   All rights reserved                    */
/*                                          */
/*  $Id: getline.c,v 1.6 2006/10/19 03:27:08 sako Exp $                                    */

#include <stdio.h>
#include <string.h>
#ifdef HAVE_READLINE
#include <readline/readline.h>
#include <readline/history.h>
#endif

#ifdef HAVE_READLINE

int gtalk_getline( char *buf, int MAX_LENGTH )
{
	char *s;
	int p;

	s = readline( NULL );
	if( s == NULL) return -1;

	strncpy( buf, s, MAX_LENGTH-1);
	free( s );

	buf[MAX_LENGTH-1] = '\0';
	p = strlen( buf );
	if( buf[p-1] == '\n' )  buf[p-1] = '\0';
	add_history( buf );

	return p;
}
 
#else  /* ~HAVE_READLINE */

int gtalk_getline( char *buf, int MAX_LENGTH )
{
	int p;

	fgets( buf, MAX_LENGTH, stdin );
	if( buf == NULL) return -1;
	p = strlen( buf ) - 1;
	if( buf[p] == '\n' )  buf[p] = '\0';

	return p;
}

#endif /* HAVE_READLINE */

