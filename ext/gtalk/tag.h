/* Copyright (c) 2000-2006                  */
/*   Yamashita Lab., Ritsumeikan University */
/*   All rights reserved                    */
/*                                          */
/* $Id: tag.h,v 1.16 2009/02/12 17:43:42 sako Exp $                                     */

/*  List of speech controll tags */

#define T_BOOKMARK 0
#define T_SILENCE  1
#define T_EMPH     2
#define T_SPELL    3
#define T_PRON     4
#define T_SPEECH   5
#define T_LANG     6
#define T_PARTOFSP 7
#define T_VOICE    8
#define T_RATE     9
#define T_VOLUME  10
#define T_PITCH   11
#define T_RESET   12
#define T_CONTEXT 13
#define T_REGWORD 14
#define T_APB     15
#define T_W1      16

#ifdef INIT_TAG_TABLE

struct {
	int 	id;
	char	*name;
} tagTable[] = {
	{ T_BOOKMARK, "BOOKMARK" },
	{ T_SILENCE,  "SILENCE"  },
	{ T_EMPH,     "EMPH"     },
	{ T_SPELL,    "SPELL"    },
	{ T_PRON,     "PRON"     },
	{ T_SPEECH,   "SPEECH"   },
	{ T_LANG,     "LANG"     },
	{ T_PARTOFSP, "PARTOFSP" },
	{ T_VOICE,    "VOICE"    },
	{ T_RATE,     "RATE"     },
	{ T_VOLUME,   "VOLUME"   },
	{ T_PITCH,    "PITCH"    },
	{ T_RESET,    "RESET"    },
	{ T_CONTEXT,  "CONTEXT"  },
	{ T_REGWORD,  "REGWORD"  },
	{ T_APB,      "APB"      },
	{ T_W1,       "W1"       }
};

#define NUM_TAG ( sizeof(tagTable)/sizeof(tagTable[0]))

#endif /* INIT_TAG_TABLE */

/* List of attributes in the speech control tag */

/* BOOKMARK */
#define TA_MARK      1
/* SILENCE */
#define TA_MSEC     11
#define TA_MORA     12
/* PRON */
#define TA_SYM      21
#define TA_SAMPA    22
/* LANG */
#define TA_ISO639   31
/* PARTOFSP */
#define TA_PART     41
/* VOICE */
#define TA_REQUIRED 51
#define TA_OPTIONAL 52
#define TA_ALPHA    53
/* RATE */
#define TA_SPEED    61
#define TA_ABSSPEED 62
#define TA_MORASEC  63
/* VOLUME, PITCH */
#define TA_LEVEL    71
#define TA_ABSLEVEL 72
#define TA_RANGE    73
/* CONTEXT */
#define TA_TYPE     81
/* REGWORD */
#define TA_STRING   91
#define TA_READING  92
#define TA_PARTOFSP 93
#define TA_SYMSAMPA 94

#define TA_START  1000
#define TA_END    1001

#ifdef INIT_TAG_TABLE

struct {
	int 	id;
	char	*name;
} attrTable[] = {
	{ TA_MARK,     "MARK"     },
	{ TA_MSEC,     "MSEC"     },
	{ TA_MORA,     "MORA"     },
	{ TA_SYM,      "SYM"      },
	{ TA_SAMPA,    "SAMPA"    },
	{ TA_ISO639,   "ISO639"   },
	{ TA_PART,     "PART"     },
	{ TA_REQUIRED, "REQUIRED" },
	{ TA_OPTIONAL, "OPTIONAL" },
	{ TA_ALPHA,    "ALPHA" },
	{ TA_SPEED,    "SPEED"    },
	{ TA_ABSSPEED, "ABSSPEED" },
	{ TA_MORASEC,  "MORASEC"  },
	{ TA_LEVEL,    "LEVEL"    },
	{ TA_ABSLEVEL, "ABSLEVEL" },
	{ TA_RANGE,    "RANGE"    },
	{ TA_TYPE,     "TYPE"     },
	{ TA_STRING,   "STRING"   },
	{ TA_READING,  "READING"  },
	{ TA_PARTOFSP, "PARTOFSP" },
	{ TA_SYMSAMPA, "SYMSAMPA" },
	{ TA_START,    "start"    },
	{ TA_END,      "end"      }
};

#define NUM_ATTR ( sizeof(attrTable)/sizeof(attrTable[0]))

#endif /* INIT_TAG_TABLE */

#define MAX_JEIDA_TAGOPTIONS 10

typedef struct _JEIDA_tagoptions {
	int 	attrID;
	char	*val;
} JEIDA_TAGOPTIONS;

typedef struct _tag {
	int 	id;
	int 	n_op;
	JEIDA_TAGOPTIONS options[MAX_JEIDA_TAGOPTIONS];
/*	int 	attrID;		*/
/*	char	*val;	*/
	int 	start;
	int 	end;
	MORPH	*prev_morph;
	MORPH	*start_morph;
	MORPH	*end_morph;
} TAG;

#define MAX_TAG 200
extern TAG *tag[MAX_TAG];

extern int n_tag;

#define TAG_NAME_SIZE 128
#define TAG_ATTR_SIZE 64
#define TAG_VAL_SIZE 256
#define TAG_MAX_OP 10

/* √„‰•≤Ú¿œ∑Î≤Ã§Œ∑¡¬÷¡«¬∞¿≠Ãæ§ŒID */

#define W_PRON    0
#define W_POS     1
#define W_CTYPE   2
#define W_CFORM   3
#define W_INFO    4
#define W_FORM    5
#define W_ORTH    6

#define W_ACCENT       7
#define W_INDEX_FORM   8
#define W_INDEX_ORTH   9
#define W_A_TYPE      10
#define W_A_CON_TYPE  11
#define W_C_TYPE      12
#define W_C_FORM      13
#define W_LEX         14
#define W_SILENCE     15
#define W_INTERROGATIVE  16

#ifdef INIT_TAG_TABLE

struct {
	int 	id;
	char	*name;
} attributeTable[] = {
	{ W_PRON,       "pron" },
	{ W_POS,        "pos" },
	{ W_CTYPE,      "ctype" },
	{ W_CFORM,      "cform" },
	{ W_INFO,       "info" },
	{ W_FORM,       "form" },
	{ W_ORTH,       "orth" },
	{ W_ACCENT,     "accent" },
	{ W_INDEX_FORM, "indexForm" },
	{ W_INDEX_ORTH, "indexOrth" },
	{ W_A_TYPE,     "aType"},
	{ W_A_CON_TYPE, "aConType" },
	{ W_C_TYPE,     "cType" },
	{ W_C_FORM,     "cForm" },
	{ W_LEX,        "lex" },
	{ W_SILENCE,    "silence" },
	{ W_INTERROGATIVE, "interrogative" }
};

#define NUM_ATTRIBUTE	(sizeof(attributeTable)/sizeof(attributeTable[0]))

#endif /* INIT_TAG_TABLE */

typedef struct _tagoptions {
	char	attr[TAG_ATTR_SIZE];
	char	val[TAG_VAL_SIZE];
} TAGOPTIONS;
