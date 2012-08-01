/* Copyright (c) 2000-2006                             */
/*   Takao Kobayashi, Takashi Masuko, Masatsune Tamura */
/*   (Tokyo Institute of Technology)                   */
/*   Keiichi Tokuda, Takayoshi Yoshimura, Heiga Zen    */
/*   (Nagoya Institute of Technology)                  */
/*   All rights reserved                               */
/* $Id: model.c,v 1.10 2006/10/19 03:27:08 sako Exp $                                                */

/************************************************************************
*									*
*    Model read functions						*
*									*
*					2000.5 M.Tamura			*
*									*
************************************************************************/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "synthesis.h"
#include "misc.h"
#include "model.h"
#include "tree.h"
#include "defaults.h"
#include "confpara.h"
#include "hmmsynth.h"

int TmpMsg(char *,...);
int ErrMsg(char *,...);

int xfread( void *, int, int, FILE *);
int ByteSwap( void *, int, int);

void ReadModelFile (int sid)
{
  int i,j,k;
  int ndurpdf, *nmceppdf, *npitchpdf;

  xfread (&nstate, sizeof (int), 1, durmodel);
  xfread (&ndurpdf, sizeof (int), 1, durmodel);

  if ((mset[sid].durpdf = (float **) calloc (ndurpdf, sizeof (float *))) == NULL)
    {
      ErrMsg("Memory allocation error !\n");
      exit (1);
    }

  mset[sid].durpdf--;
  for (i=1; i<=ndurpdf; i++)
    {
      if ((mset[sid].durpdf[i] = (float *) calloc (nstate*2, sizeof (float))) == NULL)
        {
          ErrMsg("Memory allocation error !\n");
          exit (1);
        }

      xfread (mset[sid].durpdf[i], sizeof (float), nstate*2, durmodel);
      mset[sid].durpdf[i] -=2;
    }

  xfread (&mcepvsize, sizeof (int), 1, mcepmodel);
  if ((nmceppdf = (int *) calloc (nstate, sizeof (int))) == NULL)
    {
      ErrMsg("Memory allocation error !\n");
      exit (1);
    }

  xfread (nmceppdf, sizeof (int), nstate, mcepmodel);
  nmceppdf -= 2;
  if ((mset[sid].mceppdf = (float ***) calloc (nstate, sizeof (float **))) == NULL)
    {
      ErrMsg("Memory allocation error !\n");
      exit (1);
    }

  mset[sid].mceppdf -= 2;
  for (i=2; i<=nstate+1; i++)
    {
      if ((mset[sid].mceppdf[i] = (float **) calloc (nmceppdf[i], sizeof (float *))) == NULL)
        {
          ErrMsg("Memory allocation error !\n");
          exit (1);
        }

      mset[sid].mceppdf[i]--;
      for (j=1; j<=nmceppdf[i]; j++)
        {
          if ((mset[sid].mceppdf[i][j] = (float *) calloc (mcepvsize*2, sizeof (float))) == NULL)
            {
              ErrMsg("Memory allocation error !\n");
              exit (1);
            }

          xfread(mset[sid].mceppdf[i][j], sizeof (float), mcepvsize*2, mcepmodel);
        }
     } 

  xfread (&pitchstream, sizeof (int), 1, pitchmodel);
  if ((npitchpdf = (int *) calloc (nstate, sizeof (int))) == NULL)
    {
      ErrMsg("Memory allocation error !\n");
      exit (1);
    }

  xfread (npitchpdf, sizeof (int), nstate, pitchmodel);
  npitchpdf -= 2;
  if ((mset[sid].pitchpdf = (float ****) calloc (nstate, sizeof (float ***))) == NULL)
    {
      ErrMsg("Memory allocation error !\n");
      exit (1);
    }

  mset[sid].pitchpdf -= 2;
  for (i=2; i<=nstate+1; i++)
    {
      if ((mset[sid].pitchpdf[i] = (float ***) calloc (npitchpdf[i], sizeof (float **))) == NULL)
        {
          ErrMsg("Memory allocation error !\n");
          exit (1);
        }

      mset[sid].pitchpdf[i]--;
      for (j=1; j<=npitchpdf[i]; j++)
        {
          if ((mset[sid].pitchpdf[i][j] = (float **) calloc (pitchstream, sizeof (float *))) == NULL)
            {
              ErrMsg("Memory allocation error !\n");
              exit (1);
            }
  
          mset[sid].pitchpdf[i][j]--;
          for (k=1; k<=pitchstream; k++)
            {
              if ((mset[sid].pitchpdf[i][j][k] = (float *) calloc (4, sizeof (float))) == NULL)
                {
                  ErrMsg("Memory allocation error !\n");
                  exit (1);
                }

              xfread(mset[sid].pitchpdf[i][j][k], sizeof (float), 4, pitchmodel);
            }
        }
     } 


#ifdef DEBUG
  printf ("nstate = %d\n", nstate);
  printf ("mcepvsize = %d\n", mcepvsize);
  printf ("pitchstream = %d\n", pitchstream);
#endif
}

void SearchDurationPDF (m, sid)
      Model *m;
      int sid;
{
  float diffdur,data;
  int state, num;
  char *c;

#ifdef DEBUG
  TmpMsg("durpdf=%s\n", m->dufpdf);
#endif

  c = strrchr (m->durpdf, '_') + 1;
  num = atoi(c);

  if ((m->duration = (int *) calloc (nstate, sizeof (int))) == NULL)
    {
      ErrMsg("Memory allocation error !\n");
      exit (1);
    }

  m->duration -= 2;
  diffdur = 0;
  m->totalduration = 0;
  m->durmean = mset[sid].durpdf[num];
  m->durvariance = mset[sid].durpdf[num]+nstate;
  for(state = 2; state <= nstate + 1; state++)
    {
      data = m->durmean[state];
      m->duration[state] = (int) (data + diffdur + 0.5);
      m->totalduration += m->duration[state];
      diffdur += data - (float) m->duration[state];

#ifdef DEBUG
      TmpMsg("duration state%d = %d\n", 
                       state, m->duration[state]);

#endif
    }
}

void SearchPitchPDF (m,state,sid)
     Model *m;
     int state, sid;
{
  int num, stream;
  char *c;
  float *weight;

  c = strrchr (m->pitchpdf[state], '_') + 1;
  num = atoi(c);

  if ((m->pitchmean[state] = (float *) calloc (pitchstream, sizeof (float))) == NULL)
    {
      ErrMsg("Memory allocation error !\n");
      exit (1);
    }

  m->pitchmean[state]--;
  if ((m->pitchvariance[state] = (float *) calloc (pitchstream, sizeof (float))) == NULL)
    {
      ErrMsg("Memory allocation error !\n");
      exit (1);
    }

  m->pitchvariance[state]--;

  for (stream = 1; stream <= pitchstream; stream++)
    {
      m->pitchmean[state][stream] = mset[sid].pitchpdf[state][num][stream][0];
      m->pitchvariance[state][stream] = mset[sid].pitchpdf[state][num][stream][1];
      weight = mset[sid].pitchpdf[state][num][stream]+2;
      if(stream == 1)
        {
          if(weight[0] > weight[1])
            m->voiced[state] = TR;
          else
            m->voiced[state] = FA;
        }
    }

#ifdef DEBUG
  TmpMsg("pitchpdf = %s\n", m->pitchpdf[state]);
  TmpMsg("pitch state[%d]\n", state);
  TmpMsg("\tmean: %8e, %8e, %8e\n",
           m->pitchmean[state][1],
           m->pitchmean[state][2],
           m->pitchmean[state][3]);
  TmpMsg("\tvariance: %8e, %8e, %8e\n",
           m->pitchvariance[state][1],
           m->pitchvariance[state][2],
           m->pitchvariance[state][3]);
  TmpMsg("\tweight: %8e, %8e: voiced = %d\n",
           weight[0], weight[1], m->voiced[state]);
#endif

}

void SearchMcepPDF (m,state,sid)
     Model *m;
     int state, sid;
{
  int num;
  char *c;

  c = strrchr (m->mceppdf[state], '_') + 1;
  num = atoi(c);

  m->mcepmean[state] = mset[sid].mceppdf[state][num];
  m->mcepvariance[state] = mset[sid].mceppdf[state][num]+mcepvsize;

#ifdef DEBUG
  TmpMsg("mceppdf state%d = %s\n", state, m->mceppdf[state]);

  TmpMsg("mcep state[%d]\n", state);
  TmpMsg("\tmean: %8e", m->mcepmean[state][1]);
  for (i = 2; i <= mcepvsize; i++)
    TmpMsg(" %8e", m->mcepmean[state][i]);
  TmpMsg("\n");
  TmpMsg("\tvariance:%8e", m->mcepvariance[state][1]);
  for (i = 2; i <= mcepvsize; i++)
    TmpMsg(" %8e",m->mcepvariance[state][i]);
  TmpMsg("\n");
#endif
}

