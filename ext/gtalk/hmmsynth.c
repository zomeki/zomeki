/* Copyright (c) 2000-2006                             */
/*   Takao Kobayashi, Takashi Masuko, Masatsune Tamura */
/*   (Tokyo Institute of Technology)                   */
/*   Keiichi Tokuda, Takayoshi Yoshimura, Heiga Zen    */
/*   (Nagoya Institute of Technology)                  */
/*   All rights reserved                               */
/*                                                     */
/*  $Id: hmmsynth.c,v 1.13 2006/10/19 03:27:08 sako Exp $                                               */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "synthesis.h"
#include "confpara.h"
#include "defaults.h"
#include "misc.h"
#include "model.h"
#include "mlpg.h"
#include "vocoder.h"
#include "tree.h"
#include "hmmsynth.h"

int TmpMsg(char *,...);
int ErrMsg(char *,...);
void restart(int);

#if defined(WIN32) || defined(USE_CHASENLIB)
int snprintf( char *, size_t, char *, ... );
#endif

void init_hmmsynth()
{
  FILE *fp;
  int sid;

/* read tree file */
  for (sid = 0;sid < n_speaker; sid++)
    {
      fp = getfp (speaker[sid].dur_tree_file ,"r");
      ReadTreeFile (fp, DURATION, sid);
      fclose(fp);
      fp = getfp (speaker[sid].pit_tree_file ,"r");
      ReadTreeFile (fp, PITCH, sid);
      fclose(fp);
      fp = getfp (speaker[sid].mcep_tree_file ,"r");
      ReadTreeFile (fp, MCEP, sid);
      fclose(fp);

/* read model file */
      durmodel = getfp (speaker[sid].dur_model_file, "rb");
      pitchmodel = getfp (speaker[sid].pit_model_file, "rb");
      mcepmodel = getfp (speaker[sid].mcep_model_file, "rb");
      ReadModelFile (sid);
      fclose(durmodel);
      fclose(pitchmodel);
      fclose(mcepmodel);
    }

/* set delta window for mlpg */
  if ((pitchpst.dw.fn = (char **) calloc (sizeof (char *), 3)) == NULL)
    {
      ErrMsg("Memory allocation erorr !  (in init_hmmsynth)\n");
      exit(1);
    }

  pitchpst.dw.fn[1] = strdup (DELTAWIN);
  pitchpst.dw.fn[2] = strdup (ACCWIN);
  pitchpst.dw.num = 3;
  pitchpst.dw.calccoef = 0;
  pitchpst.vSize = pitchstream;
  InitDWin (&pitchpst);

  if ((mceppst.dw.fn = (char **) calloc (sizeof (char *), 3)) == NULL)
    {
       ErrMsg("Memory allocation error !  (in init_hmmsynth)\n");
       exit(1);
    }

  mceppst.dw.fn[1] = strdup (DELTAWIN);
  mceppst.dw.fn[2] = strdup (ACCWIN);
  mceppst.dw.num = 3;
  mceppst.dw.calccoef = 0;
  mceppst.vSize = mcepvsize;
  
  InitDWin (&mceppst);

  mceppst.order = mceppst.vSize / mceppst.dw.num - 1;
/* vocoder */
  init_vocoder (mceppst.order);
}

void refresh_hmmsynth()
{
  int i;
  Model *m,*next;

  if(f0.data == NULL)return;
  free (f0.data);
  f0.data = NULL;
  free (power.data);
  free (alpha.data);
  free (wave.data);
  for (i = 0; i <= totalframe; i++)
    {
      free (mcep[i]);
      free (coeff[i]);
    }
  free(mcep);
  free(coeff);
  free(voiced);

  m = mhead;
  while (m)
    {
      next = m->next;
      free (m->name);
      free (m->durpdf);
      free (m->duration + 2);
      for ( i = 2; i<= nstate + 1; i++)
        {
           free (m->pitchmean[i] + 1);
           free (m->pitchvariance[i] + 1);
        }
      free (m->pitchpdf + 2);
      free (m->pitchmean + 2);
      free (m->pitchvariance + 2);
      free (m->voiced + 2);
      free (m->mceppdf + 2);
      free (m->mcepmean + 2);
      free (m->mcepvariance + 2);
      free (m);
      m = next;
    }
    mhead = mtail = NULL;
    refresh_vocoder();
}

char *id2str(int i)
{
  static char buff[5];

  if(i<0)
    return("x");
  else {
    sprintf(buff,"%d",i);
    return buff;
  }
}

void make_context_label (PHONEME *p,char *buff)
{
  MORA *mr;
  MORPH *mp;
  APHRASE *a;
  BREATH *b;
  SENTENCE *s;
  char tmp_buff[64];

  mr = p->parent;
  mp = mr->parent;
  a = mp->parent;
  b = a->parent;
  s = b->parent;

		/* phoneme-previous */
  if (mr->silence != SILB)
    snprintf (buff, sizeof(tmp_buff), "%s-", p->prev->phoneme);
  else 
    snprintf (buff, sizeof(tmp_buff), "x-");

		/* phoneme-center */
  strncat( buff, p->phoneme, strlen( p->phoneme));

		/* phoneme-next */
  if (mr->silence != SILE){
    strncat( buff, "+", 1);
    strncat( buff, p->next->phoneme, strlen( p->next->phoneme));
  }
  else{
    strncat( buff, "+x", 2);
  }
    
		/* mora */
  strncat( buff, "/A:", 3);
  if (mr->silence == NON){
    snprintf( tmp_buff, sizeof(tmp_buff), "%d_", mr->position);
    strncat( buff, tmp_buff, strlen( tmp_buff));
  }
  else{
    strncat( buff, "x_", 2);
  }
  if (mr->silence == NON){
    snprintf( tmp_buff, sizeof(tmp_buff), "%d", mr->acdist);
    strncat( buff, tmp_buff, strlen( tmp_buff));
  }
  else{
    strncat( buff, "x", 1);
  }

		/* morph-previous */
  strncat( buff, "/B:", 3);
  if (mp->silence == SILB || mp->prev->silence == SILB){
    strncat( buff, "x_x_x", 5);
  }
  else if (mp->prev->silence == PAU) {
    snprintf( tmp_buff, sizeof(tmp_buff), "%s_%s_%s",
	      id2str(mp->prev->prev->hinshiID),
	      id2str(mp->prev->prev->katsuyogataID),
	      id2str(mp->prev->prev->katsuyokeiID));
    strncat( buff, tmp_buff, strlen( tmp_buff));
  } else {
    snprintf( tmp_buff, sizeof(tmp_buff), "%s_%s_%s",
	      id2str(mp->prev->hinshiID),
	      id2str(mp->prev->katsuyogataID),
	      id2str(mp->prev->katsuyokeiID));
    strncat( buff, tmp_buff, strlen( tmp_buff));
  }

		/* morph-center */
  strncat( buff, "-", 1);
  if ( mp->silence == NON) {
    snprintf( tmp_buff, sizeof(tmp_buff), "%s_%s_%s",
	      id2str(mp->hinshiID), 
	      id2str(mp->katsuyogataID),
	      id2str(mp->katsuyokeiID));
    strncat( buff, tmp_buff, strlen( tmp_buff));
    
  } else{
    strncat( buff, "x_x_x", 5);
  }

		/* morph-next */
  strncat( buff, "+", 1);
  if (mp->silence == SILE || mp->next->silence == SILE){
    strncat( buff, "x_x_x", 5);
  }
  else if (mp->next->silence == PAU) {
    snprintf( tmp_buff, sizeof(tmp_buff), "%s_%s_%s",
	      id2str(mp->next->next->hinshiID),
	      id2str(mp->next->next->katsuyogataID),
	      id2str(mp->next->next->katsuyokeiID));
    strncat( buff, tmp_buff, strlen( tmp_buff));
  } else {
    snprintf( tmp_buff, sizeof(tmp_buff), "%s_%s_%s",
	      id2str(mp->next->hinshiID),
	      id2str(mp->next->katsuyogataID),
	      id2str(mp->next->katsuyokeiID));
    strncat( buff, tmp_buff, strlen( tmp_buff));
  }

		/* aphrase-previous */
  strncat( buff, "/C:", 3);
  if (a->silence == SILB || a->prev->silence == SILB){
    strncat( buff, "x_x", 3);
  }
  else if (a->prev->silence == PAU){
    snprintf( tmp_buff, sizeof(tmp_buff), "%d_%d",
	      a->prev->prev->nmora,
	      a->prev->prev->accentType);
    strncat( buff, tmp_buff, strlen( tmp_buff));
  }
  else{
    snprintf( tmp_buff, sizeof(tmp_buff), "%d_%d",
	      a->prev->nmora,
	      a->prev->accentType);
    strncat( buff, tmp_buff, strlen( tmp_buff));
  }

  strncat( buff, "_x", 2);
  if ( a->silence == NON)
    {
      if (a->prev->silence == PAU){
	strncat( buff, "_1", 2);
      }
      else{
	strncat( buff, "_0", 2);
      }
    }
  else{
    strncat( buff, "_x", 2);
  }

		/* aphrase-center */
  strncat( buff, "-", 1);
  if ( a->silence == NON){
    snprintf( tmp_buff, sizeof(tmp_buff), "%d_%d_x_%d_%d", 
	     a->nmora, a->accentType, a->position, a->interrogative);
    strncat( buff, tmp_buff, strlen( tmp_buff));
  }
  else{
    strncat( buff, "x_x_x_x_x", 9);
  }
  strncat( buff, "+", 1);

		/* aphrase-next */
  if (a->silence == SILE || a->next->silence == SILE){
    strncat( buff, "x_x", 3);
  }
  else if (a->next->silence == PAU){
    snprintf( tmp_buff, sizeof(tmp_buff), "%d_%d",
	      a->next->next->nmora, a->next->next->accentType);
    strncat( buff, tmp_buff, strlen( tmp_buff));
  }
  else{
    snprintf( tmp_buff, sizeof(tmp_buff), "%d_%d",
	      a->next->nmora, a->next->accentType);
    strncat( buff, tmp_buff, strlen( tmp_buff));
  }

  strncat( buff, "_x", 2);
  if ( a->silence == NON)
    {
      if (a->next->silence == PAU){
	strncat( buff, "_1", 2);
      }
      else{
	strncat( buff, "_0", 2);	
      }
    }
  else{
    strncat( buff, "_x", 2);
  }

		/* breath-prev */
  strncat( buff, "/D:", 3);

  if (b->silence == SILB || b->prev->silence == SILB){
    strncat( buff, "x", 1);
  }
  else if (b->prev->silence == PAU){
    snprintf( tmp_buff, sizeof(tmp_buff), "%d", b->prev->prev->nmora);
    strncat( buff, tmp_buff, strlen( tmp_buff));
  }
  else{
    snprintf( tmp_buff, sizeof(tmp_buff), "%d", b->prev->nmora);
    strncat( buff, tmp_buff, strlen( tmp_buff));
  }
		/* breath-center */

  strncat( buff, "-", 1);

  if (b->silence == NON){
    snprintf( tmp_buff, sizeof(tmp_buff), "%d_%d",  b->nmora, b->position);
    strncat( buff, tmp_buff, strlen( tmp_buff));
  }
  else if (b->silence == PAU){
    snprintf( tmp_buff, sizeof(tmp_buff), "%x_d%d",  b->nmora, b->prev->position);
    strncat( buff, tmp_buff, strlen( tmp_buff));
  }
  else {
    strncat( buff, "x_x", 3);
  }
  strncat( buff, "+", 1);

		/* breath-next */
  if (b->silence == SILE || b->next->silence == SILE){
    strncat( buff, "x", 1);
  }
  else if (b->next->silence == PAU){
    snprintf( tmp_buff, sizeof(tmp_buff), "%d", b->next->next->nmora);
    strncat( buff, tmp_buff, strlen( tmp_buff));
  }
  else{
    snprintf (tmp_buff, sizeof(tmp_buff), "%d", b->next->nmora);
    strncat( buff, tmp_buff, strlen( tmp_buff));
  }

		/* sentence */
  snprintf( tmp_buff, sizeof(tmp_buff), "/E:%d", s->nmora);
  strncat( buff, tmp_buff, strlen(tmp_buff));

  strncat( buff, "\0", 1);

#ifdef PRINTDATA
  TmpMsg("%s\n",buff);
#endif
}

void init_parameter(){
  PHONEME *ph;
  char label[1024];
  if((mhead = (Model *) calloc (1, sizeof (Model))) == NULL)
    {
      ErrMsg("Memory allocation error !  (in init_parameter)\n");
      restart(1);
    }
  mtail = mhead;
  ph = phhead;
  for (;;)
    {
      make_context_label(ph,label);
      mtail->name = strdup (label);
      mtail->phoneme = ph;

      if (ph == phtail) break;
      ph = ph->next;
      if ((mtail->next = (Model *) calloc (1, sizeof (Model))) == NULL)
        {
          ErrMsg("Memory allocation error !  (in init_parameter)\n");
          restart(1);
        }

      mtail = mtail->next;
    }
}
