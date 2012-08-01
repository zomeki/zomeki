/* Copyright (c) 2000-2006                  */
/*   Yamashita Lab., Ritsumeikan University */
/*   All rights reserved                    */
/*                                          */
/* $Id: command.h,v 1.8 2006/10/19 03:27:08 sako Exp $                                     */
 
/* List of Command */

/* for speech synthesis module */
#define C_set             0
#define C_inq             1
#define C_prop            2
#define C_save            3
#define C_rest            4
#define C_del             5

/* for all modules */
#define C_def             100
#define C_do              101


struct {
	int 	id;
	char	*name;
} commandTable[] = {
	{ C_set,  "set" },
	{ C_inq,  "inq" },
	{ C_prop, "prop" },
	{ C_save, "save" },
	{ C_rest, "rest" },
	{ C_del,  "del" },
	{ C_def,  "def" },
	{ C_do,   "do" }
};

#define NUM_COMMAND ( sizeof(commandTable)/sizeof(commandTable[0]))
