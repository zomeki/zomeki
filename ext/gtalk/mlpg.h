/* Copyright (c) 2000-2006                             */
/*   Takao Kobayashi, Takashi Masuko, Masatsune Tamura */
/*   (Tokyo Institute of Technology)                   */
/*   Keiichi Tokuda, Takayoshi Yoshimura, Heiga Zen    */
/*   (Nagoya Institute of Technology)                  */
/*   All rights reserved                               */
/*                                                     */
/* $Id: mlpg.h,v 1.8 2006/10/19 03:27:08 sako Exp $                                                */

/************************************************************************
*									*
*    ML-based Parameter Generation from PDFs				*
*									*
*					1999.7 T.Masuko			*
*					2000.1 M.Tamura modified	*
*									*
************************************************************************/

#define MTYPE FA

#define LENGTH 256
#define INFTY ((double) 1.0e+38)
#define INFTY2 ((double) 1.0e+19)
#define INVINF ((double) 1.0e-38)
#define INVINF2 ((double) 1.0e-19)

#ifndef min
  #define min(x, y) ((x) < (y) ? (x) : (y))
#endif /* min */

#define WLEFT 0
#define WRIGHT 1

typedef struct _DWin {
  int num;           /* number of static + deltas */
  int calccoef;      /* calculate regression coefficients */
  char **fn;         /* delta window coefficient file */
  int **width;       /* width [0..num-1][0(left) 1(right)] */
  double **coef;     /* coefficient [0..num-1][length[0]..length[1]] */
  int maxw[2];       /* max width [0(left) 1(right)] */
  int max_L;
} DWin;

typedef struct _SMatrices {
	double **mseq;   /* sequence of mean vector */
	double **ivseq;	 /* sequence of invarsed variance vector */
	double *C;		 /* generated parameter c */
	double *g;			
	double **WUW;
	double *WUM;
} SMatrices;

typedef struct _PStream {
	int vSize;
	int	order;
	int	mType;
	int	T;
	int max_T;
	int	width;
	DWin dw;
	double **par;     /* output parameter vector */
	SMatrices sm;
} PStream;

extern PStream pitchpst;
extern PStream mceppst;

extern Boolean *voiced;

void InitDWin (PStream *);
void GenerateParam(FILE *);

