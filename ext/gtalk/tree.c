/* Copyright (c) 2000-2006                             */
/*   Takao Kobayashi, Takashi Masuko, Masatsune Tamura */
/*   (Tokyo Institute of Technology)                   */
/*   Keiichi Tokuda, Takayoshi Yoshimura, Heiga Zen    */
/*   (Nagoya Institute of Technology)                  */
/*   All rights reserved                               */
/*                                                     */
/* $Id: tree.c,v 1.10 2006/10/19 03:27:08 sako Exp $                                                */

/************************************************************************
*									*
*   PDF search functions from decision tree				*
*									*
*					2000.1 M.Tamura			*
*									*
************************************************************************/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#include "misc.h"
#include "tree.h"
#include "confpara.h"
#include "hmmsynth.h"

int TmpMsg(char *,...);
int ErrMsg(char *,...);

#if 0
Boolean DPMatch (string, pattern, pos, max)
     char *string, *pattern;
     int pos,max;
{
  if (pos > max) return FA;
  if (*string == '\0' && *pattern == '\0') return TR;
  if (*pattern == '*')
    {
      if (DPMatch (string + 1, pattern, pos+1, max) == TR)
         return TR;
      else
         return DPMatch (string + 1, pattern + 1, pos + 1, max);
    }
  if (*string == *pattern || *pattern == '?')
    {
      if (DPMatch (string + 1, pattern + 1, pos + 1, max + 1) == TR)
        {
          return TR;
        }
      else if (*(pattern + 1) == '*')
        {
          return DPMatch (string + 1, pattern + 2, pos + 1, max + 1);
        }
    }
  else
    return FA;
  return FA;
}
#else
Boolean	DPMatch_new( string, pattern, pos, max )
char	*string, *pattern;
int		pos, max;
{
	char	*p, *s;
	int		cnt;

	if( pos > max ) {
		return( FA );
	}
	if( ( *string == '\0' ) && ( *pattern == '\0' ) ) {
		return( TR );
	}
	if( *pattern == '*' ) {

		for( cnt = 0, p = pattern+1, s = string ; *p && *s ; s++, cnt++ ) {
			if( *p == *s ) {
				if( DPMatch_new( s, p, pos+cnt, max ) == TR ) {
					return( TR );
				}
			}
		}
		return( DPMatch_new( string+1, pattern+1, pos+1, max ) );
/*
		if( DPMatch( string+1, pattern, pos+1, max ) == TR ) {
			return( TR );
		} else {
			return( DPMatch( string+1, pattern+1, pos+1, max ) );
		}
*/
	}

	if( ( *string == *pattern ) || ( *pattern == '?' ) ) {

		for( cnt = 0, p = pattern+1, s = string+1 ; *p && *s ; p++, s++, cnt++ ) {
			if( *p != *s ) {
				if( *p == '*' ) {
					if( *(p+1) == '\0' ) {
						return( TR );
					}
					if( DPMatch_new( s, p, pos+cnt, max+1 ) == TR ) {
						return( TR );
					}
				} else if( *p == '?' ) {
					continue;
				} else {
					return( FA );
				}
			}
		}

		if( ( *p == '\0' ) && ( *s == '\0' ) ) {
			return( TR );
		}

		if( *(pattern+1) == '*' ) {
			return( DPMatch_new( string+1, pattern+1, pos+1, max+1 ) );
		}
/*
		if( DPMatch( string+1, pattern+1, pos+1, max+1 ) == TR ) {
			return( TR );
		} else if( *(pattern+1) == '*' ) {
			return( DPMatch( string+1, pattern+2, pos+1, max+1 ) );
		}
*/
	} else {
		return( FA );
	}
	return( FA );
}
#endif

Boolean PatternMatch (string, pattern)
     char *string, *pattern;
{
  int i, max = 0;
  for(i = 0; i < (int) strlen (pattern); i++)
    if (pattern[i] != '*') max++;
#if 0
  return DPMatch (string, pattern, 0, strlen (string) - max);
#else
  return DPMatch_new (string, pattern, 0, strlen (string) - max);
#endif
}

Boolean QuestionMatch (string, quest)
     char *string;
     Question *quest;
{
  Boolean flag = FA;
  Pattern *ptmp;
  for (ptmp = quest->phead; ptmp != quest->ptail; ptmp = ptmp->next)
    {
      flag = PatternMatch (string, ptmp->pat);
      if (flag)
        break;
    }
  return flag;
}

char *TraverseTree (string, nd)
     char *string;
     Node *nd;
{
  Boolean answer;
  answer = QuestionMatch (string, nd->quest);

#ifdef DEBUG
  TmpMsg("%s,%d\n", nd->quest->quest, answer);
#endif /* DEBUG */

  if (answer)
    {
      if (nd->yesnum == 1)
        {

#ifdef DEBUG
          TmpMsg("%s\n", nd->yespdf);
#endif /* DEBUG */

         return nd->yespdf;
        }
      else
        {
         return TraverseTree (string, nd->yes);
        }
    }
  if (!answer)
    {
      if (nd->nonum == 1)
        {

#ifdef DEBUG
          TmpMsg("%s\n", nd->nopdf);
#endif /* DEBUG */

          return nd->nopdf;
        }
      else
        return TraverseTree (string, nd->no);
    }
  return NULL;
}

void ReadQuestion (fp, mt, sid)
     FILE *fp;
     Mtype mt;
     int sid;
{
  char buff[1024];

  GetToken (fp, buff, 1024);
  mset[sid].qtail[mt]->quest = strdup (buff);
  if ((mset[sid].qtail[mt]->phead = (Pattern *) calloc (1, sizeof (Pattern))) == NULL)
    {
      ErrMsg("Memory allocation error !\n");
      exit (1);
    }

  mset[sid].qtail[mt]->ptail = mset[sid].qtail[mt]->phead;
  GetToken (fp, buff, 1024);
  if (strcmp (buff, "{") == 0)
    {
      while (strcmp (buff, "}") != 0)
        {
          GetToken (fp, buff, 1024);
          mset[sid].qtail[mt]->ptail->pat = strdup (buff);
          if ((mset[sid].qtail[mt]->ptail->next = (Pattern *) calloc (1, sizeof (Pattern))) == NULL)
            {
              ErrMsg("Memory allocation error !\n");
              exit (1);
            }

          mset[sid].qtail[mt]->ptail = mset[sid].qtail[mt]->ptail->next;
          GetToken (fp, buff, 1024);
        }
    }
  if ((mset[sid].qtail[mt]->next = (Question *) calloc (1, sizeof (Question))) == NULL)
    {
      ErrMsg("Memory allocation error !\n");
      exit (1);
    }

  mset[sid].qtail[mt] = mset[sid].qtail[mt]->next;
}

Boolean istree (buff, mt, sid)
     char *buff;
     Mtype mt;
     int sid;
{
  char *s,*c;
  Boolean flag = TR;

  s = buff;
  if ((c = strchr (s, '[')) != NULL)
    {
      *c = '\0';
      mset[sid].ttail[mt]->phone = strdup (s);
      s = c + 1;
      if ((c = strchr (s, ']')) != NULL)
        {
          *c = '\0';
          mset[sid].ttail[mt]->state = atoi (s);
          mset[sid].ttail[mt]->mt = mt;
        }
      else
        flag = FA;
    }
  else
    flag = FA; 
  return flag;
}

Boolean isnum (buff)
      char *buff;
{
   Boolean flag = TR;
   int i;

   for (i=0; i < (int) strlen (buff); i++)
      if (! (isdigit (buff[i]) || (buff[i] == '-'))) flag = FA;
   return flag;
}

void ConstructTree (end, mt, sid)
     int end;
     Mtype mt;
     int sid;
{
  Node **npp;
  Node *ntmp;
  Question *qtmp;


  end = abs (end);
  if ((npp = (Node **) calloc (end + 1, sizeof (Node *))) == NULL)
    {
      ErrMsg("Memory allocation error !\n");
      exit (1);
    }

  for (ntmp = mset[sid].ttail[mt]->nhead; ntmp != mset[sid].ttail[mt]->ntail; ntmp = ntmp->next)
    npp[abs (ntmp->num)] = ntmp;

  mset[sid].ttail[mt]->parent = mset[sid].ttail[mt]->nhead;
  for (ntmp = mset[sid].ttail[mt]->nhead; ntmp != mset[sid].ttail[mt]->ntail; ntmp = ntmp->next)
    {
      if (ntmp->yesnum != 1)
        ntmp->yes = npp[abs (ntmp->yesnum)];
      if (ntmp->nonum != 1)
        ntmp->no = npp[abs (ntmp->nonum)];
      for(qtmp = mset[sid].qhead[mt]; qtmp != mset[sid].qtail[mt]; qtmp = qtmp->next)
        if(strcmp (qtmp->quest, ntmp->name) == 0)
          {
            ntmp->quest = qtmp;
            break;
          }
    }
  free (npp);
}

void ReadTree (fp, mt, sid)
     FILE *fp;
     Mtype mt;
     int sid;
{
  char buff[1024];
  int num, end = 0;
  GetToken (fp, buff, 1024);
  if ((mset[sid].ttail[mt]->nhead = (Node *) calloc (1, sizeof (Node))) == NULL)
    {
      ErrMsg("Memory allocation error !\n");
      exit (1);
    }

  mset[sid].ttail[mt]->ntail = mset[sid].ttail[mt]->nhead;
  if(strcmp (buff,"{") == 0)
    {
      while (TR)
        {
          GetToken (fp, buff, 1024);	/* number */
          if (strcmp (buff, "}") == 0) break;
          num = atoi (buff);
          end = num;
          mset[sid].ttail[mt]->ntail->num = num;
          GetToken (fp, buff, 1024);     /* question */
          mset[sid].ttail[mt]->ntail->name = strdup (buff);
          GetToken (fp, buff, 1024);     /* no number */
          if (isnum (buff))
            {
              mset[sid].ttail[mt]->ntail->nonum = atoi (buff);
            }
          else
            {
              mset[sid].ttail[mt]->ntail->nopdf = strdup (buff);
              mset[sid].ttail[mt]->ntail->nonum = 1;
            }
          GetToken (fp, buff, 1024);     /* yes number */
          if (isnum (buff))
            {
              mset[sid].ttail[mt]->ntail->yesnum = atoi (buff);
            }
          else
            {
               mset[sid].ttail[mt]->ntail->yespdf = strdup (buff);
               mset[sid].ttail[mt]->ntail->yesnum = 1;
             }
          if ((mset[sid].ttail[mt]->ntail->next = (Node *) calloc (1, sizeof (Node))) == NULL)
            {
              ErrMsg("Memory allocation error !\n");
              exit (1);
            }

          mset[sid].ttail[mt]->ntail = mset[sid].ttail[mt]->ntail->next;
        }
      ConstructTree (end, mt, sid);
    }
  if ((mset[sid].ttail[mt]->next = (Tree *) calloc (1, sizeof (Tree))) == NULL)
    {
      ErrMsg("Memory allocation error !\n");
      exit (1);
    }

  mset[sid].ttail[mt] = mset[sid].ttail[mt]->next;
}
   
void WriteTree (nd)
     Node *nd;
{
  char buff[1024];
  sprintf (buff, "\'%s\'", nd->name);
  TmpMsg(" %3d %24s", nd->num, buff);
  if(nd->yesnum == 1)
    {
      sprintf (buff, "\"%s\"", nd->yespdf);
      TmpMsg("  %s", buff);
    }
  else
    {
      TmpMsg("    %4d   ", nd->yesnum);
    }

  if (nd->nonum == 1)
    {
      sprintf (buff, "\"%s\" ", nd->nopdf);
      TmpMsg("  %s", buff);
    }
  else
    {
      TmpMsg("    %4d    ", nd->nonum);
    }
  TmpMsg("\n");
}
   
void ReadTreeFile(fp,mt,sid)
     FILE *fp;
     Mtype mt;
     int sid;
{
  char buff[1024];

#ifdef DEBUG
  question *qtmp;
  pattern *ptmp;
  tree *ttmp;
  node *ntmp;
#endif /* DEBUG */

  if ((mset[sid].qhead[mt] = (Question *) calloc (1, sizeof (Question))) == NULL)
    {
      ErrMsg("Memory allocation error !\n");
      exit (1);
    }

  mset[sid].qtail[mt] = mset[sid].qhead[mt];
  if ((mset[sid].thead[mt] = (Tree *) calloc (1, sizeof (Tree))) == NULL)
    {
      ErrMsg("Memory allocation error !\n");
      exit (1);
    }

  mset[sid].ttail[mt] = mset[sid].thead[mt];

  while (! feof (fp))
    {
      GetToken (fp, buff, 1024);
      if (strcmp (buff, "QS") == 0)
        ReadQuestion (fp, mt, sid);
      if (istree (buff, mt, sid))
        ReadTree (fp, mt, sid);
    }

#ifdef DEBUG
  for (qtmp = mset[sid].qhead[mt]; qtmp != mset[sid].qtail[mt]; qtmp = qtmp->next)
    {
      TmpMsg("QS '%s' { ", qtmp->quest);
      TmpMsg("\"%s\"", qtmp->phead->pat);
      for (ptmp = qtmp->phead->next; ptmp != qtmp->ptail; ptmp = ptmp->next)
        {
          TmpMsg(",\"%s\"", ptmp->pat);
        }
      TmpMsg(" }\n");
    }
  TmpMsg("\n");
  for (ttmp = mset[sid].thead[mt]; ttmp != mset[sid].ttail[mt]; ttmp = ttmp->next)
    {
      TmpMsg("%s[%d]\n", ttmp->phone, ttmp->state);
      TmpMsg("{\n");
      for (ntmp = ttmp->nhead; ntmp != ttmp->ntail; ntmp = ntmp->next)
        WriteTree (ntmp);
      TmpMsg("}\n\n");
   }
#endif /* DEBUG */

}

