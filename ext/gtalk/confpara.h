/* Copyright (c) 2000-2006                  */
/*   Yamashita Lab., Ritsumeikan University */
/*   All rights reserved                    */
/*                                          */
/* $Id: confpara.h,v 1.16 2009/02/13 02:02:47 sako Exp $                                     */

/* 音素セット */

extern char *phlist_file;

#define DEF_PHLIST_FILE "mono.lst"

/* 茶筌 */

extern char *chasen_bin;
extern char *chasen_rc;
extern char *chaone_bin;
extern char *chasen_dll;
extern char *chaone_xsl;

#define DEF_CHASEN_BIN "/usr/local/bin/chasen"
#define DEF_CHASEN_RC  "chasenrc"
#define DEF_CHAONE_BIN "chaone"
#if WIN32
#define DEF_CHASEN_DLL "libchasen.dll"
#else
#define DEF_CHASEN_DLL "libchasen.so"
#endif

/* Chaone */
#if WIN32
#define DEF_XSLT_FILE "chaone_t_Shift_JIS.xsl"
#else
#define DEF_XSLT_FILE "chaone_t_EUC-JP.xsl"
#endif
extern char *chaone_xsl;

/* 英数字 */

extern char *read_number;
extern char *read_alphabet;
extern char *read_date;
extern char *read_time;

#define DEF_READ_NUMBER "DECIMAL"
#define DEF_READ_ALPHABET "WORD"
#define DEF_READ_DATE "YMD"
#define DEF_READ_TIME "hms"

/* 話者 */

typedef enum {MALE,FEMALE,UNKNOWN} GENDER;

typedef struct _speaker {
	char *code;
	GENDER	gender;
	char *dur_tree_file;
	char *pit_tree_file;
	char *mcep_tree_file;
	char *dur_model_file;
	char *pit_model_file;
	char *mcep_model_file;
	double alpha;		/* MEL の周波数ワーピング係数。通常は 0.42 */
	double alpha_saved;	/* 係数の保存 */
	double postfilter_coef;	/* ポストフィルタ係数 */
} SPEAKER;

#define MAX_SPEAKER 20
extern SPEAKER speaker[MAX_SPEAKER];

extern int n_speaker;	/* 登録された話者数 */
extern int spid;	/* 現在の話者ID */

extern char *conf_audiodev; /* 実行時に指定されるオーディオデバイス */

#define DEF_ALPHA 0.42
#define DEF_SP_CODE "male01"
#define DEF_SP_GENDER MALE
#define DEF_POSTFILTER_COEF 0.3

#define DEF_DUR_TREE_FILE "tree-dur.inf"
#define DEF_PIT_TREE_FILE "tree-lf0.inf"
#define DEF_MCEP_TREE_FILE "tree-mcep.inf"

#define DEF_DUR_MODEL_FILE "duration.pdf"
#define DEF_PIT_MODEL_FILE "lf0.pdf"
#define DEF_MCEP_MODEL_FILE "mcep.pdf"

extern FILE *logfp;

extern int s_mode;

#if defined(USE_CHASENLIB) || defined(USE_SPLIB)
typedef struct _CHASEN_FD *CHASEN_FD;
#else
typedef int CHASEN_FD;
#endif

extern char *dic_file;
