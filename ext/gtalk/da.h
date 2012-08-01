/* Copyright (c) 2000-2006                             */
/*   Takao Kobayashi, Takashi Masuko, Masatsune Tamura */
/*   (Tokyo Institute of Technology)                   */
/*   Keiichi Tokuda, Takayoshi Yoshimura, Heiga Zen    */
/*   (Nagoya Institute of Technology)                  */
/*   All rights reserved                               */
/*                                                     */
/* $Id: da.h,v 1.9 2009/02/13 02:02:47 sako Exp $                                                */

#include <stdio.h>

#ifdef LINUX
#include <fcntl.h>
#include <sys/ioctl.h>
#include <sys/soundcard.h>
#define AUDIO_DEV_DEFAULT "/dev/dsp"
#define AUDIO_DEV_ENVNAME "AUDIODEV_GTALK"
#define MIXER_DEV    "/dev/mixer"
#define	MAXAMPGAIN	100
#define DEFAULT_FREQ	16
#endif /* LINUX */

#ifdef SOLARIS
#include <fcntl.h>
#include <sys/ioctl.h>
#include <sys/audioio.h>
#define AUDIO_DEV    "/dev/audio"
#define AUDIO_CTLDEV "/dev/audioctl"
#define	MAXAMPGAIN	255
#define AVAILABLE_FREQ "8,11.025,16,22.05,32,44.1,48"
#define DEFAULT_FREQ	16
#endif /* SOLARIS */

#define U_LAW 1
#define	A_LAW 2
#define	LINEAR 3

typedef struct _MENU {
        int      value;
        unsigned sample;
        unsigned precision;
        unsigned encoding;
} MENU;

static MENU data_type [] = {
  { 0, 0,       0, 0},
  { 1, 8000,    8, U_LAW},
  { 2, 8000,    8, A_LAW},
  { 3, 8000,   16, LINEAR},
  { 4, 9600,   16, LINEAR},
  { 5, 11025,  16, LINEAR},
  { 6, 16000,  16, LINEAR},
  { 7, 18900,  16, LINEAR},
  { 8, 22050,  16, LINEAR},
  { 9, 32000,  16, LINEAR},
  {10, 37800,  16, LINEAR},
  {11, 44100,  16, LINEAR},
  {12, 48000,  16, LINEAR}
};

#define _8000_8BIT_ULAW      1
#define _8000_8BIT_ALAW      2
#define _8000_16BIT_LINEAR   3
#define _9600_16BIT_LINEAR   4 
#define _11025_16BIT_LINEAR  5
#define _16000_16BIT_LINEAR  6
#define _18900_16BIT_LINEAR  7
#define _22050_16BIT_LINEAR  8
#define _32000_16BIT_LINEAR  9
#define _37800_16BIT_LINEAR  10
#define _44100_16BIT_LINEAR  11
#define _48000_16BIT_LINEAR  12

int	ACFD;
int	ADFD;
FILE	*adfp;

