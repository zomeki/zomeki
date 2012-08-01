/* Copyright (c) 2000-2006                             */
/*   Takao Kobayashi, Takashi Masuko, Masatsune Tamura */
/*   (Tokyo Institute of Technology)                   */
/*   Keiichi Tokuda, Takayoshi Yoshimura, Heiga Zen    */
/*   (Nagoya Institute of Technology)                  */
/*   All rights reserved                               */
/*                                                     */
/*  $Id: mlpg.c,v 1.11 2006/10/19 03:27:08 sako Exp $                                               */

/************************************************************************
*									*
*    ML-based Parameter Generation from PDFs				*
*									*
*					2000.4 T.Masuko			*
*					2000.6 M.Tamura			*
*									*
************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "synthesis.h"
#include "defaults.h"
#include "misc.h"
#include "model.h"
#include "mlpg.h"
#include "confpara.h"
#include "tree.h"
#include "hmmsynth.h"
#include "vocoder.h"

int ErrMsg(char *,...);

double finv (x)
   double x;
{
  if (x >= INFTY2) return 0.0;
  if (x <= -INFTY2) return 0.0;
  if (x <= INVINF2 && x >= 0) return INFTY;
  if (x >= -INVINF2 && x < 0) return -INFTY;
  return 1.0 / x;
}
   
void GenerateParam(rawfp)
      FILE *rawfp;
{
  int frame,mcepframe,pitchframe;
  int state,lw,rw,m,n;
  Model *mtmp;
  Boolean nobound;
  void mlpg (PStream *);
  void InitPStream (PStream *);
  void FreePStream (PStream *);

  mcepframe  = 0;
  pitchframe = 0;
 
  for (mtmp = mhead; mtmp != mtail ; mtmp = mtmp->next)
	  for (state = 2; state <= nstate + 1; state++)
		  for (frame = 1; frame <= mtmp->duration[state]; frame ++) {
			  voiced[mcepframe++] = mtmp->voiced[state];
			  if(mtmp->voiced[state]) {
				  pitchframe++;
			  }
		  }

  mceppst.T = mcepframe;
  pitchpst.T = pitchframe;
  
  InitPStream(&mceppst);
  InitPStream(&pitchpst);

  mcepframe  = 0;
  pitchframe = 0;

  for (mtmp = mhead; mtmp != mtail ; mtmp = mtmp->next) {
	  for (state = 2; state <= nstate + 1; state++) {
		  for (frame = 1; frame <= mtmp->duration[state]; frame ++) {
			  for (m = 0; m < mcepvsize; m++) {
				  mceppst.sm.mseq[mcepframe][m] = mtmp->mcepmean[state][m];
				  mceppst.sm.ivseq[mcepframe][m] = finv(mtmp->mcepvariance[state][m]);
			  }
			  for (m = 0; m < pitchstream; m++) {
				  lw = pitchpst.dw.width[m][WLEFT];
				  rw = pitchpst.dw.width[m][WRIGHT];
				  nobound = 1;
				  
				  for (n = lw; n <= rw;n++)
					  if (mcepframe + n < 0 || totalframe < mcepframe + n)
						  nobound = 0;
					  else
						  nobound &= voiced[mcepframe + n];
				  
				  if (voiced[mcepframe]) {
					  pitchpst.sm.mseq[pitchframe][m] = mtmp->pitchmean[state][m + 1];
					  if (nobound)
						  pitchpst.sm.ivseq[pitchframe][m] = finv(mtmp->pitchvariance[state][m + 1]);
					  else
						  pitchpst.sm.ivseq[pitchframe][m] = 0.0;
				  }
			  }
			  if (voiced[mcepframe])
				  pitchframe++;
			  alpha.data[mcepframe] = mtmp->phoneme->alpha;
			  mcepframe++;
		  }
	  }
  }

  mlpg(&mceppst);
  if (pitchframe > 0)
	  mlpg(&pitchpst);
  
  pitchframe = 0;

  for( mcepframe = 0; mcepframe < mceppst.T; mcepframe++ ) 
	  { 
		  mc2b( mceppst.par[mcepframe], coeff[mcepframe], mceppst.order, alpha.data[mcepframe] );
		  power.data[mcepframe] = coeff[mcepframe][0];
		  if(voiced[mcepframe])
			  {
				  f0.data[mcepframe] = pitchpst.par[pitchframe][0];
				  pitchframe++;
			  }
		  else
			  f0.data[mcepframe] = 0.0;
	  }

  FreePStream(&mceppst);
  FreePStream(&pitchpst);
}

void InitPStream(PStream *pst)
{
	double		*dcalloc(int);
	double		**ddcalloc(int,int);
	
	/* void InitDWin(PStream *); */

	/* InitDWin(pst); */
	
	pst->sm.mseq	= ddcalloc(pst->T, pst->vSize);

	pst->width	= pst->dw.max_L*2+1;     /* band width of WUW */

	pst->sm.ivseq	= ddcalloc(pst->T, pst->vSize);
	pst->sm.g	= dcalloc(pst->T);
	pst->sm.WUW	= ddcalloc(pst->T,pst->width);
	pst->sm.WUM	= dcalloc(pst->T);
	pst->par	= ddcalloc(pst->T,pst->order+1);
	
}

void FreePStream(PStream *pst)
{
	int t;

	for (t=0; t<pst->T; t++) {
		free(pst->sm.mseq[t]);
		free(pst->sm.ivseq[t]);
		free(pst->sm.WUW[t]);
		free(pst->par[t]);
	}
	
	free(pst->sm.mseq);
	free(pst->sm.ivseq);
	free(pst->sm.WUW);
	free(pst->sm.g);
	free(pst->sm.WUM);
	free(pst->par);
}

void InitDWin(PStream *pst)
{
        double *dcalloc (int);
	int str2darray (char *, double **);
	register int i, j;
	int fsize, leng;
	double x, s4, s2, s0;
	FILE *fp;

	/* memory allocation */
	if ((pst->dw.width = (int **) calloc (pst->dw.num, sizeof (int *))) == NULL)
    {
      ErrMsg("Memory allocation error !\n");
      exit (1);
    }
  for (i = 0; i < pst->dw.num; i++)
    if ((pst->dw.width[i] = (int *) calloc (2, sizeof (int))) == NULL)
      {
        ErrMsg("Memory allocation error !\n");
        exit(1);
      }
  if ((pst->dw.coef = (double **) calloc (pst->dw.num, sizeof (double *)))
      == NULL)
    {
      ErrMsg("Memory allocation error !\n");
      exit (1);
    }

  /* window for static parameter */
  pst->dw.width[0][WLEFT] = pst->dw.width[0][WRIGHT] = 0;
  pst->dw.coef[0] = dcalloc (1);
  pst->dw.coef[0][0] = 1;

  /* set delta coefficients */
  if (pst->dw.calccoef == 0)
    {
      for (i = 1; i < pst->dw.num; i++)
        {
          if (pst->dw.fn[i][0] == ' ')
	    {
              fsize = str2darray(pst->dw.fn[i], &(pst->dw.coef[i]));
            }
          else
	    {            /* read from file */
              if ((fp = fopen (pst->dw.fn[i], "r")) == NULL)
	        {
                  ErrMsg("file %s not found\n", pst->dw.fn[i]);
                  exit(1);
                }

              /* check the number of coefficients */
              fseek (fp, 0L, 2);
              fsize = ftell (fp) / sizeof (float);
              fseek (fp, 0L, 0);

              /* read coefficients */
              pst->dw.coef[i] = dcalloc (fsize);
              freadf (pst->dw.coef[i], sizeof (**(pst->dw.coef)), fsize, fp);
            }

          /* set pointer */
          leng = fsize / 2;
          pst->dw.coef[i] += leng;
          pst->dw.width[i][WLEFT] = -leng;
          pst->dw.width[i][WRIGHT] = leng;
          if (fsize % 2 == 0)
            pst->dw.width[i][WRIGHT]--;
        }
    }
  else if (pst->dw.calccoef == 1)
    {
      for (i = 1; i < pst->dw.num; i++)
        {
          leng = atoi(pst->dw.fn[i]);
          if (leng < 1)
	    {
              ErrMsg("Width for regression coefficient shuould be more than 1.\n");
              exit(1);
            }
          pst->dw.width[i][WLEFT] = -leng;
          pst->dw.width[i][WRIGHT] = leng;
          pst->dw.coef[i] = dcalloc (leng*2 + 1);
          pst->dw.coef[i] += leng;
        }

      leng = atoi (pst->dw.fn[1]);
      s2 = 1;
      for (j = 2; j <= leng; j++)
        {
          x = j * j;
          s2 += x;
        }
      s2 += s2;
      for (j = -leng; j <= leng; j++)
        pst->dw.coef[1][j] = j / s2;

      if (pst->dw.num > 2)
        {
          leng = atoi (pst->dw.fn[2]);
          s2 = s4 = 1;
          for (j = 2; j <= leng; j++)
	    {
              x = j * j;
              s2 += x;
              s4 += x * x;
            }
          s2 += s2;
          s4 += s4;
          s0 = leng + leng + 1;
          for (j = -leng; j <= leng; j++)
            pst->dw.coef[2][j] = (s0*j*j - s2)/(s4*s0 - s2*s2);
        }
    }

  pst->dw.maxw[WLEFT] = pst->dw.maxw[WRIGHT] = 0;
  for (i = 0; i < pst->dw.num; i++)
    {
      if (pst->dw.maxw[WLEFT] > pst->dw.width[i][WLEFT])
        pst->dw.maxw[WLEFT] = pst->dw.width[i][WLEFT];
      if (pst->dw.maxw[WRIGHT] < pst->dw.width[i][WRIGHT])
        pst->dw.maxw[WRIGHT] = pst->dw.width[i][WRIGHT];
    }

	/* calcurate max_L to determine size of band matrix */
	if( pst->dw.maxw[WLEFT] >= pst->dw.maxw[WRIGHT] )
		pst->dw.max_L = pst->dw.maxw[WLEFT];
	else
		pst->dw.max_L = pst->dw.maxw[WRIGHT];
	
}

double *dcalloc(int x)
{
	double		*ptr;

	if ((ptr = (double *) calloc(x, sizeof(*ptr))) == NULL) {
		fprintf(stderr, "Cannot Allocate Memory\n");
		exit(1);
	}
	return(ptr);
}

double **ddcalloc(int x, int y)
{
	register int	i;
	double		**ptr;

	if ((ptr = (double **) calloc(x, sizeof(*ptr))) == NULL) {
		fprintf(stderr, "Cannot Allocate Memory\n");
		exit(1);
	}
	for (i = 0; i < x; i++)
		ptr[i] = dcalloc(y);
	return(ptr);
}

int str2darray (c, x)
      char *c;
      double **x;
{
  int i, size, sp;
  char *p, *buf;

  while (isspace (*c))
    c++;
  if (*c == '\0')
    {
      *x = NULL;
      return (0);
    }

  size = 1;
  sp = 0;
  for (p = c; *p != '\0'; p++)
    {
      if (!isspace (*p))
        {
          if (sp == 1)
            {
              size++;
              sp = 0;
            }
        }
      else
        sp = 1;
    }
  if ((buf = calloc (strlen (c), sizeof (*buf))) == NULL)
    {
      ErrMsg("Memory allocation error !\n");
      exit (1);
    }

  if ((*x = calloc (size, sizeof (double))) == NULL)
    {
      ErrMsg("Memory allocation error !\n");
      exit (1);
    }

  for (i = 0; i < size; i++)
    (*x)[i] = strtod (c, &c);
  return (size);
}

/*****************************************************************
	calcurate parameter
*****************************************************************/

void mlpg(PStream *pst)
{
	void		calc_WUM_and_WUW(PStream *, int);
	void		cholesky(PStream *);
	void		cholesky_forward(PStream *);
	void		cholesky_backward(PStream *, int);
	
	register int	m;

	for( m = 0; m <= pst->order ; m++ )
		{
			calc_WUM_and_WUW(pst,m);
			cholesky(pst);
			cholesky_forward(pst);
			cholesky_backward(pst,m);
		}
}


/*----------------------------------------------------------------
	matrix calcuration functions
----------------------------------------------------------------*/

void calc_WUM_and_WUW( PStream *pst, int m )
{
	register int	i, j, k, l, n;
	double			wu;
	
	for( i = 0; i < pst->T; i++){

		pst->sm.WUM[i]		= pst->sm.ivseq[i][m] * pst->sm.mseq[i][m];
		pst->sm.WUW[i][0]	= pst->sm.ivseq[i][m];

		for( j = 1; j < pst->width; j++ )
			pst->sm.WUW[i][j]=0.0;
		
		for( j = 1; j < pst->dw.num; j++ ){

			for( k = pst->dw.width[j][0]; k <= pst->dw.width[j][1]; k++ ){
				n = i + k;
				if( (n >= 0) && (n < pst->T) && (pst->dw.coef[j][-k] != 0.0) ){
					l = j * (pst->order+1) + m;
					wu = pst->dw.coef[j][-k] * pst->sm.ivseq[n][l];
					pst->sm.WUM[i] += wu * pst->sm.mseq[n][l]; 
					
					for( l = 0; l < pst->width; l++ ){
						n = l - k;
						if( (n <= pst->dw.width[j][1]) && (i+l < pst->T) && (pst->dw.coef[j][n] != 0.0) )
							pst->sm.WUW[i][l] += wu * pst->dw.coef[j][n];
					}
				}
			}
		}
	}
}

void cholesky(PStream *pst)
{
	register int	i,j,k;
	
	pst->sm.WUW[0][0] = sqrt(pst->sm.WUW[0][0]);

	for( i = 1; i < pst->width; i++ )
		pst->sm.WUW[0][i] /= pst->sm.WUW[0][0];

	for( i = 1; i < pst->T; i++ ){
		for( j = 1 ; j < pst->width; j++ )
			if( i-j >= 0 )
				pst->sm.WUW[i][0] -= pst->sm.WUW[i-j][j] * pst->sm.WUW[i-j][j];

		pst->sm.WUW[i][0] = sqrt(pst->sm.WUW[i][0]);

		for( j = 1; j < pst->width; j++ ){
			for( k = 0; k < pst->dw.max_L; k++ )
				if( j != pst->width-1 )
					pst->sm.WUW[i][j] -= pst->sm.WUW[i-k-1][j-k] * pst->sm.WUW[i-k-1][j+1];

			pst->sm.WUW[i][j] /= pst->sm.WUW[i][0];
		}
	}
}


void cholesky_forward(PStream *pst)
{
	register int	i, j;
	double			hold;

	pst->sm.g[0] = pst->sm.WUM[0] / pst->sm.WUW[0][0];

	for( i=0; i < pst->T; i++ ){
		hold = 0.0;
		for( j = 1; j < pst->width; j++ ){
			if( i - j >= 0 )
				hold += pst->sm.WUW[i-j][j] * pst->sm.g[i-j];
		}
		pst->sm.g[i] = ( pst->sm.WUM[i]-hold) / pst->sm.WUW[i][0];
	}
}

void cholesky_backward(PStream *pst, int m)
{
	register int	i,j;
	double			hold;
	
	pst->par[pst->T-1][m] = pst->sm.g[pst->T-1] / pst->sm.WUW[pst->T-1][0];

	for( i = pst->T-2; i >= 0; i-- ){
		hold = 0.0;

		for( j = 1; j < pst->width; j++ ){
			if( pst->sm.WUW[i][j] != 0.0 )
				hold += pst->sm.WUW[i][j] * pst->par[i+j][m];
		}
		
		pst->par[i][m] = ( pst->sm.g[i] - hold ) / pst->sm.WUW[i][0];
	}
}

