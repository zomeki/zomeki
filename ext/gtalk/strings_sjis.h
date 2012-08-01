/* $Id: strings_sjis.h,v 1.5 2009/02/12 17:43:42 sako Exp $                                            */
#define TOKEN_MEISHI "名詞"
#define TOKEN_DOUSHI "動詞"
#define TOKEN_KEIYOUSHI "形容詞"

#define KUTEN "、"
#define TOUTEN "。"
#define GIMONFU "？"

#define KATAKANA_SMALL_A "ァ"
#define KATAKANA_SMALL_I "ィ"
#define KATAKANA_SMALL_U "ゥ"
#define KATAKANA_SMALL_E "ェ"
#define KATAKANA_SMALL_O "ォ"
#define KATAKANA_SMALL_YA "ャ"
#define KATAKANA_SMALL_YU "ュ"
#define KATAKANA_SMALL_YO "ョ"

/*---- for text.c ----*/
#define KANSUUJI_ZERO "〇"
#define KANSUUJI_ICHI "一"
#define KANSUUJI_NI "二"
#define KANSUUJI_SAN "三"
#define KANSUUJI_SHI "四"
#define KANSUUJI_GO "五"
#define KANSUUJI_ROKU "六"
#define KANSUUJI_SHICHI "七"
#define KANSUUJI_HACHI "八"
#define KANSUUJI_KYUU "九"

#define KANSUUJI_KETA_ZERO "〇"
#define KANSUUJI_KETA_ICHI "一"
#define KANSUUJI_KETA_JUU "十"
#define KANSUUJI_KETA_HYAKU "百"
#define KANSUUJI_KETA_SEN "千"
#define KANSUUJI_KETA_MAN "万"
#define KANSUUJI_KETA_OKU "億"
#define KANSUUJI_KETA_CHOU "兆"

#define KANJI_TIME_NEN "年"
#define KANJI_TIME_TSUKI "月"
#define KANJI_TIME_NICHI "日"
#define KANJI_TIME_JI "時"
#define KANJI_TIME_FUN "分"
#define KANJI_TIME_BYOU "秒"

#define ZENKAKU_EXCLAMATION "！"
#define ZENKAKU_DOUBLE_QUOTATION "”"
#define ZENKAKU_SHARP "＃"
#define ZENKAKU_DOLLAR "＄"
#define ZENKAKU_PERCENT "％"
#define ZENKAKU_AMPERSAND "＆"
#define ZENKAKU_QUOTATION "’"
#define ZENKAKU_LEFT_PARENTHESIS "（"
#define ZENKAKU_RIGHT_PARENTHESIS "）"
#define ZENKAKU_ASTERISK "＊"
#define ZENKAKU_PLUS "＋"
#define ZENKAKU_COMMA "，"
#define ZENKAKU_CHOUON "ー"
#define ZENKAKU_PERIOD "．"
#define ZENKAKU_TOUTEN "、"
#define ZENKAKU_MINUS "－"
#define ZENKAKU_KUTEN "。"
#define ZENKAKU_SLASH "／"
#define ZENKAKU_EQUAL "＝"
#define ZENKAKU_QUESTION "？"
#define ZENKAKU_COLON "："
#define ZENKAKU_SEMICOLON "；"
#define ZENKAKU_EN "￥"
#define ZENKAKU_ATMARK "＠"
#define ZENKAKU_HAT "＾"
#define ZENKAKU_LT "＜"
#define ZENKAKU_GT "＞"
#define ZENKAKU_UNDERSCORE "＿"
#define ZENKAKU_LEFT_BRACKET "［"
#define ZENKAKU_RIGHT_BRACKET "］"
#define ZENKAKU_BACK_QUOTATION "‘"
#define ZENKAKU_LEFT_BRACE "｛"
#define ZENKAKU_RIGHT_BRACE "｝"
#define ZENKAKU_VERTICAL_BAR "｜"

#define PRON_SYM_TSUITACHI "<PRON SYM='ツイタチ'>"
#define PRON_SYM_FUTSUKA "<PRON SYM='フツカ'>"
#define PRON_SYM_MIKKA "<PRON SYM='ミッカ'>"
#define PRON_SYM_YOKKA "<PRON SYM='ヨッカ'>"
#define PRON_SYM_ITSUKA "<PRON SYM='イツカ'>"
#define PRON_SYM_MUIKA "<PRON SYM='ムイカ'>"
#define PRON_SYM_NANOKA "<PRON SYM='ナノカ'>"
#define PRON_SYM_YOUKA "<PRON SYM='ヨーカ'>"
#define PRON_SYM_KOKONOKA "<PRON SYM='ココノカ'>"
#define PRON_SYM_TOUKA "<PRON SYM='トーカ'>"
#define PRON_SYM_HATSUKA "<PRON SYM='ハツカ'>"

#define ZENKAKU_ALPHABET_FIRST_BYTE 0x82
#define ZENKAKU_NUMBER_SECOND_BYTE_MIN 0x4F
#define ZENKAKU_NUMBER_SECOND_BYTE_MAX 0x58
#define ZENKAKU_CAPITAL_ALPHABET_SECOND_BYTE_MIN 0x60
#define ZENKAKU_CAPITAL_ALPHABET_SECOND_BYTE_MAX 0x79
#define ZENKAKU_ALPHABET_SECOND_BYTE_MIN 0x81
#define ZENKAKU_ALPHABET_SECOND_BYTE_MAX 0x9A

#define ACCENT_MARK "’"
#define is_ZENKAKU_ALPNUM(x,y) ( (x) == ZENKAKU_ALPHABET_FIRST_BYTE && ( \
( ((y) >= ZENKAKU_NUMBER_SECOND_BYTE_MIN) && ((y) <= ZENKAKU_ALPHABET_SECOND_BYTE_MAX))))
