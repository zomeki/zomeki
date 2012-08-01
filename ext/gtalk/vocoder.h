/* Copyright (c) 2000-2006                             */
/*   Takao Kobayashi, Takashi Masuko, Masatsune Tamura */
/*   (Tokyo Institute of Technology)                   */
/*   Keiichi Tokuda, Takayoshi Yoshimura, Heiga Zen    */
/*   (Nagoya Institute of Technology)                  */
/*   All rights reserved                               */
/*                                                     */
/* $Id: vocoder.h,v 1.7 2006/10/19 03:27:08 sako Exp $                                                */

/************************************************************************
*									*
*   mel-cepstral vocoder (pulse/noise excitation & MLSA filter)		*
*									*
*					2000.9 M.Tamura			*
*									*
************************************************************************/

double	sqrt();
int     mseq();
double	rnd();
unsigned long srnd();
double	nrandom();
int	nrand();
double mlsadf();

void init_vocoder(int);
void refresh_vocoder();
void vocoder (double,double *,int,double,double);
void mc2b(double *,double *,int,double);
double b2en(double *,int,double);
void b2mc(double *,double *,int,double);
void freqt(double *,int,double *,int,double);
void c2ir(double *,int,double *,int);
