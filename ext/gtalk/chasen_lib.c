/* Copyright (c) 2000-2006                  */
/*   Yamashita Lab., Ritsumeikan University */
/*   Studio ARC, ASTEM RI/Kyoto             */
/*   All rights reserved                    */
/* Modified for library-based implementation  by H. Banno */
/*                                          */
/* $Id: chasen_lib.c,v 1.3 2006/10/19 03:27:08 sako Exp $                                     */

#ifdef USE_SPLIB
#include <sp/spBaseLib.h>
#endif

#ifdef USE_CHASENLIB
#include <chasen.h>
#endif

#include "chaone.h"

struct _CHASEN_FD {
    char *result;
};

typedef int  (*chasen_getopt_argv_type )( char**, FILE * );
typedef char*  (*chasen_sparse_tostr_type )( char* );

chasen_sparse_tostr_type chasen_sparse_func = NULL;

static char *current_result = NULL;

static CHASEN_FD init_chasen_fd(void)
{
    CHASEN_FD fd;

    fd = (CHASEN_FD)malloc(sizeof(struct _CHASEN_FD));
    fd->result = NULL;

    return fd;
}

int make_chasen_process( CHASEN_FD *fd_in, CHASEN_FD *fd_out )
{
    char *opt[] = { NULL, chasen_rc_option, chasen_rc, NULL };

#if defined(USE_CHASENLIB)
    {
	chasen_getopt_argv(opt, stdout);
	chasen_sparse_func = chasen_sparse_tostr;
	
	*fd_in = init_chasen_fd();
	*fd_out = init_chasen_fd();
	
	return 0;
    }
#elif defined(USE_SPLIB)
    {
	void *hlib;
	chasen_getopt_argv_type chasen_getopt_func = NULL;
	
	/* libchasen load */
	if( ( hlib = spOpenLibrary( chasen_dll ) ) != 0 )
	{
	    if( ( chasen_getopt_func = ( chasen_getopt_argv_type )spGetSymbolAddress( hlib, "chasen_getopt_argv" ) ) != 0 )
	    {
		( *chasen_getopt_func )( opt, stdout );
	    }

	    if( ( chasen_sparse_func = ( chasen_sparse_tostr_type )spGetSymbolAddress( hlib, "chasen_sparse_tostr" ) ) != 0 )
	    {
		*fd_in = init_chasen_fd();
		*fd_out = init_chasen_fd();
	    
		/* no error */
		return 0;
	    }
	}
	ErrMsg( "DLL open error in make_chasen_process\n" );
    }
#else
    ErrMsg( "make_chasen_process is not supported\n" );
#endif
	
    return -1;
}

int chasen_write_line( CHASEN_FD fd_out, char *text )
{
    char *chasen_result;
    
    if (fd_out == NULL || chasen_sparse_func == NULL) return EOF;

    if (current_result != NULL) {
	free(current_result);
	current_result = NULL;
    }
    
    /*TmpMsg( "chasen_write_line: text = %s\n", text );*/
    
    if ((chasen_result = ( *chasen_sparse_func )( text )) == NULL) {
	return EOF;
    }
    /*TmpMsg( "chasen_write_line: chasen_result = %s\n", chasen_result );*/
    
    current_result = make_chaone_process( chasen_result );

    fd_out->result = current_result;
    
    return 0;
}

int chasen_read_line( CHASEN_FD fd, char *buf, int len )
{
    char *ptr;
    int i;
    int c, prev_c;
    
    if (fd == NULL || current_result == NULL) return EOF;

    if (fd->result == NULL) {
	fd->result = current_result;
    }

    prev_c = '\0';
    ptr = fd->result;
    for (i = 0; *ptr != '\0'; i++) {
	c = *ptr;
	if (
#ifdef USE_SPLIB
	    spIsMBTailCandidate(prev_c, c) == SP_FALSE &&
#endif
	    (c == '\n' || (i > 0 && c == '<'))) {
	    *buf = '\0';
	    if (c == '\n') {
		++ptr;
	    }
	    if (*ptr == '\0') {
		fd->result = NULL;
	    } else {
		fd->result = ptr;
	    }
	    return 0;
	}
	*buf = c;

	++buf;  --len;
	if( len <= 1 )  {
	    ErrMsg( "Too long line ...\n" );
	    *buf = '\0';
	    fd->result = ptr;
	    return( 0 );
	}
	
	prev_c = c;
	++ptr;
    }

    *buf = '\0';
    fd->result = NULL;
    
    return EOF;
}
