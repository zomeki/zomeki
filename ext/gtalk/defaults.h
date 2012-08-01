/* Copyright (c) 2000-2006                             */
/*   Takao Kobayashi, Takashi Masuko, Masatsune Tamura */
/*   (Tokyo Institute of Technology)                   */
/*   Keiichi Tokuda, Takayoshi Yoshimura, Heiga Zen    */
/*   (Nagoya Institute of Technology)                  */
/*   All rights reserved                               */
/*                                                     */
/* $Id: defaults.h,v 1.10 2006/10/19 03:27:08 sako Exp $                                                */

/* mlpg */
#define RANGE 10

#define DELTAWIN  " -0.5 0 0.5"
#define ACCWIN  " 0.25 -0.5 0.25"

#define FRAME_RATE 5 /* frame rate (ms) */

/* mel-cepstral vocoder */

#define FPERIOD         80
#define IPERIOD         1
#define SEED            1
#define RND_MAX        32767
#define GAUSS           TR
#define B0      0x00000001
#define B28     0x10000000
#define B31     0x80000000
#define B31_    0x7fffffff
#define Z       0x00000000
#define PADEORDER 4
#define SAMPLE_RATE 16000
#define DTYPE _16000_16BIT_LINEAR
#define	POSTFILTER TR
#define BETA 0.3
#define IRLENG 64

/* 出力される文頭文末のsilの長さ(ms)*/
#define SILENCE_LENGTH 10

