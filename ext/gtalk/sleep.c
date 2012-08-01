/* Copyright (c) 2000-2006                  */
/*   Yamashita Lab., Ritsumeikan University */
/*   All rights reserved                    */
/*                                          */
/* $Id: sleep.c,v 1.9 2006/10/19 03:27:08 sako Exp $                                     */

#include <stdio.h>
#include <time.h>

int
make_sleep_time( char *str, long *sleep_ms )
{
	int hour, min, sec, ms;
	time_t t;
	struct tm *timep;

	if( str[0] == '+' )  {
		if( sscanf( str, "+%d:%d:%d.%d", &hour, &min, &sec, &ms ) == 4 )  {
			*sleep_ms = (((hour*60)+min)*60+sec)*1000+ms;
			return( 0 );
		} else if( sscanf( str, "+%d", &ms ) == 1 )  {
			*sleep_ms = ms;
			return( 0 );
		} else {
			return( -1 );
		}
	}

	if( sscanf( str, "%d:%d:%d.%d", &hour, &min, &sec, &ms ) != 4 )  {
		return( -1 );
	}

	time( &t );
	timep = localtime( &t );

	*sleep_ms = ( hour - timep->tm_hour );	/* hour */
	*sleep_ms = *sleep_ms * 60 + ( min - timep->tm_min );	/* min */
	*sleep_ms = *sleep_ms * 60 + ( sec - timep->tm_sec );	/* sec */
	*sleep_ms = *sleep_ms * 1000 + ( ms - 0  );	/* ms */

	return( 0 );
}

