/* Copyright (c) 2000-2006                             */
/*   Takao Kobayashi, Takashi Masuko, Masatsune Tamura */
/*   (Tokyo Institute of Technology)                   */
/*   Keiichi Tokuda, Takayoshi Yoshimura, Heiga Zen    */
/*   (Nagoya Institute of Technology)                  */
/*   All rights reserved                               */
/*                                                     */
/* $Id: model.h,v 1.8 2006/10/19 03:27:08 sako Exp $                                                */

/************************************************************************
*									*
*    Model reading functions						*
*									*
*					2000.5 M.Tamura			*
*									*
************************************************************************/

typedef struct _Model {
  char *name;
  char *durpdf;
  char **pitchpdf;
  char **mceppdf;
  int *duration;
  int totalduration;
  float *durmean;
  float *durvariance;
  float **pitchmean;
  float **pitchvariance;
  float **mcepmean;
  float **mcepvariance;
  Boolean *voiced;
  PHONEME *phoneme;
  struct _Model *next;
} Model;

extern Model *mhead;
extern Model *mtail;

extern FILE *durmodel;
extern FILE *pitchmodel;
extern FILE *mcepmodel;

void ReadModelFile (int);
void SearchDurationPDF (Model *, int);
void SearchPitchPDF (Model *, int, int);
void SearchMcepPDF (Model *, int, int);

