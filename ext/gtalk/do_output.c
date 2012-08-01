/* Copyright (c) 2000-2006                             */
/*   Yoichi Yamashita                                  */
/*   (Ritsumeikan University)                          */
/*   Takuya Nishimoto                                  */
/*   (Kyoto Insititute of Technology)                  */
/*   Takao Kobayashi, Takashi Masuko, Masatsune Tamura */
/*   (Tokyo Institute of Technology)                   */
/*   Keiichi Tokuda, Takayoshi Yoshimura, Heiga Zen    */
/*   (Nagoya Institute of Technology)                  */
/*   All rights reserved                               */
/*                                                     */
/*  $Id: do_output.c,v 1.21 2009/02/13 02:02:47 sako Exp $                                               */
/* 
波形を生成しながらの音声出力処理は pthread を用いて実装されている。
これは AUTO_DA が定義されていれば，組み込まれる。
通常の音声出力は pthread ではなく，fork() を使って実装されている。
これは，pthread 版の音声出力では，音声出力の途中停止において
音声が停止するまでに時間遅れが出るためである。fork 版は瞬時に停止する。
通常の音声出力も pthread で行う場合には，THREAD_DA を定義すれば良い。
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "synthesis.h"
#include "defaults.h"
#include "confpara.h"
#include "da.h"
#include "slot.h"

int talked_DA_msec;
int already_talked;
int in_auto_play;

int ErrMsg(char *,...);
int TmpMsg(char *,...);
void restart(int);
void inqSpeakLen();
void inqSpeakUtt();
void inqSpeakStat();
void do_output_file(char *);
void abort_auto_output();

#ifdef USE_SPLIB
#include "do_output_sp.c"
#else

#include <sys/wait.h>
#include <sys/time.h>
#include <sys/stat.h>
#include <unistd.h>
#include <signal.h>
#include <pthread.h>

#define	SIZE	256*400

#ifdef LINUX
int	org_vol, org_channels, org_precision, org_freq;
int	forced_stereo;
#endif /* LINUX */
int     current_pos;
int     prev_tell_pos_ms;

#ifdef SOLARIS
audio_info_t	org_data;
#include <strings.h>
#endif /* SOLARIS */

/*---------------------------------------------------------------------*/

#ifdef THREAD_DA
void set_da_signal() 
{
}

#else
static void sig_wait_da()
{
	int status;
	wait( &status );
	if( prop_Speak_len == AutoOutput )  inqSpeakLen();
	if( prop_Speak_utt == AutoOutput )  inqSpeakUtt();
	strcpy( slot_Speak_stat, "IDLE" );
	if( prop_Speak_stat == AutoOutput )  inqSpeakStat();
}

void set_da_signal()
{
	signal( SIGCHLD, sig_wait_da );
}
#endif

/*---------------------------------------------------------------------*/

void reset_output()
{
	void reset_audiodev();
	fclose( adfp);
	close( ACFD);

	reset_audiodev();
}

void init_output()
{
	int	dtype;
	void	init_audiodev();

	dtype = DTYPE;
	init_audiodev(dtype);
}

void sndout(leng, out)
int	leng;
short	*out;
{
  int i;
  int pos, pos_ms, interval_ms;
  int samp_rate;

        samp_rate = data_type[DTYPE].sample;
  
//	fwrite( out, sizeof(short), leng, adfp);
	for( i=0; i<leng; ++i ) {
		fwrite( &(out[i]), sizeof(short), 1, adfp);
		/* モノラル音声出力ができない場合 */
		if( forced_stereo )  {
			fwrite( &(out[i]), sizeof(short), 1, adfp);
		}

		if(current_pos % 128 == 0) {
#ifdef LINUX
		        count_info info;
	    
			if( ioctl( ADFD, SNDCTL_DSP_GETOPTR, &info ) != -1 ) {
			        pos = info.bytes / 2;
				if( forced_stereo )  {
				        pos /= 2;
				}
			} else {
			        pos = current_pos;
			}
#else
			pos = current_pos;
#endif
			pos_ms = (1000 * pos) / samp_rate;
			interval_ms = pos_ms - prev_tell_pos_ms;

			if( slot_Speak_syncinterval > 0 && interval_ms >= slot_Speak_syncinterval ) {
			        RepMsg("tell Speak.sync = %d\n", pos_ms);
				/*prev_tell_pos_ms = pos_ms;*/
				while( prev_tell_pos_ms + slot_Speak_syncinterval <= pos_ms ) {
				         prev_tell_pos_ms += slot_Speak_syncinterval;
				}
			}
		}
		++current_pos;
	}
	write( ADFD, out, 0);
	fflush( adfp);

}

void init_audiodev(dtype)
int	dtype;
{
#ifdef LINUX
	int arg;
	int channels;
	char *devname;

	/* 環境変数によって指定された場合 */
	if ((devname = getenv(AUDIO_DEV_ENVNAME)) != NULL) {
	  adfp = fopen(devname, "w");
	/* 設定ファイルで指定されている場合 */
	}
	else if( conf_audiodev != NULL){
	  adfp = fopen(conf_audiodev, "w");
	} else {
	  adfp = fopen(AUDIO_DEV_DEFAULT, "w");
	}
	if( adfp == NULL){
	    ErrMsg("can't open audio device\n");
	    restart( 1 );
	}
	ADFD = adfp->_fileno;
	ACFD = open( MIXER_DEV, O_RDWR, 0);

	/* モノラルの音声出力が可能かどうかのチェック */
	forced_stereo = 0;
	channels = 0;	/* 0: monoral */
	ioctl(ADFD, SNDCTL_DSP_STEREO, &channels);
//	fprintf(stderr,"CHANNELS %d ----------------------------\n", channels);
	if (channels != 0) {
//		fprintf(stderr,"ERROR: monoral playing not supported\n");
		forced_stereo = 1;
	}

	ioctl(ADFD, SOUND_PCM_READ_BITS, &org_precision);
	ioctl(ADFD, SOUND_PCM_READ_CHANNELS, &org_channels);
	ioctl(ADFD, SOUND_PCM_READ_RATE, &org_freq);
	ioctl(ACFD, SOUND_MIXER_READ_PCM, &org_vol);
	
	arg = data_type[dtype].precision;
	ioctl(ADFD, SOUND_PCM_WRITE_BITS, &arg);
/*	arg = data_type[dtype].channel; */
	if (forced_stereo == 1) {
	  arg = 2;
	} else {
	  arg = 1;
	}
	ioctl(ADFD, SOUND_PCM_WRITE_CHANNELS, &arg);
	arg = data_type[dtype].sample;
	ioctl(ADFD, SOUND_PCM_WRITE_RATE, &arg);
#endif /* LINUX */
#ifdef SOLARIS
	audio_info_t	data;
	char *devname;

	ACFD = open(AUDIO_CTLDEV, O_RDWR, 0);

	/* 設定ファイルで指定されている場合 */
	/* 環境変数によって指定された場合 */
	if ((devname = getenv(AUDIO_DEV_ENVNAME)) != NULL) {
	  adfp = fopen(devname, "w");
	}
	else if( conf_audiodev != NULL){
	  adfp = fopen(conf_audiodev, "w");
	}
	else {
	  adfp = fopen(AUDIO_DEV_DEFAULT, "w");
	}
	if( adfp == NULL){
	    ErrMsg("can't open audio device\n");
	    restart( 1 );
	}
	ADFD = adfp->_file;

	AUDIO_INITINFO(&data);
	ioctl(ACFD, AUDIO_GETINFO, &data);
	bcopy( &data, &org_data, sizeof( audio_info_t));

	data.play.sample_rate = data_type[dtype].sample;
	data.play.precision   = data_type[dtype].precision;
	data.play.encoding    = data_type[dtype].encoding;

	ioctl(ADFD,AUDIO_SETINFO,&data);
#endif /* SOLARIS */
	current_pos = 0;
	prev_tell_pos_ms = 0;
}

void reset_audiodev()
{
#ifdef LINUX
	char *devname;

	ACFD = open( MIXER_DEV, O_RDWR, 0);
	/*	ADFD = open( AUDIO_DEV, O_RDWR, 0); */

	/* 環境変数によって指定された場合 */
	if ((devname = getenv(AUDIO_DEV_ENVNAME)) != NULL) {
	  ADFD = open(devname, O_WRONLY, 0);
	}
	/* 設定ファイルで指定されている場合 */
	else if( conf_audiodev != NULL){
	  adfp = fopen(conf_audiodev, "w");
	}
	else {
	  ADFD = open(AUDIO_DEV_DEFAULT, O_WRONLY, 0);
	}
	ioctl(ADFD, SOUND_PCM_WRITE_BITS, &org_precision);
	ioctl(ADFD, SOUND_PCM_WRITE_CHANNELS, &org_channels);
	ioctl(ADFD, SOUND_PCM_WRITE_RATE, &org_freq);
	ioctl(ACFD, SOUND_MIXER_WRITE_PCM, &org_vol);

	close( ADFD);
	close( ACFD);
#endif /* linux */
#ifdef SOLARIS
	ACFD = open(AUDIO_CTLDEV, O_RDWR, 0);
	ioctl( ACFD, AUDIO_SETINFO, &org_data);
	close( ACFD);
#endif /* SOLARIS */
	current_pos = 0;
	prev_tell_pos_ms = 0;
}

/*---------------------------------------------------------------------*/
#if defined(LINUX) || defined(SOLARIS)

struct timeval tv;
struct timezone tz;
static int start_DA_sec;
static int start_DA_usec;

#ifdef THREAD_DA

pthread_t thread;

void output_speaker_cleanup(void *dummy)
{

  reset_output();
  strcpy( slot_Speak_stat, "IDLE" );
  if( prop_Speak_stat == AutoOutput )  inqSpeakStat();

}

void output_speaker_thread(int *t)
{

  int total = *t;
  int nout;
  int last_state, last_type;

  pthread_setcanceltype(PTHREAD_CANCEL_DEFERRED, &last_type);
  pthread_setcancelstate(PTHREAD_CANCEL_ENABLE, &last_state);
  pthread_cleanup_push((void *)output_speaker_cleanup, NULL);
  
  init_output();
  nout = 0;
  while ( nout < total - SIZE)  {
    sndout(SIZE,&wave.data[nout]);
    nout += SIZE;
    pthread_testcancel();
  }
  sndout(total - nout, &wave.data[nout]);
  ioctl(ADFD, SOUND_PCM_SYNC, 0);

  pthread_cleanup_pop(1);
  return;

}

void abort_demanded_output()
{
  void *statusp;

  gettimeofday( &tv, &tz );
/*
  printf( "tv: %d %d\n", tv.tv_sec, tv.tv_usec );
*/
  talked_DA_msec = (tv.tv_sec-start_DA_sec)*1000 + 
                   (tv.tv_usec-start_DA_usec)/1000.;

  pthread_cancel(thread);
  pthread_join(thread, &statusp);

  if( prop_Speak_len == AutoOutput )  inqSpeakLen();
  if( prop_Speak_utt == AutoOutput )  inqSpeakUtt();
}

#else /* Not THREAD_DA */

static int da_process = -1;

void output_speaker( int total )
{
	int nout, i;
	//	char *sbuff;

	if( (da_process=fork())==0 )  {
	  //		sbuff = (char *) malloc( 2 * sizeof(shart) * total );
	  //		for( i=0; i<total; ++i )  {
	  //		  sbuff[2*i] = wave.data[i];
	  //		  sbuff[2*i+1] = wave.data[i];
	  //		}
	  //		total *= 2;

		setpgrp();
		init_output();
		nout = 0;
		while ( nout < total - SIZE)  {
			sndout(SIZE,&wave.data[nout]);
			nout += SIZE;
		}
		sndout(total - nout, &wave.data[nout]);
#ifdef LINUX
		ioctl(ADFD, SOUND_PCM_SYNC, 0);
#endif /* LINUX */
		reset_output();
		exit(0);
	} else {
//		wait( &status );	
	}
}

void abort_demanded_output()
{
	gettimeofday( &tv, &tz );
	talked_DA_msec = (tv.tv_sec-start_DA_sec)*1000 + 
	                 (tv.tv_usec-start_DA_usec)/1000.;

/* da_process を一度も作らないで kill すると abort する。*/
	if( da_process >= 0 )  {
		kill( da_process, SIGKILL );
		/*
		TmpMsg( "DA process was killed\n" );
		*/
	}
}

#endif /* THREAD_DA */

#else

void abort_demanded_output(){}

#endif /* LINUX || SOLARIS */



/*---------------------------------------------------------------------*/

void do_output(char *fn)
{
	static int nsample;

	in_auto_play = 0;

	if( fn )  {
		do_output_file( fn );
		return;
	}

	nsample = wave.nsample;

#if defined(LINUX) || defined(SOLARIS)
	gettimeofday( &tv, &tz );
/*	printf( "tv: %d %d\n", (int)tv.tv_sec, (int)tv.tv_usec );	*/
	start_DA_sec = (int)tv.tv_sec;
	start_DA_usec = (int)tv.tv_usec;
	talked_DA_msec = -1;
	already_talked = 1;

#ifdef THREAD_DA
	pthread_create(&thread,
		NULL,
		(void *) output_speaker_thread,
		(void *) &nsample);
#else
		output_speaker( nsample );
#endif /* THREAD_DA */
#else
		TmpMsg( "Sorry. Not implemented ...\n" );
#endif /* LINUX || SOLARIS */
}

void abort_output()
{
#ifdef AUTO_DA
	if( in_auto_play )  {
		abort_auto_output();
	} else {
		abort_demanded_output();
	}
#else
	abort_demanded_output();
#endif
}

/*--------------------------------------------------------------------
	AutoPlay
--------------------------------------------------------------------*/

#ifdef AUTO_DA

pthread_t ap_thread;

extern int synthesized_nsample;
extern int nsample_frame;

void auto_output_speaker_cleanup(void *dummy)
{

  reset_output();
  strcpy( slot_Speak_stat, "IDLE" );
  if( prop_Speak_stat == AutoOutput )  inqSpeakStat();

}

void auto_output_speaker_thread(int *t)
{

  int total = *t;
  int nout;
  int last_state, last_type;

  pthread_setcanceltype(PTHREAD_CANCEL_DEFERRED, &last_type);
  pthread_setcancelstate(PTHREAD_CANCEL_ENABLE, &last_state);
  pthread_cleanup_push((void *)auto_output_speaker_cleanup, NULL);
  
  init_output();
  nout = 0;
/*  usleep( 1000*250 );	*/
  usleep( 1000*slot_Auto_play_delay );
  while ( nout < total - nsample_frame )  {
    while( nout+nsample_frame > synthesized_nsample )  {
/*		printf( "sleep\n" );	*/
      usleep( 1000 );	/* 1msec */
    }
    sndout( nsample_frame, &wave.data[nout] );
    nout += nsample_frame;
    pthread_testcancel();
  }
  sndout( total-nout, &wave.data[nout] );

  ioctl(ADFD, SOUND_PCM_SYNC, 0);

  pthread_cleanup_pop(1);
  return;
}

void do_auto_output()
{
	static int nsample;

	in_auto_play = 1;

	nsample = wave.nsample;

#if defined(LINUX) || defined(SOLARIS)
	gettimeofday( &tv, &tz );
/*	printf( "tv: %d %d\n", (int)tv.tv_sec, (int)tv.tv_usec );	*/
	start_DA_sec = (int)tv.tv_sec;
	start_DA_usec = (int)tv.tv_usec;
	talked_DA_msec = -1;
	already_talked = 1;

	pthread_create(&ap_thread,
		NULL,
		(void *) auto_output_speaker_thread,
		(void *) &nsample);
#else
		TmpMsg( "Sorry. Not implemented ...\n" );
#endif /* LINUX || SOLARIS */
}

void abort_auto_output()
{
  void *statusp;

  gettimeofday( &tv, &tz );
/*
  printf( "tv: %d %d\n", tv.tv_sec, tv.tv_usec );
*/
  talked_DA_msec = (tv.tv_sec-start_DA_sec)*1000 + 
                   (tv.tv_usec-start_DA_usec)/1000.;

  pthread_cancel(ap_thread);
  pthread_join(ap_thread, &statusp);

  if( prop_Speak_len == AutoOutput )  inqSpeakLen();
  if( prop_Speak_utt == AutoOutput )  inqSpeakUtt();
}


#endif /* AUTO_DA */


#endif /* !USE_SPLIB */
