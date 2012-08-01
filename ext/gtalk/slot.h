/* Copyright (c) 2000-2006                  */
/*   Yamashita Lab., Ritsumeikan University */
/*   All rights reserved                    */
/*                                          */
/* $Id: slot.h,v 1.16 2009/02/12 17:43:42 sako Exp $                                     */

/* List of Slot */

#define S_Run                    0
#define S_ModuleVersion          1
#define S_ProtocolVersion        2
#define S_SpeakerSet            10
#define S_Speaker               11
#define S_Alpha                 12
#define S_Postfilter_coef       13
#define S_Text                  20
#define S_Text_text             21
#define S_Text_pho              22
#define S_Text_dur              23
#define S_Speak                 30
#define S_Speak_text            31
#define S_Speak_pho             32
#define S_Speak_dur             33
#define S_Speak_utt             34
#define S_Speak_len             35
#define S_Speak_stat            36
#define S_Speak_syncinterval    37
#define S_SaveRAW               40
#define S_LoadRAW               41
#define S_SaveWAV               42
#define S_LoadWAV               43
#define S_SavePros              44
#define S_LoadPros              45
#define S_AutoPlay              46
#define S_AutoPlayDelay         47
#define S_Save                  50  /* 旧バージョンとの互換性のため残す */
#define S_SpeechFile            51	/* 旧バージョンとの互換性のため残す */
#define S_ProsFile              53	/* 旧バージョンとの互換性のため残す */
#define S_ParsedText            60
#define S_Log                  100	/* for debug */
#define S_Log_conf             101	/* for debug */
#define S_Log_text             102	/* for debug */
#define S_Log_arranged_text    103	/* for debug */
#define S_Log_chasen           104	/* for debug */
#define S_Log_tag              105	/* for debug */
#define S_Log_phoneme          106	/* for debug */
#define S_Log_mora             107	/* for debug */
#define S_Log_morph            108	/* for debug */
#define S_Log_aphrase          109	/* for debug */
#define S_Log_breath           110	/* for debug */
#define S_Log_sentence         111	/* for debug */
#define S_Err                  120	/* for debug */

#ifdef INIT_SLOT_TABLE

struct {
	int 	id;
	char	*name;
} slotTable[] = {
	{ S_Run, "Run" },
	{ S_ModuleVersion, "ModuleVersion" },
	{ S_ProtocolVersion, "ProtocolVersion" },
	{ S_SpeakerSet, "SpeakerSet" },
	{ S_Speaker, "Speaker" },
	{ S_Alpha, "Alpha" },
	{ S_Postfilter_coef, "Postfilter"},
	{ S_Text, "Text" },
	{ S_Text_text, "Text.text" },
	{ S_Text_pho, "Text.pho" },
	{ S_Text_dur, "Text.dur" },
	{ S_Speak, "Speak" },
	{ S_Speak_text, "Speak.text" },
	{ S_Speak_pho, "Speak.pho" },
	{ S_Speak_dur, "Speak.dur" },
	{ S_Speak_utt, "Speak.utt" },
	{ S_Speak_len, "Speak.len" },
	{ S_Speak_stat, "Speak.stat" },
	{ S_Speak_syncinterval, "Speak.syncinterval" },
	{ S_SaveRAW,    "SaveRAW" },
	{ S_LoadRAW,    "LoadRAW" },
	{ S_SaveWAV,    "SaveWAV" },
	{ S_LoadWAV,    "LoadWAV" },
	{ S_SavePros,   "SavePros" },
	{ S_LoadPros,   "LoadPros" },
	{ S_Save,       "Save" },	  /* 旧バージョンとの互換性のため残す */
	{ S_SpeechFile, "SpeechFile" },	  /* 旧バージョンとの互換性のため残す */
	{ S_ProsFile,   "ProsFile" },	  /* 旧バージョンとの互換性のため残す */
	{ S_AutoPlay,   "AutoPlay" },
	{ S_AutoPlayDelay,"AutoPlayDelay" },
	{ S_ParsedText, "ParsedText" },
	{ S_Log,          "Log" },
	{ S_Log_conf,     "Log.conf" },
	{ S_Log_text,     "Log.text" },
	{ S_Log_arranged_text,  "Log.arrangedText" },
	{ S_Log_chasen,   "Log.chasen" },
	{ S_Log_tag,      "Log.tag" },
	{ S_Log_phoneme,  "Log.phoneme" },
	{ S_Log_mora,     "Log.mora" },
	{ S_Log_morph,    "Log.morph" },
	{ S_Log_aphrase,  "Log.aphrase" },
	{ S_Log_breath,   "Log.breath" },
	{ S_Log_sentence, "Log.sentence" },
	{ S_Err,          "Err" }
};

#define NUM_SLOT ( sizeof(slotTable)/sizeof(slotTable[0]))

#endif

typedef enum {AutoOutput, NoAutoOutput} SlotProp;

extern SlotProp prop_Run;
extern SlotProp prop_ModuleVersion;
extern SlotProp prop_ProtocolVersion;
extern SlotProp prop_SpeakerSet;
extern SlotProp prop_Speaker;
extern SlotProp prop_SpeechFile;
extern SlotProp prop_ProsFile;
extern SlotProp prop_Text;
extern SlotProp prop_Text_text;
extern SlotProp prop_Text_pho;
extern SlotProp prop_Text_dur;
extern SlotProp prop_Speak;
extern SlotProp prop_Speak_text;
extern SlotProp prop_Speak_pho;
extern SlotProp prop_Speak_dur;
extern SlotProp prop_Speak_utt;
extern SlotProp prop_Speak_len;
extern SlotProp prop_Speak_stat;
extern SlotProp prop_Speak_syncinterval;

/* slots */

#define MAX_TEXT_LEN 8192     /* 合成すべき文の最大文字数 */

extern char slot_Run[20];
extern char slot_Speak_stat[20];
extern char input_text[MAX_TEXT_LEN];  /* 入力されたテキスト(タグつき) */
extern char spoken_text[MAX_TEXT_LEN]; /* 音声出力された発話のテキスト */
extern char slot_Log_file[256];
extern char slot_Err_file[256];
extern char slot_Speech_file[512];
extern char slot_Pros_file[512];
extern int slot_Auto_play;
extern int slot_Auto_play_delay;	/* msec */
extern int slot_n_phonemes;
extern int slot_total_dur;
extern int slot_Log_conf;
extern int slot_Log_text;
extern int slot_Log_arranged_text;
extern int slot_Log_chasen;
extern int slot_Log_tag;
extern int slot_Log_phoneme;
extern int slot_Log_mora;
extern int slot_Log_morph;
extern int slot_Log_aphrase;
extern int slot_Log_breath;
extern int slot_Log_sentence;
extern int slot_Speak_syncinterval;
