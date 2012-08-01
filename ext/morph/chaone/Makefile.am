chaonedir = @CHAONE_DIR@
XSLDATA = chaone.xsl prep.xsl chunker.xsl phonetic.xsl accent.xsl postp.xsl
XMLDATA = ea_symbol_table.xml chunk_rules.xml IPAfn.xml FPAfn.xml ap_rule.xml accent_rule.xml kannjiyomi.xml pos_sys.xml
chaone_DATA = $(XSLDATA) $(XMLDATA)
chaone_PROGRAMS = chaone
chaone_SOURCES = chaone.c
DEFS = -DKANJICODE=\"@KANJICODE@\" -DCHAONE_DIR=\"@CHAONE_DIR@\" @DEFS@
