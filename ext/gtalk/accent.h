/* Copyright (c) 2000-2006                  */
/*   Yamashita Lab., Ritsumeikan University */
/*   All rights reserved                    */
/*                                          */
/* $Id: accent.h,v 1.14 2006/10/19 03:27:08 sako Exp $                                     */
/*                                          */
/* アクセント結合様式のID */

#define	AF_NULL	0
#define	AF_F1	1
#define	AF_F2	2
#define	AF_F3	3
#define	AF_F4	4
#define	AF_F5	5
#define	AF_F6	6
#define	AF_F7	7
#define	AF_F8	8
#define	AF_F9	9

#define	AF_C1	11
#define	AF_C2	12
#define	AF_C3	13
#define	AF_C4	14
#define	AF_C5	15
#define	AF_C6	16
#define	AF_C7	17
#define	AF_C8	18
#define	AF_C9	19
#define	AF_C10	20
#define	AF_C11	21
#define	AF_C12	22

#define	AF_P1	31
#define	AF_P2	32
#define	AF_P3	33
#define	AF_P4	34
#define	AF_P5	35
#define	AF_P6	36
#define	AF_P7	37
#define	AF_P8	38
#define	AF_P9	39
#define	AF_P10	40
#define	AF_P11	41
#define	AF_P12	42
#define	AF_P13	43
#define	AF_P14	44
#define	AF_P15	45

#define AF_OTHER 99

#define	IS_FUZOKU_KETSUGOU(af)	( (af)>=AF_F1 && (af)<AF_C1 )
#define	IS_POST_KETSUGOU(af)	( (af)>=AF_C1 && (af)<AF_P1 )
#define	IS_PRE_KETSUGOU(af) 	( (af)>=AF_P1 && (af)<AF_OTHER )

#ifdef INIT_ACON_DATA_TABLE

struct {
	int 	id;
	char	*name;
} aformTable[] = {
	{ AF_NULL, "-" },
	{ AF_F1, "F1" },
	{ AF_F2, "F2" },
	{ AF_F3, "F3" },
	{ AF_F4, "F4" },
	{ AF_F5, "F5" },
	{ AF_F6, "F6" },
	{ AF_F7, "F7" },
	{ AF_F8, "F8" },
	{ AF_F9, "F9" },
	{ AF_C1, "C1" },
	{ AF_C2, "C2" },
	{ AF_C3, "C3" },
	{ AF_C4, "C4" },
	{ AF_C5, "C5" },
	{ AF_C6, "C6" },
	{ AF_C7, "C7" },
	{ AF_C8, "C8" },
	{ AF_C9, "C9" },
	{ AF_C10, "C10" },
	{ AF_C11, "C11" },
	{ AF_C12, "C12" },
	{ AF_P1, "P1" },
	{ AF_P2, "P2" },
	{ AF_P3, "P3" },
	{ AF_P4, "P4" },
	{ AF_P5, "P5" },
	{ AF_P6, "P6" },
	{ AF_P7, "P7" },
	{ AF_P8, "P8" },
	{ AF_P9, "P9" },
	{ AF_P10, "P10" },
	{ AF_P11, "P11" },
	{ AF_P12, "P12" },
	{ AF_P13, "P13" },
	{ AF_P14, "P14" },
	{ AF_P15, "P15" },
	{ AF_OTHER, "?" },
};

#define	NUM_AFORM	(sizeof(aformTable)/sizeof(aformTable[0]))

#endif	/* INIT_ACON_DATA_TABLE */

