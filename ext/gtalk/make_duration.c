/* Copyright (c) 2000-2006                             */
/*   Takao Kobayashi, Takashi Masuko, Masatsune Tamura */
/*   (Tokyo Institute of Technology)                   */
/*   Keiichi Tokuda, Takayoshi Yoshimura, Heiga Zen    */
/*   (Nagoya Institute of Technology)                  */
/*   All rights reserved                               */
/*                                                     */
/* $Id: make_duration.c,v 1.8 2007/07/12 06:10:45 sako Exp $                                                */

#include <stdio.h>
#include <string.h>
#include "synthesis.h"
#include "defaults.h"
#include "misc.h"
#include "model.h"
#include "tree.h"
#include "confpara.h"
#include "hmmsynth.h"

void make_duration(){
  PHONEME *p;
  Model *m;
  int sid;

  m = mhead;
  totalframe = 0;

  for (;;)
    {
      p = m->phoneme;
      sid = p->sid;
      m->durpdf = strdup(TraverseTree(m->name,mset[sid].thead[DURATION]->parent));
      SearchDurationPDF (m, sid);
      p->time = m->totalduration * FRAME_RATE;

      if (m == mtail) break;
      m = m->next;
    }
}
