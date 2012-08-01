/* ChaOne in C                         */
/*   using libxslt                     */
/*                        ver. 1.2.0b4 */
/*            2005-03-27 by Studio ARC */
/* Copyright (c) 2004-2006 Studio ARC  */
/*   All rights reserved               */
/* Modified for library-based implementation in gtalk  by H. Banno */
/*                                     */
/* $Id: chaone.c,v 1.3 2006/10/19 03:27:08 sako Exp $                                */

#ifdef USE_CHASENLIB
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include <libxslt/transform.h>
#include <libxslt/xsltutils.h>
#include <libexslt/exslt.h>

#if defined(_WIN32) && !defined(__CYGWIN32__)
#include <mbctype.h>
#include <mbstring.h>

#define strchr(string, c) ((char *)_mbschr(((unsigned char *)string), (unsigned int)c))
#define strrchr(string, c) ((char *)_mbsrchr(((unsigned char *)string), (unsigned int)c))
#endif

extern int xmlLoadExtDtdDefaultValue;

#include "chaone.h"
#include "confpara.h"

static char *encoding = KANJICODE;
static int initialized = 0;

void refresh_chaone( void )
{
    return;
}

char* make_chaone_process( char* pszXmlIn )
{
    int arg_indx;
    const char *param[2 * 2 + 1];
    int param_indx = 0;
    char *istr;
    char *xmlstr;
    int xmlstr_len;
    int required_len;
    char *inputFile = NULL;
    xmlDocPtr doc, res;
    xmlChar *oxmlstr = NULL;
    int oxmlstr_len;
    xmlChar *doctxt;
    int doctxt_len;
    char *p, *np;
    xsltStylesheetPtr xsl;

    if (chaone_xsl == NULL || chaone_xsl[0] == '\0') return NULL;

    if (!initialized) {
	exsltRegisterAll();
	xmlSubstituteEntitiesDefault(1);
	xmlLoadExtDtdDefaultValue = 1;
	
	initialized = 1;
    }
    
    xsl = xsltParseStylesheetFile((const xmlChar *)chaone_xsl);
    
    param[param_indx] = NULL;
    
    xmlstr_len = 65536;
    xmlstr = (char *)malloc(xmlstr_len);

    strcpy(xmlstr, "<?xml version='1.0' encoding='");
    strcat(xmlstr, encoding);
    strcat(xmlstr, "'?>");

    oxmlstr = NULL; oxmlstr_len = 0;

    istr = (char *)malloc(strlen(pszXmlIn) + 1);
    strcpy(istr, pszXmlIn);
    
    p = istr;
    while (*p != '\0') {
	if ((np = strchr(p, '\n')) != NULL) {
	    *np = '\0';
	    np++;
	} else {
	    np = p + strlen(p);
	}
	/*TmpMsg( "make_chaone_process: p = %s\n", p );*/

	required_len = strlen(xmlstr) + strlen(p) + 64;
	if (required_len > xmlstr_len) {
	    /*TmpMsg( "make_chaone_process: realloc xmlstr, orignal len = %d, required len = %d\n",
	      xmlstr_len, required_len );*/
	    
	    if (required_len < xmlstr_len + 65536) {
		xmlstr_len += 65536;;
	    } else {
		xmlstr_len = required_len;
	    }
	    xmlstr = (char *)realloc(xmlstr, xmlstr_len);
	}
	strcat(xmlstr, p);
	strcat(xmlstr, "\n");
	
	if (strncmp(p, "</S>", 4) == 0) {
	    doc = xmlParseMemory(xmlstr, strlen(xmlstr));
	    res = xsltApplyStylesheet(xsl, doc, NULL);
	    
	    doctxt = NULL, doctxt_len = 0;
	    xsltSaveResultToString(&doctxt, &doctxt_len, res, xsl);
	    /*TmpMsg( "make_chaone_process: xsltSaveResultToString done: doctxt_len = %d \n", doctxt_len );*/

	    if (doctxt != NULL && doctxt_len > 0) {
		if (oxmlstr == NULL) {
		    oxmlstr_len = doctxt_len;
		    oxmlstr = (xmlChar *)xmlMalloc(sizeof(xmlChar) * (oxmlstr_len + 1));
		    memcpy(oxmlstr, doctxt, sizeof(xmlChar) * (doctxt_len + 1));
		} else {
		    oxmlstr_len += doctxt_len;
		    oxmlstr = (xmlChar *)xmlRealloc(oxmlstr, sizeof(xmlChar) * (oxmlstr_len + 1));
		    xmlStrcat(oxmlstr, doctxt);

		}
		xmlFree(doctxt);
	    }
	    
	    xmlFreeDoc(doc);
	    xmlFreeDoc(res);
	    
	    strcpy(xmlstr, "<?xml version='1.0' encoding='");
	    strcat(xmlstr, encoding);
	    strcat(xmlstr, "'?>");
	}

	p = np;
    }
    
    xsltFreeStylesheet(xsl);
  
    free(xmlstr);
    free(istr);
  
    return (char *)oxmlstr;
}
#endif
