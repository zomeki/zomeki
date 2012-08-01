/* Copyright (c) 2000-2006                             */
/*   Yamashita Lab.                                    */
/*   (Ritsumeikan University)                          */
/*   Takao Kobayashi, Takashi Masuko, Masatsune Tamura */
/*   (Tokyo Institute of Technology)                   */
/*   Keiichi Tokuda, Takayoshi Yoshimura, Heiga Zen    */
/*   (Nagoya Institute of Technology)                  */
/*   All rights reserved                               */
/*                                                     */
/* $Id: synthesis.h,v 1.18 2009/02/12 17:43:42 sako Exp $                                                */

typedef enum {NON,SILB,SILE,PAU} SILENCE;
typedef enum {NO,YES} GBOOLEAN;
typedef enum {RAW,WAV} SPEECHFILETYPE;

/* 音素 */

typedef struct _phoneme {
	char *phoneme;
	double time;
	double ctime;	/* 直前までの累積時間。時間長修正の後で設定 */
	struct _phoneme *next;
	struct _phoneme *prev;
	struct _mora *parent;
	int sid;	/* speaker ID */
	double alpha;	/* warping parameter */
} PHONEME;

extern PHONEME *phhead;
extern PHONEME *phtail;

/* モーラ */

typedef struct _mora {
	char *yomi;     /* カナ表記 */
	int position;
	int acdist;
	GBOOLEAN chouonka;
	GBOOLEAN devoiced;
	SILENCE silence;
	PHONEME *phead;
	PHONEME *ptail;
	struct _mora *next;
	struct _mora *prev;
	struct _morph *parent;
} MORA;

extern MORA *mrhead;
extern MORA *mrtail;

typedef struct _accent{
	char prepos; /* 先行品詞情報: V, A, N, *(all), -(None) */
	int form;   /* アクセント結合様式 */
	int ctype;  /* 結合アクセント価 */
	int ctype2;  /* 結合アクセント価 (付属語で、先行語が有核、無核によって
	                結合アクセント値が変わる場合 (F6とF9) がある。) */
} ACCENT;

#define MAX_ACCENT      4

/* 形態素 */
typedef struct _morph {
	char *kanji;    /* 漢字表記 */
	char *pron;     /* カナ表記：茶筌の「読み」出力 */
	int nmora;
	int nbyte;		/* 漢字表記での文字数 */
	int hinshiID;
	int katsuyogataID;
	int katsuyokeiID;
	int accentType;
	ACCENT accent[MAX_ACCENT];
	int n_accent;
	struct _morph *submorph;
	SILENCE silence;
	MORA *mrhead;
	MORA *mrtail;
	struct _morph *next;
	struct _morph *prev;
	struct _aphrase *parent;
} MORPH;

extern MORPH *mphead;
extern MORPH *mptail;

/* アクセント句 */
typedef struct _aphrase {
	int nmora;
	int accentType;
	int position;		/* 呼気段落中でのアクセント句の位置 */
	SILENCE silence;
	GBOOLEAN interrogative;
	MORPH *mphead;
	MORPH *mptail;
	struct _aphrase *next;
	struct _aphrase *prev;
	struct _breath *parent;
} APHRASE;

extern APHRASE *ahead;
extern APHRASE *atail;

/* 呼気段落 */
typedef struct _breath {
	int nmora;
	int position;   /* 文中での呼気段落の位置。ポーズも一つの呼気段落に
	                   なるが数にはいれず、その position は -1 */
	SILENCE silence;
	APHRASE *ahead;
	APHRASE *atail;
	struct _breath *next;
	struct _breath *prev;
	struct _sentence *parent;
} BREATH;

extern BREATH *bhead;
extern BREATH *btail;

/* 文章 */
typedef struct _sentence {
	int nmora;
	int nbreath;	/* ポーズ以外の呼気段落の数 */
	BREATH *bhead;
	BREATH *btail;
	struct _sentence *prev;
	struct _sentence *next;
} SENTENCE;

extern SENTENCE *shead;
extern SENTENCE *stail;
extern SENTENCE *sentence;

typedef struct _wave
{
  short *data;
  int rate;
  int nsample;
} WAVE;

extern WAVE wave;

typedef struct _param
{
  double *data;
  int rate;
} PARAM;

extern PARAM power;
extern PARAM f0;
extern PARAM alpha;

typedef struct _pros
{
	int	nPhoneme;
	char **ph_name;
	int *ph_dur;
	int	nFrame;
	double *fr_f0;
	double *fr_power;
} PROS;

extern PROS prosBuf;	/* 韻律データの一時格納用 */
