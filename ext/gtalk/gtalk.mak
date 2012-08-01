# Microsoft Developer Studio Generated NMAKE File, Based on gtalk.dsp
!IF "$(CFG)" == ""
CFG=gtalk - Win32 Debug
!MESSAGE 構成が指定されていません。ﾃﾞﾌｫﾙﾄの gtalk - Win32 Debug を設定します。
!ENDIF 

!IF "$(CFG)" != "gtalk - Win32 Release" && "$(CFG)" != "gtalk - Win32 Debug"
!MESSAGE 指定された ﾋﾞﾙﾄﾞ ﾓｰﾄﾞ "$(CFG)" は正しくありません。
!MESSAGE NMAKE の実行時に構成を指定できます
!MESSAGE ｺﾏﾝﾄﾞ ﾗｲﾝ上でﾏｸﾛの設定を定義します。例:
!MESSAGE 
!MESSAGE NMAKE /f "gtalk.mak" CFG="gtalk - Win32 Debug"
!MESSAGE 
!MESSAGE 選択可能なﾋﾞﾙﾄﾞ ﾓｰﾄﾞ:
!MESSAGE 
!MESSAGE "gtalk - Win32 Release" ("Win32 (x86) Console Application" 用)
!MESSAGE "gtalk - Win32 Debug" ("Win32 (x86) Console Application" 用)
!MESSAGE 
!ERROR 無効な構成が指定されています。
!ENDIF 

!IF "$(OS)" == "Windows_NT"
NULL=
!ELSE 
NULL=nul
!ENDIF 

CPP=cl.exe
RSC=rc.exe

!IF  "$(CFG)" == "gtalk - Win32 Release"

OUTDIR=.\Release
INTDIR=.\Release

ALL : ".\gtalk.exe"


CLEAN :
	-@erase "$(INTDIR)\accent.obj"
	-@erase "$(INTDIR)\chaone.obj"
	-@erase "$(INTDIR)\chasen.obj"
	-@erase "$(INTDIR)\do_output.obj"
	-@erase "$(INTDIR)\do_synthesis.obj"
	-@erase "$(INTDIR)\fileIO.obj"
	-@erase "$(INTDIR)\getline.obj"
	-@erase "$(INTDIR)\hmmsynth.obj"
	-@erase "$(INTDIR)\main.obj"
	-@erase "$(INTDIR)\make_aphrase.obj"
	-@erase "$(INTDIR)\make_breath.obj"
	-@erase "$(INTDIR)\make_duration.obj"
	-@erase "$(INTDIR)\make_mora.obj"
	-@erase "$(INTDIR)\make_parameter.obj"
	-@erase "$(INTDIR)\make_phoneme.obj"
	-@erase "$(INTDIR)\make_sentence.obj"
	-@erase "$(INTDIR)\misc.obj"
	-@erase "$(INTDIR)\mlpg.obj"
	-@erase "$(INTDIR)\model.obj"
	-@erase "$(INTDIR)\modify_parameter.obj"
	-@erase "$(INTDIR)\morph.obj"
	-@erase "$(INTDIR)\read_conf.obj"
	-@erase "$(INTDIR)\send.obj"
	-@erase "$(INTDIR)\server.obj"
	-@erase "$(INTDIR)\sleep.obj"
	-@erase "$(INTDIR)\tag.obj"
	-@erase "$(INTDIR)\text.obj"
	-@erase "$(INTDIR)\tree.obj"
	-@erase "$(INTDIR)\util.obj"
	-@erase "$(INTDIR)\vc60.idb"
	-@erase "$(INTDIR)\vocoder.obj"
	-@erase ".\gtalk.exe"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

CPP_PROJ=/nologo /MT /W3 /GX /O2 /I "..\spAudio" /I "..\spBase" /D "NDEBUG" /D "WIN32" /D "_CONSOLE" /D "_MBCS" /D WORDS_LITTLEENDIAN=1 /D "USE_SPLIB" /Fp"$(INTDIR)\gtalk.pch" /YX /Fo"$(INTDIR)\\" /Fd"$(INTDIR)\\" /FD /c 
BSC32=bscmake.exe
BSC32_FLAGS=/nologo /o"$(OUTDIR)\gtalk.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
LINK32_FLAGS=spAudio.lib spBase.lib ws2_32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /incremental:no /pdb:"$(OUTDIR)\gtalk.pdb" /machine:I386 /out:"gtalk.exe" /libpath:"..\lib" 
LINK32_OBJS= \
	"$(INTDIR)\accent.obj" \
	"$(INTDIR)\chaone.obj" \
	"$(INTDIR)\chasen.obj" \
	"$(INTDIR)\do_output.obj" \
	"$(INTDIR)\do_synthesis.obj" \
	"$(INTDIR)\fileIO.obj" \
	"$(INTDIR)\getline.obj" \
	"$(INTDIR)\hmmsynth.obj" \
	"$(INTDIR)\main.obj" \
	"$(INTDIR)\make_aphrase.obj" \
	"$(INTDIR)\make_breath.obj" \
	"$(INTDIR)\make_duration.obj" \
	"$(INTDIR)\make_mora.obj" \
	"$(INTDIR)\make_parameter.obj" \
	"$(INTDIR)\make_phoneme.obj" \
	"$(INTDIR)\make_sentence.obj" \
	"$(INTDIR)\misc.obj" \
	"$(INTDIR)\mlpg.obj" \
	"$(INTDIR)\model.obj" \
	"$(INTDIR)\modify_parameter.obj" \
	"$(INTDIR)\morph.obj" \
	"$(INTDIR)\read_conf.obj" \
	"$(INTDIR)\send.obj" \
	"$(INTDIR)\server.obj" \
	"$(INTDIR)\sleep.obj" \
	"$(INTDIR)\tag.obj" \
	"$(INTDIR)\text.obj" \
	"$(INTDIR)\tree.obj" \
	"$(INTDIR)\util.obj" \
	"$(INTDIR)\vocoder.obj"

".\gtalk.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "gtalk - Win32 Debug"

OUTDIR=.\Debug
INTDIR=.\Debug

ALL : ".\gtalk.exe"


CLEAN :
	-@erase "$(INTDIR)\accent.obj"
	-@erase "$(INTDIR)\chaone.obj"
	-@erase "$(INTDIR)\chasen.obj"
	-@erase "$(INTDIR)\do_output.obj"
	-@erase "$(INTDIR)\do_synthesis.obj"
	-@erase "$(INTDIR)\fileIO.obj"
	-@erase "$(INTDIR)\getline.obj"
	-@erase "$(INTDIR)\hmmsynth.obj"
	-@erase "$(INTDIR)\main.obj"
	-@erase "$(INTDIR)\make_aphrase.obj"
	-@erase "$(INTDIR)\make_breath.obj"
	-@erase "$(INTDIR)\make_duration.obj"
	-@erase "$(INTDIR)\make_mora.obj"
	-@erase "$(INTDIR)\make_parameter.obj"
	-@erase "$(INTDIR)\make_phoneme.obj"
	-@erase "$(INTDIR)\make_sentence.obj"
	-@erase "$(INTDIR)\misc.obj"
	-@erase "$(INTDIR)\mlpg.obj"
	-@erase "$(INTDIR)\model.obj"
	-@erase "$(INTDIR)\modify_parameter.obj"
	-@erase "$(INTDIR)\morph.obj"
	-@erase "$(INTDIR)\read_conf.obj"
	-@erase "$(INTDIR)\send.obj"
	-@erase "$(INTDIR)\server.obj"
	-@erase "$(INTDIR)\sleep.obj"
	-@erase "$(INTDIR)\tag.obj"
	-@erase "$(INTDIR)\text.obj"
	-@erase "$(INTDIR)\tree.obj"
	-@erase "$(INTDIR)\util.obj"
	-@erase "$(INTDIR)\vc60.idb"
	-@erase "$(INTDIR)\vc60.pdb"
	-@erase "$(INTDIR)\vocoder.obj"
	-@erase "$(OUTDIR)\gtalk.pdb"
	-@erase ".\gtalk.exe"
	-@erase ".\gtalk.ilk"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

CPP_PROJ=/nologo /MTd /W3 /Gm /GX /ZI /Od /I "..\spAudio" /I "..\spBase" /D "_DEBUG" /D "WIN32" /D "_CONSOLE" /D "_MBCS" /D WORDS_LITTLEENDIAN=1 /D "USE_SPLIB" /Fp"$(INTDIR)\gtalk.pch" /YX /Fo"$(INTDIR)\\" /Fd"$(INTDIR)\\" /FD /GZ /c 
BSC32=bscmake.exe
BSC32_FLAGS=/nologo /o"$(OUTDIR)\gtalk.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
LINK32_FLAGS=spAudio.lib spBase.lib ws2_32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /incremental:yes /pdb:"$(OUTDIR)\gtalk.pdb" /debug /machine:I386 /out:"gtalk.exe" /pdbtype:sept /libpath:"..\lib" 
LINK32_OBJS= \
	"$(INTDIR)\accent.obj" \
	"$(INTDIR)\chaone.obj" \
	"$(INTDIR)\chasen.obj" \
	"$(INTDIR)\do_output.obj" \
	"$(INTDIR)\do_synthesis.obj" \
	"$(INTDIR)\fileIO.obj" \
	"$(INTDIR)\getline.obj" \
	"$(INTDIR)\hmmsynth.obj" \
	"$(INTDIR)\main.obj" \
	"$(INTDIR)\make_aphrase.obj" \
	"$(INTDIR)\make_breath.obj" \
	"$(INTDIR)\make_duration.obj" \
	"$(INTDIR)\make_mora.obj" \
	"$(INTDIR)\make_parameter.obj" \
	"$(INTDIR)\make_phoneme.obj" \
	"$(INTDIR)\make_sentence.obj" \
	"$(INTDIR)\misc.obj" \
	"$(INTDIR)\mlpg.obj" \
	"$(INTDIR)\model.obj" \
	"$(INTDIR)\modify_parameter.obj" \
	"$(INTDIR)\morph.obj" \
	"$(INTDIR)\read_conf.obj" \
	"$(INTDIR)\send.obj" \
	"$(INTDIR)\server.obj" \
	"$(INTDIR)\sleep.obj" \
	"$(INTDIR)\tag.obj" \
	"$(INTDIR)\text.obj" \
	"$(INTDIR)\tree.obj" \
	"$(INTDIR)\util.obj" \
	"$(INTDIR)\vocoder.obj"

".\gtalk.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ENDIF 

.c{$(INTDIR)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cpp{$(INTDIR)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cxx{$(INTDIR)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.c{$(INTDIR)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cpp{$(INTDIR)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cxx{$(INTDIR)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<


!IF "$(NO_EXTERNAL_DEPS)" != "1"
!IF EXISTS("gtalk.dep")
!INCLUDE "gtalk.dep"
!ELSE 
!MESSAGE Warning: cannot find "gtalk.dep"
!ENDIF 
!ENDIF 


!IF "$(CFG)" == "gtalk - Win32 Release" || "$(CFG)" == "gtalk - Win32 Debug"
SOURCE=.\accent.c

"$(INTDIR)\accent.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\chaone.cpp

"$(INTDIR)\chaone.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\chasen.c

"$(INTDIR)\chasen.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\do_output.c

"$(INTDIR)\do_output.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\do_synthesis.c

"$(INTDIR)\do_synthesis.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\fileIO.c

"$(INTDIR)\fileIO.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\getline.c

"$(INTDIR)\getline.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\hmmsynth.c

"$(INTDIR)\hmmsynth.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\main.c

"$(INTDIR)\main.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\make_aphrase.c

"$(INTDIR)\make_aphrase.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\make_breath.c

"$(INTDIR)\make_breath.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\make_duration.c

"$(INTDIR)\make_duration.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\make_mora.c

"$(INTDIR)\make_mora.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\make_parameter.c

"$(INTDIR)\make_parameter.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\make_phoneme.c

"$(INTDIR)\make_phoneme.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\make_sentence.c

"$(INTDIR)\make_sentence.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\misc.c

"$(INTDIR)\misc.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\mlpg.c

"$(INTDIR)\mlpg.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\model.c

"$(INTDIR)\model.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\modify_parameter.c

"$(INTDIR)\modify_parameter.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\morph.c

"$(INTDIR)\morph.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\read_conf.c

"$(INTDIR)\read_conf.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\send.c

"$(INTDIR)\send.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\server.c

"$(INTDIR)\server.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\sleep.c

"$(INTDIR)\sleep.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\tag.c

"$(INTDIR)\tag.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\text.c

"$(INTDIR)\text.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\tree.c

"$(INTDIR)\tree.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\util.c

"$(INTDIR)\util.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\vocoder.c

"$(INTDIR)\vocoder.obj" : $(SOURCE) "$(INTDIR)"



!ENDIF 

