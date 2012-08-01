/* Copyright (c) 2000-2006                             */
/*   Takao Kobayashi, Takashi Masuko, Masatsune Tamura */
/*   (Tokyo Institute of Technology)                   */
/*   Keiichi Tokuda, Takayoshi Yoshimura, Heiga Zen    */
/*   (Nagoya Institute of Technology)                  */
/*   All rights reserved                               */
/*                                                     */
/* $Id: vocoder.c,v 1.8 2006/10/19 03:27:08 sako Exp $                                                */

/************************************************************************
*									*
*   mel-cepstral vocoder (pulse/noise excitation & MLSA filter)		*
*									*
*					2000.9 M.Tamura			*
*									*
***********************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "synthesis.h"
#include "defaults.h"
#include "misc.h"
#include "model.h"
#include "vocoder.h"

int ErrMsg(char *,...);

int fprd = FPERIOD, iprd = IPERIOD, seed = SEED, pd = PADEORDER;
long next = SEED;
Boolean gauss = GAUSS;
double p1, pc;
double *ppade;
static double *c,*cc,*cinc,*d1;
int nsample;
static double pade[] = {1.0,
                        1.0, 0.0,
                        1.0, 0.0,       0.0,
                        1.0, 0.0,       0.0,       0.0,
                        1.0, 0.4999273, 0.1067005, 0.01170221, 0.0005656279,
                        1.0, 0.4999391, 0.1107098, 0.01369984, 0.0009564853, 0.00003041721 };

void init_vocoder (m)
      int m;
{
  if ((c = (double *)calloc(3*(m+1)+3*(pd+1)+pd*(m+2),sizeof(double))) == NULL)
    {
      ErrMsg("Memory allocation error !\n");
      exit (1);
    }

  p1 = -1;
  nsample = 0;
}

void refresh_vocoder ()
{
  p1 = -1;
  nsample = 0;
}

void vocoder (p,b,m,a,pf)
      double p,*b,a,pf;
      int m;
{
  double inc,x,e1,e2;
  int i,j,k;
  double beta = pf;
  if (p!=0.0) p = SAMPLE_RATE / exp(p);
  if (p1 < 0)
    {
      if(gauss & (seed  != 1)) next = srnd ((unsigned)seed);
      p1 = p;
      pc = p1;
      cc = c + m + 1;
      cinc = cc + m + 1;
      d1 = cinc + m + 1;
      for(k=0;k<=m;k++)
        c[k] = b[k];
      if ((beta > 0.0) && (m > 1)) {
        e1 = b2en(c, m, a);
        c[1] -= beta * a * b[2];
        for(k=2;k<=m;k++)
          c[k] *= (1.0 + beta);
        e2 = b2en(c, m, a);
        c[0] += log(e1/e2)/2;
      }
      return;
    }

  for(k=0;k<=m;k++)
    cc[k] = b[k];
  if ((beta > 0.0) && (m > 1)) {
    e1 = b2en(cc, m, a);
    cc[1] -= beta * a * b[2];
    for(k=2;k<=m;k++)
      cc[k] *= (1.0 + beta);
    e2 = b2en(cc, m, a);
    cc[0] += log(e1/e2)/2;
  }
  for(k=0;k<=m;k++)
    cinc[k] = (cc[k] - c[k]) * (double) iprd / (double) fprd;

  if(p1 != 0.0 && p != 0.0)
    inc = (p - p1) * (double) iprd / (double) fprd;
  else
    {
      inc = 0.0;
      pc = p;
      p1 = 0.0;
    }

  for (j=fprd, i=(iprd+1)/2; j--;)
    {
      if (p1 == 0.0)
        {
          if (gauss)
             x = (double) nrandom (&next);
          else
             x = mseq ();
        }
      else
        {
          if ((pc += 1.0) >= p1)
            {
              x = sqrt (p1);
              pc = pc - p1;
            }
          else
              x = 0.0;
        }

      x *= exp(c[0]);

      x = mlsadf(x,c,m,a,pd,d1);
      wave.data[nsample++] = (short) x;

      if (!--i)
        {
          p1 += inc;
          for (k=0;k<=m;k++) c[k] += cinc[k];
          i = iprd;
        }
    }
  p1 = p;
  movem(cc,c,sizeof(*cc),m+1);
}

double mlsadf(x, b, m, a, pd, d)
      double x, *b, *d, a;
      int m, pd;
{
  double mlsadf1 (), mlsadf2 ();

  ppade = &pade[pd*(pd+1) / 2];
    
  x = mlsadf1 (x, b, m, a, pd, d);
  x = mlsadf2 (x, b, m, a, pd, &d[2*(pd+1)]);

  return (x);
}

double mlsadf1 (x, b, m, a, pd, d)
      double x, *b, *d, a;
      int m, pd;
{
  double v, out = 0.0, *pt, aa;
  register int i;

  aa = 1 - a*a;
  pt = &d[pd+1];

  for(i=pd; i>=1; i--)
    {
      d[i] = aa*pt[i-1] + a*d[i];
      pt[i] = d[i] * b[1];
      v = pt[i] * ppade[i];
		
      x += (1 & i) ? v : -v;
      out += v;
    }
	
  pt[0] = x;
  out += x;
	
  return(out);
}

double mlsadf2 (x, b, m, a, pd, d)
      double x, *b, *d, a;
      int m, pd;
{
  double v, out = 0.0, *pt, aa, mlsafir();
  register int i;
    
  aa = 1 - a*a;
  pt = &d[pd * (m+2)];

	
  for (i=pd; i>=1; i--)
    {
      pt[i] = mlsafir (pt[i-1], b, m, a, &d[(i-1)*(m+2)]);
      v = pt[i] * ppade[i];

      x  += (1&i) ? v : -v;
      out += v;
    }
    
  pt[0] = x;
  out  += x;
	
  return(out);
}

double mlsafir (x, b, m, a, d)
      double x, *b, *d, a;
      int m;
{
  double y = 0.0, aa;
  register int i;
	
  aa = 1 - a*a;

  d[0] = x;
  d[1] = aa*d[0] + a*d[1];
	
  for (i=2; i<=m; i++)
    {
      d[i] = d[i] + a*(d[i+1]-d[i-1]);
      y += d[i]*b[i];
    }
	
  for (i=m+1; i>1; i--) d[i] = d[i-1];

	
  return (y);
}


int nrand (p, leng, seed)
      double *p;
      int leng, seed;
{
  int i;
  unsigned long next;

  if (seed != 1)
    next = srnd ((unsigned)seed);
  for (i=0;i<leng;i++)
    p[i] = (double)nrandom(&next);

  return (0);
}

double nrandom (next)
      unsigned long *next;
{
  static int sw = 0;
  static double r1, r2, s;

  if (sw == 0)
    {
      sw = 1;
      do  
        {
          r1 = 2 * rnd(next) - 1;
          r2 = 2 * rnd(next) - 1;
          s = r1 * r1 + r2 * r2;
        }
      while (s > 1 || s == 0);
      s = sqrt (-2 * log(s) / s);
      return ( r1 * s );
    }
  else
    {
      sw = 0;
      return ( r2 * s );
    }
}

double rnd (next)
      unsigned long *next;
{
  double r;

  *next = *next * 1103515245L + 12345;
  r = (*next / 65536L) % 32768L;

  return ( r / RND_MAX ); 
}

unsigned long srnd ( seed )
      unsigned seed;
{
  return (seed);
}


int mseq ()
{
  static int x = 0x55555555;
  register int x0, x28;

  x >>= 1;

  if (x & B0)
    x0 = 1;
  else
    x0 = -1;

  if (x & B28)
    x28 = 1;
  else
    x28 = -1;

  if (x0 + x28)
    x &= B31_;
  else
    x |= B31;

  return (x0);
}

void mc2b(mc, b, m, a)
double *mc, *b, a;
int m;
{
  b[m] = mc[m];
    
  for(m--; m>=0; m--)
    b[m] = mc[m] - a * b[m+1];
}

double b2en(b, m, a)
double *b, a;
int m;
{
  double en;
  int k;
  static double *mc = NULL, *cep, *ir;
  static int o = 0, irleng = IRLENG;

  if (o < m) {
    if (mc != NULL) {
      free(mc);
    }
    if ((mc = (double *)calloc((m+1)+2*irleng,sizeof(double))) == NULL) {
      ErrMsg("Memory allocation error !\n");
      exit (1);
    }
    cep = mc + m+1;
    ir = cep + irleng;
  }

  b2mc(b, mc, m, a);
  freqt(mc, m, cep, irleng-1, -a);
  c2ir(cep, irleng, ir, irleng);
  en = 0.0;
  for (k=0;k<irleng;k++)
    en += ir[k] * ir[k];

  return(en);
}

void b2mc(b, mc, m, a)
double *b, *mc, a;
int m;
{
  double d, o;
	
  d = mc[m] = b[m];
  for(m--; m>=0; m--){
    o = b[m] + a * d;
    d = b[m];
    mc[m] = o;
  }
}

void freqt(c1, m1, c2, m2, a)
double *c1, *c2, a;
int m1, m2;
{
    register int 	i, j;
    double		b;
    static double	*d = NULL, *g;
    static int		size;
    
    if(d == NULL){
	size = m2;
	if ((d = (double *)calloc(size+size+2, sizeof(double))) == NULL) {
            ErrMsg("Memory allocation error !\n");
            exit (1);
        }
	g = d + size + 1;
    }

    if(m2 > size){
	free(d);
	size = m2;
	if ((d = (double *)calloc(size+size+2, sizeof(double))) == NULL) {
            ErrMsg("Memory allocation error !\n");
            exit (1);
        }
	g = d + size + 1;
    }
    
    b = 1 - a*a;
    for (i = 0; i < m2+1; i++)
        g[i] = 0.0;

    for (i=-m1; i<=0; i++){
	if (0 <= m2)
	    g[0] = c1[-i] + a*(d[0] = g[0]);
	if (1 <= m2)
	    g[1] = b*d[0] + a*(d[1] = g[1]);
	for (j=2; j<=m2; j++)
	    g[j] = d[j-1] + a*((d[j]=g[j]) - g[j-1]);
    }
    
    movem(g, c2, sizeof(*g), m2+1);
}

void c2ir(c,nc,h,leng)
double 	*c,*h;
int 	leng,nc;
{
	register int	n, k, upl;
	double	d;

	h[0] = exp(c[0]);
	for(n = 1; n < leng; ++n) {
		d = 0;
		upl = (n >= nc) ? nc - 1 : n;
		for(k = 1; k <= upl; ++k)
			d += k * c[k] * h[n - k];
		h[n] = d / n;
	}
}

