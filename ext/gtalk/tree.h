/* Copyright (c) 2000-2006                             */
/*   Takao Kobayashi, Takashi Masuko, Masatsune Tamura */
/*   (Tokyo Institute of Technology)                   */
/*   Keiichi Tokuda, Takayoshi Yoshimura, Heiga Zen    */
/*   (Nagoya Institute of Technology)                  */
/*   All rights reserved                               */
/*                                                     */
/* $Id: tree.h,v 1.7 2006/10/19 03:27:08 sako Exp $                                                */

/************************************************************************
*									*
*   PDF search functions from decision tree				*
*									*
*					2000.1 M.Tamura			*
*									*
************************************************************************/

typedef struct _Pattern{
  char *pat;
  struct _Pattern *next;
} Pattern;

typedef struct _Question{
  char *quest;
  Pattern *phead;
  Pattern *ptail;
  struct _Question *next;
} Question;

typedef struct _Node{
  char *name;
  int num;
  struct _Node *yes;
  struct _Node *no;
  int yesnum;
  int nonum;
  char *yespdf;
  char *nopdf;
  Question *quest;
  struct _Node *next;
} Node;
   
typedef struct _Tree{
  Mtype mt;
  char *phone;
  int state;
  struct _Tree *next;
  Node *parent;
  Node *nhead;
  Node *ntail;
} Tree;

void ReadTreeFile (FILE *, Mtype, int);
char *TraverseTree (char *, Node *);
void GetToken (FILE *, char *, int);

