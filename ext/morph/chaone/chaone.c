/* ChaOne in C                         */
/*   using libxslt                     */
/*                          ver. 1.3.2 */
/*            2008-02-12 by Studio ARC */
/* Copyright (c) 2004-2008 Studio ARC  */
/*   All rights reserved               */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include <libxslt/transform.h>
#include <libxslt/xsltutils.h>
#include <libexslt/exslt.h>

extern int xmlLoadExtDtdDefaultValue;

char *encoding = KANJICODE;
char *xslFilename = CHAONE_DIR "/chaone.xsl";
char *moduleVersion = "1.3.1";

static void usage(const char *name) {
  printf("Usage: %s [options] [file]\n", name);
  printf("[file]\tinput file name. if none is specified, stdin is used\n");
  printf("\toutput to stdout\n");
  printf("[options]\n");
  printf("\t--encoding {ISO-2022-JP|EUC-JP|Shift_JIS|UTF-8}: set I/O encoding\n");
  printf("\t--mode {prep|chunker|phonetic|accent|postp|pc|pcp|pcpa|gtalk}: set standalone mode\n");
  printf("\t--debug : debug output to stderr in UTF-8\n");
}

static void version(const char *name) {
  printf("Version: %s\n", name);
  printf("	%s\n", moduleVersion);
}

int main(int argc, char **argv) {
  int arg_indx;
  const char *param[2 * 2 + 1];
  int param_indx = 0;
  char *xmlstr = (char *)malloc(65536);
  xsltStylesheetPtr xsl = NULL;
  char *inputFile = NULL;
  xmlDocPtr doc, res;
  int return_value = 0;
  char buf[2048];
  exsltRegisterAll();
  
  for (arg_indx = 1; arg_indx < argc; arg_indx++) {
    if (argv[arg_indx][0] != '-')
      break;
    if ((!strcmp(argv[arg_indx], "-h")) || (!strcmp(argv[arg_indx], "--help"))) {
      usage(argv[0]);
      return_value = 1;
      goto finish;
    }
    if ((!strcmp(argv[arg_indx], "-v")) || (!strcmp(argv[arg_indx], "--version"))) {
      version(argv[0]);
      return_value = 1;
      goto finish;
    }
    if ((!strcmp(argv[arg_indx], "-e")) || (!strcmp(argv[arg_indx], "--encoding"))) {
      arg_indx++;
      if ((!strcmp(argv[arg_indx], "ISO-2022-JP")) || (!strcmp(argv[arg_indx], "EUC-JP")) || (!strcmp(argv[arg_indx], "Shift_JIS")) || (!strcmp(argv[arg_indx], "UTF-8"))) {
	encoding = argv[arg_indx];
      } else {
	fprintf(stderr, "Unknown option %s\n", argv[arg_indx]);
	usage(argv[0]);
	return_value = 1;
	goto finish;
      }
    } else if ((!strcmp(argv[arg_indx], "-s")) || (!strcmp(argv[arg_indx], "--mode"))) {
      arg_indx++;
      if ((!strcmp(argv[arg_indx], "prep")) || (!strcmp(argv[arg_indx], "chunker")) || (!strcmp(argv[arg_indx], "phonetic")) || (!strcmp(argv[arg_indx], "accent")) || (!strcmp(argv[arg_indx], "postp")) || (!strcmp(argv[arg_indx], "pc")) || (!strcmp(argv[arg_indx], "pcp")) || (!strcmp(argv[arg_indx], "pcpa")) || (!strcmp(argv[arg_indx], "gtalk"))) {
	param[param_indx++] = "standalone";
	xmlChar *value;
	value = xmlStrdup((const xmlChar *)"'");
	value = xmlStrcat(value, (const xmlChar *)argv[arg_indx]);
	value = xmlStrcat(value, (const xmlChar *)"'");
	param[param_indx++] = (const char *)value;
      } else {
	fprintf(stderr, "Unknown option %s\n", argv[arg_indx]);
	usage(argv[0]);
	return_value = 1;
	goto finish;
      }
    } else if ((!strcmp(argv[arg_indx], "-d")) || (!strcmp(argv[arg_indx], "--debug"))) {
      param[param_indx++] = "debug";
      param[param_indx++] = "'true'";
    } else {
      fprintf(stderr, "Unknown option %s\n", argv[arg_indx]);
      usage(argv[0]);
      return_value = 1;
      goto finish;
    }
  }

  param[param_indx] = NULL;
  
  for (; arg_indx < argc; arg_indx++) {
    if (inputFile != NULL) {
      fprintf(stderr, "more than 1 input file: %s\n", argv[arg_indx]);
      usage(argv[0]);
      return_value = 1;
      goto finish;
    } else {
      inputFile = argv[arg_indx];
    }
  }
  
  xmlSubstituteEntitiesDefault(1);
  xmlLoadExtDtdDefaultValue = 1;
  xsl = xsltParseStylesheetFile((const xmlChar *)xslFilename);
  xmlFree(xsl->encoding);
  xsl->encoding = (xmlChar *)encoding;
  if (inputFile) {
    xsl->omitXmlDeclaration = 0;
  } else {
    xsl->omitXmlDeclaration = 1;
  }
  strcpy(xmlstr, "<?xml version='1.0' encoding='");
  strcat(xmlstr, encoding);
  strcat(xmlstr, "'?>");
  
  FILE *fp;
  if (inputFile) {
    fp = fopen(inputFile, "r");
  } else {
    fp = stdin;
  }
  if(fp == NULL)  {
    fprintf(stderr, "* Can't open ... %s\n", inputFile);
    goto finish;
  }
  while(fgets(buf, sizeof(buf), fp) != NULL) {
    strcat(xmlstr, buf);
    if((strncmp(buf,"</S>",4)==0) || (strncmp(buf,"</cha:S>",8)==0)) {
      doc = xmlParseMemory(xmlstr, strlen(xmlstr));
      res = xsltApplyStylesheet(xsl, doc, param);
      xmlFreeDoc(doc);
      xsltSaveResultToFile(stdout, res, xsl);
      xmlFreeDoc(res);
      strcpy(xmlstr, "<?xml version='1.0' encoding='");
      strcat(xmlstr, encoding);
      strcat(xmlstr, "'?>");
    }
  }
  
  //xsltFreeStylesheet(xsl);
  xsltCleanupGlobals();
  xmlCleanupParser();
  
 finish:
  free(xmlstr);
  return(return_value);
}
