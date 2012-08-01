/* Copyright (c) 2000-2006                  */
/*   Yamashita Lab., Ritsumeikan University */
/*   All rights reserved                    */
/*                                          */
/* $Id: pronunciation.h,v 1.12 2006/10/19 03:27:08 sako Exp $                                     */

#ifdef WIN32
#include "pronunciation_sjis.h"
#else
#include "pronunciation_eucjp.h"
#endif

#define	NUM_KANA	(sizeof(prnTable)/sizeof(prnTable[0]))
