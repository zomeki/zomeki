/* Copyright (c) 2000-2006                  */
/*   Studio ARC, ASTEM RI/Kyoto             */
/*   All rights reserved                    */
/*                                          */
/*  $Id: chaone.h,v 1.4 2006/10/19 03:27:08 sako Exp $                                    */

#ifndef _CHAONE_H_

#ifdef __cplusplus
extern "C" {
#endif

#if defined(_WIN32) && !defined(__CYGWIN32__)
#define KANJICODE "Shift_JIS"
#else
#define KANJICODE "EUC-JP"
#endif
    
void refresh_chaone();
char* make_chaone_process( char* pszXmlIn );

#ifdef __cplusplus
}
#endif

#endif /* _CHAONE_H_ */
