/* Copyright (c) 2000-2006                             */
/*   Takao Kobayashi, Takashi Masuko, Masatsune Tamura */
/*   (Tokyo Institute of Technology)                   */
/*   Keiichi Tokuda, Takayoshi Yoshimura, Heiga Zen    */
/*   (Nagoya Institute of Technology)                  */
/*   All rights reserved                               */
/*                                                     */
/*   $Id: make_parameter.c,v 1.9 2006/10/19 03:27:08 sako Exp $                                              */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "synthesis.h"
#include "defaults.h"
#include "misc.h"
#include "model.h"
#include "tree.h"
#include "mlpg.h"
#include "confpara.h"
#include "hmmsynth.h"

int TmpMsg(char *,...);
int ErrMsg(char *,...);
void restart(int);

void make_parameter()
{
   Model *m;
   Tree *t;
   int state, nframe, i, sid;

   m = mhead;
   nframe = 0;
   for (;;)
     {
/* search pdfs */
       state = 2;
       sid = m->phoneme->sid;
       if ((m->pitchpdf = (char **) calloc (nstate, sizeof (char *))) == NULL)
         {
           ErrMsg("Memory allocation error !  (in make_parameter)\n");
           restart(1);
         }

       if ((m->pitchmean = (float **) calloc (nstate, sizeof (float *))) == NULL)
         {
           ErrMsg("Memory allocation error !  (in make_parameter)\n");
           restart(1);
         }

       if ((m->pitchvariance = (float **) calloc (nstate, sizeof (float *))) == NULL)
         {
           ErrMsg("Memory allocation error !  (in make_parameter)\n");
           restart(1);
         }

       if ((m->voiced = (Boolean *) calloc (nstate, sizeof (Boolean))) == NULL)
         {
           ErrMsg("Memory allocation error !  (in make_parameter)\n");
           restart(1);
         }

 
       m->pitchpdf -= 2;
       m->pitchmean -= 2;
       m->pitchvariance -= 2;
       m->voiced -= 2;
       for (t = mset[sid].thead[PITCH]; t != mset[sid].ttail[PITCH]; t = t->next)
         {
            m->pitchpdf[state] = strdup (TraverseTree (m->name,
                                                           t->parent));
            SearchPitchPDF (m, state, sid);
            state++;
          }

       state = 2;
       if ((m->mceppdf = (char **) calloc (nstate, sizeof (char *))) == NULL )
         {
           ErrMsg("Memory allocation error !  (in make_parameter)\n");
           restart(1);
         }

       if ((m->mcepmean = (float **) calloc (nstate, sizeof (float *))) == NULL)
         {
           ErrMsg("Memory allocation error !  (in make_parameter)\n");
           restart(1);
         }

       if ((m->mcepvariance = (float **) calloc (nstate, sizeof (float *))) == NULL)
         {
           ErrMsg("Memory allocation error !  (in make_parameter)\n");
           restart(1);
         }

       m->mceppdf -= 2;
       m->mcepmean -= 2;
       m->mcepvariance -= 2;
       for (t = mset[sid].thead[MCEP]; t != mset[sid].ttail[MCEP]; t = t -> next)
         {
           m->mceppdf[state] = strdup (TraverseTree (m->name,
                                                         t->parent));
           SearchMcepPDF (m, state, sid);
           state++;
         }
#ifdef DEBUG
       TmpMsg("%d %d %s\n", nframe, nframe + m->totalduration, m->name);
#endif
       nframe += m->totalduration;
       if (m == mtail) break;
       m = m->next;
     }

/* parameter generation */
     totalframe = nframe;
     f0.rate = FRAME_RATE;
     if ((f0.data = (double *) calloc (totalframe + 1, sizeof (double))) == NULL)
       {
         ErrMsg("Memory allocation error !  (in make_parameter)\n");
         restart(1);
       }

     power.rate = FRAME_RATE;
     if ((power.data = (double *) calloc (totalframe + 1, sizeof (double))) == NULL)
       {
         ErrMsg("Memory allocation error !  (in make_parameter)\n");
         restart(1);
       }

     alpha.rate = FRAME_RATE;
     if ((alpha.data = (double *) calloc (totalframe + 1, sizeof (double))) == NULL)
       {
         ErrMsg("Memory allocation error !  (in make_parameter)\n");
         restart(1);
       }


     if ((mcep = (double **) calloc (totalframe + 1, sizeof (double *))) == NULL)
       {
         ErrMsg("Memory allocation error !  (in make_parameter)\n");
         restart(1);
       }

     if ((coeff = (double **) calloc (totalframe + 1, sizeof (double *))) == NULL)
       {
         ErrMsg("Memory allocation error !  (in make_parameter)\n");
         restart(1);
       }

     if ((voiced = (Boolean *) calloc (totalframe +1, sizeof (Boolean))) == NULL)
       {
         ErrMsg("Memory allocation error !  (in make_parameter)\n");
         restart(1);
       }

     for (i=0; i <= totalframe; i++)
       {
         if ((mcep[i] = (double *) calloc (mceppst.order + 1, sizeof (double))) == NULL)
           {
             ErrMsg("Memory allocation error !  (in make_parameter)\n");
             restart(1);
           }

         if ((coeff[i] = (double *) calloc (mceppst.order + 1, sizeof (double))) == NULL)
           {
             ErrMsg("Memory allocation error !  (in make_parameter)\n");
             restart(1);
           }

 
       }
     GenerateParam(stdout);
/*
     for (i=0; i <= totalframe; i++)
     	f0.data[i] = (f0.data[i] == 0.0)? 0:f0.data[i]+log(2.0);
*/
}

