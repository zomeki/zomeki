/* Copyright (c) 2000-2006                             */
/*   Takao Kobayashi, Takashi Masuko, Masatsune Tamura */
/*   (Tokyo Institute of Technology)                   */
/*   Keiichi Tokuda, Takayoshi Yoshimura, Heiga Zen    */
/*   (Nagoya Institute of Technology)                  */
/*   All rights reserved                               */
/*                                                     */
/*  $Id: misc.c,v 1.9 2006/10/19 03:27:08 sako Exp $                                               */

/************************************************************************
*									*
*    Miscellaneous Functions (from SPTK)				*
*									*
*					2000.1 M.Tamura			*
*									*
************************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "misc.h"

int ErrMsg(char *,...);
void restart(int);

FILE *getfp (name, opt)
     char *name, *opt;
{
  FILE *fp;

  if ((fp = fopen (name, opt)) == NULL)
    {
      ErrMsg("Can't open '%s'!\n", name);
      exit (2);
    }
  return (fp);
}

static	float	*f;
static	int	items;

int fwritef (ptr, size, nitems, fp)
     double *ptr;
     unsigned int size;
     int nitems;
     FILE *fp;
{
  int i;
  if (items < nitems)
    {
      if (f != NULL)
        free (f);
        items = nitems;
        if ((f = (float *) calloc (items, sizeof (float))) == NULL)
          {
            ErrMsg("Memory allocation error !  (in fwritef)\n");
            restart(1);
          }
    }
  for (i = 0; i < nitems; i++)
    f[i] = (float)ptr[i];
  return fwrite (f, sizeof (float), nitems, fp);
}

int freadf (ptr, size, nitems, fp)
     double *ptr;
     unsigned int size;
     int nitems;
     FILE *fp;
{
  int i, n;
  if (items < nitems)
    {
      if (f != NULL)
        free (f);
      items = nitems;
      if ((f = (float *) calloc (items, sizeof (float))) == NULL)
        {
          ErrMsg("Memory allocation error !  (in freadf)\n");
          restart(1);
        }
    }
  n = fread (f, sizeof (float), nitems, fp);
  for (i = 0; i < n; i++)
    ptr[i] = f[i];
  return n;
}

void GetToken (fp, buff, maxlength)
     FILE *fp;
     char *buff;
     int maxlength;
{
  static char c;
  int i;
  Boolean squote = FA;
  Boolean dquote = FA;
  if(maxlength <1) return;
  buff[0]=0;
  if(maxlength <2) return;

  c = fgetc (fp);
  while (isspace (c))
    c = fgetc (fp);
  if(c==EOF) return;

  if (c == '\'')      /*single quote*/
    {
      c = fgetc (fp);
      squote = TR;
    }
  if (c == '\"')      /*double quote*/
    {
      c = fgetc (fp);
      dquote = TR;
    }
  if (c == ',')       /*special character ','*/
    {
      strcpy (buff, ",");
      return;
    }
  i = 0;
  while (TR)
    {
      buff[i++] = c;
      if(i >= maxlength-1) { i=maxlength-1; break;}
      c = fgetc (fp);  if(c==EOF) break;
      if (squote && c == '\'') break;
      if (dquote && c == '\"') break;
      if (!(squote || dquote || isgraph (c))) break;
    }
  buff[i]=0;
}

void movem (a, b, size, nitem)
      register char *a, *b;
      int size, nitem;
{
  register long i;

  i = size * nitem;
  if (a > b)
    while (i--) *b++ = *a++;
  else
    {
      a += i; b += i;
      while (i--) *--b = *--a;
    }
}

void fillz(ptr, size, nitem)
char *ptr;
int size, nitem;
{
    register long n;
    
    n = size * nitem;
    while(n--)
        *ptr++ = '\0';
}

