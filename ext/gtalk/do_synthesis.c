/* Copyright (c) 2000-2006                             */
/*   Takao Kobayashi, Takashi Masuko, Masatsune Tamura */
/*   (Tokyo Institute of Technology)                   */
/*   Keiichi Tokuda, Takayoshi Yoshimura, Heiga Zen    */
/*   (Nagoya Institute of Technology)                  */
/*   All rights reserved                               */
/*                                                     */
/*  $Id: do_synthesis.c,v 1.13 2006/10/19 03:27:08 sako Exp $                                               */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "synthesis.h"
#include "defaults.h"
#include "misc.h"
#include "mlpg.h"
#include "vocoder.h"
#include "tree.h"
#include "confpara.h"
#include "hmmsynth.h"
#include "model.h"
#include "slot.h"

int ErrMsg(char *,...);
void restart(int);
void inqSpeakStat();
void do_auto_output();

extern int already_talked;

int synthesized_nsample;
int nsample_frame;

void do_synthesis()
{
  int nframe;
  int shift_start, shift_end;

  shift_start = mhead->totalduration - 
    ((int )(SILENCE_LENGTH / FRAME_RATE));
  shift_end = mtail->totalduration - 
    ((int )(SILENCE_LENGTH / FRAME_RATE));
  totalframe -= shift_end;
  
  wave.rate = SAMPLE_RATE;
  wave.nsample = SAMPLE_RATE * FRAME_RATE * (totalframe - shift_start) / 1000;

  if ((wave.data = (short *) calloc (wave.nsample, sizeof (short))) == NULL)
    {
      ErrMsg("Memory allocation error !\n");
      restart(1);
    }

#ifdef AUTO_DA
  nsample_frame = SAMPLE_RATE * FRAME_RATE  / 1000;
  synthesized_nsample = SAMPLE_RATE * FRAME_RATE * shift_start / 1000;
#endif

  already_talked = 0;
 
  for(nframe = shift_start; nframe < totalframe; nframe++)
    {
/* for power modification */ 
      coeff[nframe][0] = power.data[nframe];

/* MLSA filter */
      vocoder(f0.data[nframe],coeff[nframe],mceppst.order,alpha.data[nframe],speaker[spid].postfilter_coef);

#ifdef AUTO_DA
      synthesized_nsample += nsample_frame;
      if( nframe == shift_start && slot_Auto_play == YES )  {
        strcpy( slot_Speak_stat, "SPEAKING" );
        if( prop_Speak_stat == AutoOutput )  inqSpeakStat();
        do_auto_output();
      }
#endif
    }
  synthesized_nsample = wave.nsample;
  totalframe -= shift_start;
}

