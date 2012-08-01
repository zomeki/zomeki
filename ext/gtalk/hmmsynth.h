/* Copyright (c) 2000-2006                             */
/*   Takao Kobayashi, Takashi Masuko, Masatsune Tamura */
/*   (Tokyo Institute of Technology)                   */
/*   Keiichi Tokuda, Takayoshi Yoshimura, Heiga Zen    */
/*   (Nagoya Institute of Technology)                  */
/*   All rights reserved                               */
/*                                                     */
/* $Id: hmmsynth.h,v 1.8 2006/10/19 03:27:08 sako Exp $                                                */

typedef struct _ModelSet {
  float **durpdf;
  float ***mceppdf;
  float ****pitchpdf;
  Tree *thead[3];
  Tree *ttail[3];
  Question *qhead[3];
  Question *qtail[3];
} ModelSet;

extern int nstate;
extern int pitchstream;
extern int mcepvsize;

extern ModelSet mset[MAX_SPEAKER];

extern double **mcep;  /* generated mel-cepstrum */
extern double **coeff; /* mlsa filter coefficients */

extern int totalframe;

