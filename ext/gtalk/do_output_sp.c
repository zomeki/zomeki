/*  $Id: do_output_sp.c,v 1.4 2006/10/19 03:26:33 sako Exp $                              */
#include <sp/spBaseLib.h>
#include <sp/spAudioLib.h>

#define GTALK_AUDIO_BLOCKSIZE 1024
#define GTALK_USE_SP_PLUGIN_OUTPUT

int RepMsg(char *, ...);
void abort_auto_output();

static volatile spAudio gtalk_sp_audio = NULL;
static volatile int gtalk_aborted_flag = 0;
static volatile long gtalk_prev_tell_pos_ms = 0;

/* nonzero value restarts play from beginning on replay */
static int gtalk_replay_init_flag = 0;

int in_auto_play;

void output_speaker(int total) {}

void init_output() {}

void reset_audiodev() {}

void set_da_signal() {}

static int get_current_pos(spAudio audio)
{
    int pos_ms;
    long position;

    pos_ms = -1;
    
    if (audio != NULL) {
	if (spGetAudioOutputPosition(audio, &position) == SP_TRUE) {
	    pos_ms = (1000 * position) / SAMPLE_RATE;
	    spDebug(80, "get_current_pos", 
		    "spGetAudioOutputPosition: position = %ld, da_msec = %d, SAMPLE_RATE = %d\n", 
		    position, pos_ms, SAMPLE_RATE);
	}
    }

    return pos_ms;
}

void abort_demanded_output() {
    if (gtalk_sp_audio != NULL) {
	talked_DA_msec = get_current_pos(gtalk_sp_audio);

	if (!gtalk_aborted_flag) {
	    spDebug(1, "abort_output", "output aborted\n");
	    spStopAudio(gtalk_sp_audio);
	    gtalk_aborted_flag = 1;
	}

	if ( prop_Speak_len == AutoOutput )  inqSpeakLen();
	if ( prop_Speak_utt == AutoOutput )  inqSpeakUtt();
    }

}

spBool output_pos_func(spAudio audio, spAudioCallbackType call_type,
		       void *data1, void *data2, void *user_data)
{
    long pos_ms;
    long *pos;
    long current_interval;
    
    if (call_type == SP_AUDIO_OUTPUT_POSITION_CALLBACK) {
	pos = (long *)data1;
	pos_ms = 1000 * (*pos) / SAMPLE_RATE;
	current_interval = pos_ms - gtalk_prev_tell_pos_ms;
	spDebug(100, "output_pos_func",
		"pos = %ld, pos_ms = %ld, slot_Speak_syncinterval = %d, current_interval = %ld\n",
		*pos, pos_ms, slot_Speak_syncinterval, current_interval);
    
	if (slot_Speak_syncinterval > 0 && current_interval >= (long)slot_Speak_syncinterval) {
	    if (!gtalk_aborted_flag) {
		RepMsg("tell Speak.sync = %ld\n", pos_ms);
	    }
	    gtalk_prev_tell_pos_ms = pos_ms;
	}
    }
    
    return SP_TRUE;
}

static spThreadReturn do_output_thread(void *data)
{
    int total;
    int length;
    int offset;
    int block_length;

    spDebug(50, "do_output_thread", "in\n");

    total = *(int *)data;

    if (in_auto_play && slot_Auto_play_delay > 0) {
	spMSleep(slot_Auto_play_delay);
    }
    
    if (gtalk_sp_audio == NULL) {
	gtalk_sp_audio = spInitAudio();
	spSetAudioSampleRate(gtalk_sp_audio, (double)SAMPLE_RATE);
	spSetAudioBufferSize(gtalk_sp_audio, GTALK_AUDIO_BLOCKSIZE);
	spSetAudioCallbackFunc(gtalk_sp_audio, SP_AUDIO_OUTPUT_POSITION_CALLBACK,
			       output_pos_func, NULL);
    }

    /* open "write only" mode */
    if (spOpenAudioDevice(gtalk_sp_audio, "wo") == SP_FALSE) {
	spDebug(1, "do_output_thread", "Can't open audio device\n");
	return SP_THREAD_RETURN_FAILURE;
    }

    offset = 0;
    block_length = GTALK_AUDIO_BLOCKSIZE * sizeof(short);

    gtalk_prev_tell_pos_ms = 0;
    
    while (!gtalk_aborted_flag && offset < total) {
	spDebug(80, "do_output_thread", "offset = %ld, total = %ld\n", offset, total);

	length = MIN(total - offset, block_length);
	spWriteAudio(gtalk_sp_audio, &wave.data[offset], length);

	offset += block_length;
    }

    spCloseAudioDevice(gtalk_sp_audio);

    if (!gtalk_aborted_flag) {
	if ( prop_Speak_len == AutoOutput )  inqSpeakLen();
	if ( prop_Speak_utt == AutoOutput )  inqSpeakUtt();
    }

    strcpy( slot_Speak_stat, "IDLE" );
    if( prop_Speak_stat == AutoOutput )  inqSpeakStat();

    spDebug(50, "do_output_thread", "done: offset = %d\n", offset);

    return SP_THREAD_RETURN_SUCCESS;
}

void do_output_info(char *);

void do_output_file_sp(char *sfile)
{
#ifdef GTALK_USE_SP_PLUGIN_OUTPUT
    static char o_plugin_name[SP_MAX_LINE];
    spPlugin *o_plugin;
    spWaveInfo wave_info;

    spInitWaveInfo(&wave_info);
    wave_info.samp_rate = (double)SAMPLE_RATE;
    wave_info.num_channel = 1;

    strcpy(o_plugin_name, "");
    
    if ((o_plugin = spOpenFilePluginArg(o_plugin_name, sfile, "w",
					SP_PLUGIN_DEVICE_FILE,
					&wave_info, NULL, 0, NULL, NULL)) != NULL) {
	spWritePlugin(o_plugin, wave.data, wave.nsample);
	spCloseFilePlugin(o_plugin);
    } else {
	/*TmpMsg( "Cannot find suitable plugin for %s\n", sfile );*/
	do_output_file(sfile);
    }
    
    do_output_info(sfile);
#else
    do_output_file(sfile);
#endif
    
    return;
}

void do_output_da()
{
    static int total;
    static void *thread = NULL;

    /*total = SAMPLE_RATE * FRAME_RATE * (totalframe - 1) / 1000;*/
    total = wave.nsample;

    talked_DA_msec = -1;
    already_talked = 1;

    if (thread != NULL) {
	if (gtalk_sp_audio != NULL && gtalk_replay_init_flag) {
	    spStopAudio(gtalk_sp_audio);
	}

	spWaitThread(thread);
	spDestroyThread(thread);
    }
    spDebug(1, "do_output_da", "creating thread...\n");

    gtalk_aborted_flag = 0;

    if ((thread = spCreateThread(0, SP_THREAD_PRIORITY_NORMAL, 
				 do_output_thread, (void *)&total)) == NULL) {
	spDebug(1, "do_output", "Can't create audio thread\n");
	return;
    }

    spDebug(1, "do_output_da", "creating thread done\n");
}

void do_output(char *fn)
{
    in_auto_play = 0;

    if(fn == NULL){
	do_output_da();
    } else {
	do_output_file_sp( fn );
    }
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
void do_auto_output()
{
    in_auto_play = 1;

    do_output_da();
}

void abort_auto_output() {
    abort_demanded_output();
}

#endif /* AUTO_DA */
