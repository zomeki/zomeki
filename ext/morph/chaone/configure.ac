#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ(2.61)
AC_INIT([chaone], [1.3.2], [unidic@kokken.go.jp])
AM_INIT_AUTOMAKE

# Checks for programs.
AC_PROG_CC

# Checks for libraries.
AC_CHECK_LIB([xml2], [
    xmlCleanupParser,
    xlFreeDoc,
    xmlLoadExtDtdDefaultValue,
    xmlFree,
    xmlParseMemory,
    xmlStrcat,
    xmlStrdup,
    xmlSubstituteEntitiesDefault])
AC_CHECK_LIB([xslt], [
    xsltApplyStylesheet,
    xsltCleanupGlobals,
    xsltFreeStylesheet,
    xsltParseStylesheetFile,
    xsltSaveResultToFile])
AC_CHECK_LIB([exslt], [
    exsltRegisterAll])

# Checks for header files.
AC_HEADER_STDC
AC_CHECK_HEADERS([stdlib.h string.h])
AC_CHECK_HEADERS([libxslt/transform.h libxslt/xsltutils.h libexslt/exslt.h])

# Checks for xml2-config
AC_PATH_PROG( XML2_CONFIG, xml2-config, no)

if test "$XML2_CONFIG" = "no" ; then
	AC_MSG_WARN( "xml2-config is not found")
else
	XML_CPPFLAGS=`$XML2_CONFIG --cflags`
	XML_LIBS=`$XML2_CONFIG --libs`
	CPPFLAGS="$CPPFLAGS $XML_CPPFLAGS"
fi

# Checks for typedefs, structures, and compiler characteristics.
AC_C_CONST

# Checks for library functions.
AC_FUNC_MALLOC

# Other variables
AC_ARG_WITH(kanjicode,
	[  --with-kanjicode[=CODE]   set kanji code (EUC-JP|ISO-2022-JP|Shift_JIS|UTF-8) [[UTF-8]]])
if test x$with_kanjicode != x; then
	AC_MSG_CHECKING(kanjicode option)

	case "$with_kanjicode" in
		EUC-JP)
			KANJICODE="EUC-JP"
			;;
		ISO-2022-JP)
			KANJICODE="ISO-2022-JP"
			;;
		Shift_JIS)
			KANJICODE="Shift_JIS"
			;;
		UTF-8)
			KANJICODE="UTF-8"
			;;
		*)
			AC_MSG_ERROR(Fatal error!  KANJICODE must be EUC-JP|ISO-2022-JP|Shift_JIS|UTF-8)
			exit 1
			;;
	esac
	AC_MSG_RESULT($with_kanjicode)
else
	KANJICODE="EUC-JP"
fi		
AC_SUBST(KANJICODE)

AC_ARG_WITH(chaonedir,
	[  --with-chaonedir[=DIR]    set chaone installation directory [[PREFIX/chaone]]])
if test x$with_chaonedir != x; then
	AC_MSG_CHECKING(chaone option)
	CHAONE_DIR=$with_chaonedir
	AC_MSG_RESULT($CHAONE_DIR)
else
	if test "x$prefix" = "xNONE"; then
	   CHAONE_DIR=${ac_default_prefix}/$PACKAGE_NAME
	else
	   CHAONE_DIR=${prefix}/$PACKAGE_NAME
	fi
fi
AC_SUBST(CHAONE_DIR)

AC_CONFIG_FILES([Makefile])
AC_OUTPUT
