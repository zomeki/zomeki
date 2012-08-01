/* Copyright (c) 2000-2006                  */
/*   Yamashita Lab., Ritsumeikan University */
/*   All rights reserved                    */
/*                                          */
/* $Id: pos.h,v 1.7 2007/02/16 09:58:52 sako Exp $                                     */

/* 品詞のID */

#define H_MEISHI                      1000
#define H_MEISHI_FUTSUU_IPPAN         1010
#define H_MEISHI_FUTSUU_SAHEN         1020
#define H_MEISHI_FUTSUU_KEIJOU        1030
#define H_MEISHI_FUTSUU_FUKUSHI       1040
#define H_MEISHI_FUTSUU_SAHENKEIJOU   1050
#define H_MEISHI_KOYUU_IPPAN          1100
#define H_MEISHI_KOYUU_JINMEI_IPPAN   1110
#define H_MEISHI_KOYUU_JINMEI_SEI     1111
#define H_MEISHI_KOYUU_JINMEI_MEI     1112
#define H_MEISHI_KOYUU_CHIMEI_IPPAN   1120
#define H_MEISHI_KOYUU_CHIMEI_KUNI    1121
#define H_MEISHI_KOYUU_SOSHIKI        1137
#define H_MEISHI_JODOUSHIGOKAN        1000
#define H_MEISHI_KAZU                 1500
#define H_MEISHI_KAZU_IPPAN           1500
#define H_MEISHI_KAZU_KETA            1510
#define H_DAIMEISHI                   2000

#define H_KEIJOUSHI                   2200
#define H_KEIJOUSHI_IPPAN             2210
#define H_KEIJOUSHI_JODOUGOKAN        2220
#define H_KEIJOUSHI_TARI              2230
#define H_RENTAISHI                   2500
#define H_FUKUSHI                     3000
#define H_SETSUZOKUSHI                3500
#define H_KANDOUSHI                   4000
#define H_KANDOUSHI_IPPAN             4010
#define H_KANDOUSHI_FILLER            4020

#define H_DOUSHI                      5000
#define H_DOUSHI_IPPAN                5010
#define H_DOUSHI_HIJIRITSU            5020

#define H_KEIYOUSHI                   5500
#define H_KEIYOUSHI_IPPAN             5510
#define H_KEIYOUSHI_HIJIRITSU         5520

#define H_JODOUSHI                    4500

#define H_JOSHI                       6000
#define H_JOSHI_KAKUJOSHI             6100
#define H_JOSHI_KAKUJOSHI_IPPAN       6110
#define H_JOSHI_KAKUJOSHI_RENYOU      6120
#define H_JOSHI_KAKUJOSHI_RENTAI      6130
#define H_JOSHI_FUKUJOSHI             6200
#define H_JOSHI_KAKARIJOSHI           6300
#define H_JOSHI_SETSUZOKUJOSHI        6400
#define H_JOSHI_SHUUJOSHI             6500
#define H_JOSHI_JUNTAIJOSHI           6600

#define H_SETTOUJI                    7000
#define H_SETTOUJI_MEISHI_IPPAN       7110
#define H_SETTOUJI_MEISHI_SUUSHI      7120
#define H_SETTOUJI_KEIJOUSHI          7200
#define H_SETTOUJI_DOUSHI             7300
#define H_SETTOUJI_KEIYOUSHI          7400

#define H_SETSUBIJI                   8000
#define H_SETSUBIJI_MEISHI_IPPAN      8010
#define H_SETSUBIJI_MEISHI_SAHEN      8120
#define H_SETSUBIJI_MEISHI_KEIJOU     8130
#define H_SETSUBIJI_MEISHI_HUKUSHI    8140
#define H_SETSUBIJI_MEISHI_JINMEI     8151
#define H_SETSUBIJI_MEISHI_CHIMEI     8152
#define H_SETSUBIJI_MEISHI_SOHIKI     8153
#define H_SETSUBIJI_MEISHI_JOSHUUSHI  8160
#define H_SETSUBIJI_MEISHI_SAHENKEIJOU 8170
#define H_SETSUBIJI_KEIJOUSHI         8200
#define H_SETSUBIJI_DOUSHI            8300
#define H_SETSUBIJI_KEIYOUSHI         8400

#define H_KIGOU                       9000
#define H_KIGOU_IPPAN                 9110
#define H_KIGOU_MOJI                  9120
#define H_KIGOU_SUUJI                 9130

#define H_SONOTA                      9500
#define H_SONOTA_IPPAN                9510
#define H_SONOTA_SUUJI                9520
#define H_SONOTA_KUUHAKU              9530
#define H_SONOTA_KUTEN                9541
#define H_SONOTA_TOUTEN               9542
#define H_SONOTA_KAKKO_HIRAKU         9551
#define H_SONOTA_KAKKO_TOJIRU         9552
#define H_KUUHAKU                     9500

#define H_MICHIGO                     9999

#define	IS_MEISHI(h)	   ( ((h)>=H_MEISHI && (h)<=H_DAIMEISHI) )
#define	IS_KOYUU_MEISHI(h) ( ((h)>=H_KOYUU_IPPAN && (h)<H_KAZU_IPPAN) )
#define	IS_DAIMEISHI(h)	   ( ((h)==H_DAIMEISHI) )
#define IS_KEIJOUSHI(h)    ( ((h)>=H_KEIJOUSHI && (h)<H_RENTAISHI) )
#define IS_RENTAISHI(h)    ( ((h)==H_RENTAISHI) )
#define IS_FUKUSHI(h)      ( ((h)==H_FUKUSHI) )
#define IS_SETSUZOKUSHI(h) ( ((h)==H_SETSUZOKUSHI) )
#define IS_KANDOUSHI(h)    ( ((h)>=H_KANDOUSHI && (h)<H_DOUSHI) )
#define IS_FILLER(h)       ( ((h)==H_FILLER) )
#define	IS_DOUSHI(h)	   ( ((h)>=H_DOUSHI && (h)<H_KEIYOUSHI) )
#define	IS_KEIYOUSHI(h)	   ( ((h)>=H_KEIYOUSHI && (h)<H_JODOUSHI) )
#define	IS_JODOUSHI(h)	   ( ((h)==H_JODOUSHI) )
#define	IS_JOSHI(h)	       ( ((h)>=H_JOSHI && (h)<H_SETTOUJI) )
#define IS_SETTOUJI(h)     ( ((h)=>H_SETTOUJI && (h)<H_SETSUBIJI) )
#define IS_SETSUBIJI(h)    ( ((h)==H_SETSUBIJI && (h)<H_KIGOU) )
#define IS_KIGOU(h)        ( ((h)>=H_KIGOU && (h)<H_SONOTA) )
#define IS_SONOTA(h)       ( ((h)>=h_SONOTA && (h)<H_MICHIGO) )

#define	IS_FUZOKUGO(h)	( IS_JODOUSHI(h) || IS_JOSHI(h) )
#define	IS_JIRITSUGO(h)	( ! IS_FUZOKUGO(h) )
#define	IS_KUTOUTEN(h)	( ((h)==H_SONOTA_KUTEN || (h)==H_SONOTA_TOUTEN) )


/* 一般的なカテゴリーは後に宣言しておく必要あり。
   「名詞-固有名詞」は「名詞」より先に。 */


/* 活用型のID */

#define KATA_GODAN_KAGYOU_IPPAN             1000 /* 五段-カ行-一般 */
#define KATA_GODAN_KAGYOU_IPPAN_IPPAN       1000 /* 五段-カ行-一般-一般 */
#define KATA_GODAN_KAGYOU_IPPAN_IDAN        1001 /* 五段-カ行-一般-イ段 */
#define KATA_GODAN_KAGYOU_IKU               1002 /* 五段-カ行-イク */
#define KATA_GODAN_KAGYOU_YUKU              1003 /* 五段-カ行-ユク */
#define KATA_GODAN_GAGYOU_IPPAN             1010 /* 五段-ガ行-一般 */
#define KATA_GODAN_GAGYOU_IDAN              1011 /* 五段-ガ行-イ段 */
#define KATA_GODAN_GAGYOU                   1010 /* 五段-ガ行 */
#define KATA_GODAN_SAGYOU                   1020 /* 五段-サ行 */
#define KATA_GODAN_TAGYOU                   1030 /* 五段-タ行 */
#define KATA_GODAN_NAGYOU                   1040 /* 五段-ナ行 */
#define KATA_GODAN_BAGYOU                   1050 /* 五段-バ行 */
#define KATA_GODAN_MAGYOU_IPPAN             1060 /* 五段-マ行-一般 */
#define KATA_GODAN_MAGYOU_SUMU              1061 /* 五段-マ行-済ム */
#define KATA_GODAN_MAGYOU                   1060 /* 五段-マ行 */
#define KATA_GODAN_RAGYOU_IPPAN             1070 /* 五段-ラ行-一般 */
#define KATA_GODAN_RAGYOU_ARU               1071 /* 五段-ラ行-アル */
#define KATA_GODAN_RAGYOU_SARU              1072 /* 五段-ラ行-サル */
#define KATA_GODAN_WAAGYOU_IPPAN            1100 /* 五段-ワア行-一般 */
#define KATA_GODAN_WAAGYOU_ADAN_IPPAN       1100 /* 五段-ワア行-ア段-一般 */
#define KATA_GODAN_WAAGYOU_ADAN_AU_IPPAN    1101 /* 五段-ワア行-ア段-アウ-一般 */
#define KATA_GODAN_WAAGYOU_ADAN_AU_AU       1102 /* 五段-ワア行-ア段-アウ-あう */
#define KATA_GODAN_WAAGYOU_ADAN_KAU_IPPAN   1103 /* 五段-ワア行-ア段-カウ-一般 */
#define KATA_GODAN_WAAGYOU_ADAN_KAU_KAU     1104 /* 五段-ワア行-ア段-カウ-かう */
#define KATA_GODAN_WAAGYOU_ADAN_GAU_IPPAN   1105 /* 五段-ワア行-ア段-ガウ-一般 */
#define KATA_GODAN_WAAGYOU_ADAN_GAU_GAU     1106 /* 五段-ワア行-ア段-ガウ-がう */
#define KATA_GODAN_WAAGYOU_ADAN_TAU_IPPAN   1107 /* 五段-ワア行-ア段-タウ-一般 */
#define KATA_GODAN_WAAGYOU_ADAN_TAU_TAU     1108 /* 五段-ワア行-ア段-タウ-たう */
#define KATA_GODAN_WAAGYOU_ADAN_DAU_IPPAN   1109 /* 五段-ワア行-ア段-ダウ-一般 */
#define KATA_GODAN_WAAGYOU_ADAN_DAU_DAU     1110 /* 五段-ワア行-ア段-ダウ-だう */
#define KATA_GODAN_WAAGYOU_ADAN_NAU_IPPAN   1111 /* 五段-ワア行-ア段-ナウ-一般 */
#define KATA_GODAN_WAAGYOU_ADAN_NAU_NAU     1112 /* 五段-ワア行-ア段-ナウ-なう */
#define KATA_GODAN_WAAGYOU_ADAN_HAU_IPPAN   1113 /* 五段-ワア行-ア段-ハウ-一般 */
#define KATA_GODAN_WAAGYOU_ADAN_HAU_HAU     1114 /* 五段-ワア行-ア段-ハウ-はう */
#define KATA_GODAN_WAAGYOU_ADAN_BAU_IPPAN   1115 /* 五段-ワア行-ア段-バウ-一般 */
#define KATA_GODAN_WAAGYOU_ADAN_BAU_BAU     1116 /* 五段-ワア行-ア段-バウ-ばう */
#define KATA_GODAN_WAAGYOU_ADAN_MAU_IPPAN   1117 /* 五段-ワア行-ア段-マウ-一般 */
#define KATA_GODAN_WAAGYOU_ADAN_MAU_MAU     1118 /* 五段-ワア行-ア段-マウ-まう */
#define KATA_GODAN_WAAGYOU_ADAN_YAU_IPPAN   1119 /* 五段-ワア行-ア段-ヤウ-一般 */
#define KATA_GODAN_WAAGYOU_ADAN_YAU_YAU     1120 /* 五段-ワア行-ア段-ヤウ-やう */
#define KATA_GODAN_WAAGYOU_ADAN_RAU_IPPAN   1121 /* 五段-ワア行-ア段-ラウ-一般 */
#define KATA_GODAN_WAAGYOU_ADAN_RAU_RAU     1122 /* 五段-ワア行-ア段-ラウ-らう */
#define KATA_GODAN_WAAGYOU_ADAN_WAU_IPPAN   1123 /* 五段-ワア行-ア段-ワウ-一般 */
#define KATA_GODAN_WAAGYOU_ADAN_WAU_WAU     1124 /* 五段-ワア行-ア段-ワウ-わう */
#define KATA_GODAN_WAAGYOU_IDAN_IPPAN       1130 /* 五段-ワア行-イ段-一般 */
#define KATA_GODAN_WAAGYOU_IDAN_IU          1131 /* 五段-ワア行-イ段-イウ */
#define KATA_GODAN_WAAGYOU_UDAN_IPPAN       1140 /* 五段-ワア行-ウ段-一般 */
#define KATA_GODAN_WAAGYOU_UDAN_TUU         1141 /* 五段-ワア行-ウ段-ツウ */
#define KATA_GODAN_WAAGYOU_EDAN             1150 /* 五段-ワア行-エ段 */
#define KATA_GODAN_WAAGYOU_ODAN             1160 /* 五段-ワア行-オ段 */
#define KATA_UEICHIDAN_AGYOU_IPPAN          2000 /* 上一段-ア行-一般 */
#define KATA_UEICHIDAN_AGYOU_IDAN           2001 /* 上一段-ア行-イ段 */
#define KATA_UEICHIDAN_AGYOU                2000 /* 上一段-ア行 */
#define KATA_UEICHIDAN_KAGYOU               2010 /* 上一段-カ行 */
#define KATA_UEICHIDAN_GAGYOU               2020 /* 上一段-ガ行 */
#define KATA_UEICHIDAN_ZAGYOU               2030 /* 上一段-ザ行 */
#define KATA_UEICHIDAN_TAGYOU               2040 /* 上一段-タ行 */
#define KATA_UEICHIDAN_NAGYOU               2050 /* 上一段-ナ行 */
#define KATA_UEICHIDAN_HAGYOU               2060 /* 上一段-ハ行 */
#define KATA_UEICHIDAN_BAGYOU               2070 /* 上一段-バ行 */
#define KATA_UEICHIDAN_MAGYOU               2080 /* 上一段-マ行 */
#define KATA_UEICHIDAN_RAGYOU_IPPAN         2090 /* 上一段-ラ行-一般 */
#define KATA_UEICHIDAN_RAGYOU_RIRU          2091 /* 上一段-ラ行-リル */
#define KATA_UEICHIDAN_RAGYOU               2090 /* 上一段-ラ行 */
#define KATA_SHIMOICHIDAN_AGYOU_IPPAN       2500 /* 下一段-ア行-一般 */
#define KATA_SHIMOICHIDAN_AGYOU_EDAN        2501 /* 下一段-ア行-エ段 */
#define KATA_SHIMOICHIDAN_AGYOU             2500 /* 下一段-ア行 */
#define KATA_SHIMOICHIDAN_KAGYOU            2510 /* 下一段-カ行 */
#define KATA_SHIMOICHIDAN_GAGYOU            2520 /* 下一段-ガ行 */
#define KATA_SHIMOICHIDAN_SAGYOU_IPPAN      2530 /* 下一段-サ行-一般 */
#define KATA_SHIMOICHIDAN_SAGYOU_SERU       2531 /* 下一段-サ行-セル */
#define KATA_SHIMOICHIDAN_SAGYOU            2530 /* 下一段-サ行 */
#define KATA_SHIMOICHIDAN_ZAGYOU            2540 /* 下一段-ザ行 */
#define KATA_SHIMOICHIDAN_TAGYOU            2550 /* 下一段-タ行 */
#define KATA_SHIMOICHIDAN_DAGYOU            2560 /* 下一段-ダ行 */
#define KATA_SHIMOICHIDAN_NAGYOU            2570 /* 下一段-ナ行 */
#define KATA_SHIMOICHIDAN_HAGYOU            2590 /* 下一段-ハ行 */
#define KATA_SHIMOICHIDAN_BAGYOU            2600 /* 下一段-バ行 */
#define KATA_SHIMOICHIDAN_MAGYOU            2610 /* 下一段-マ行 */
#define KATA_SHIMOICHIDAN_RAGYOU_IPPAN      2620 /* 下一段-ラ行-一般 */
#define KATA_SHIMOICHIDAN_RAGYOU_RERU       2621 /* 下一段-ラ行-レル */
#define KATA_SHIMOICHIDAN_RAGYOU_KURERU     2622 /* 下一段-ラ行-呉レル */
#define KATA_KAGYOUHENKAKU_IPPAN            3000 /* カ行変格-一般 */
#define KATA_KAGYOUHENKAKU_KURU             3020 /* カ行変格-くる */
#define KATA_KAGYOUHENKAKU                  3000 /* カ行変格 */
#define KATA_SAGYOUHENKAKU_IRU              3510 /* サ行変格-為ル */
#define KATA_SAGYOUHENKAKU_SURU             3520 /* サ行変格-スル */
#define KATA_SAGYOUHENKAKU_ZURU             3530 /* サ行変格-ズル */
#define KATA_SAGYOUHENKAKU                  3500 /* サ行変格 */
#define KATA_ZAGYOUHENKAKU                  3500 /* ザ行変格 */
#define KATA_BUNGOYODAN_KAGYOU              4010 /* 文語四段-カ行 */
#define KATA_BUNGOYODAN_GAGYOU              4020 /* 文語四段-ガ行 */
#define KATA_BUNGOYODAN_SAGYOU              4030 /* 文語四段-サ行 */
#define KATA_BUNGOYODAN_TAGYOU              4040 /* 文語四段-タ行 */
#define KATA_BUNGOYODAN_HAGYOU_ADAN_KAU_IPPAN   4050 /* 文語四段-ハ行-ア段-カウ-一般 */
#define KATA_BUNGOYODAN_HAGYOU_ADAN_KAU_KAU   4051 /* 文語四段-ハ行-ア段-カウ-かふ */
#define KATA_BUNGOYODAN_HAGYOU_ADAN_GAU_IPPAN   4052 /* 文語四段-ハ行-ア段-ガウ-一般 */
#define KATA_BUNGOYODAN_HAGYOU_ADAN_GAU_GAU   4053 /* 文語四段-ハ行-ア段-ガウ-がふ */
#define KATA_BUNGOYODAN_HAGYOU_ADAN_NAU_IPPAN   4054 /* 文語四段-ハ行-ア段-ナウ-一般 */
#define KATA_BUNGOYODAN_HAGYOU_ADAN_NAU_NAU   4055 /* 文語四段-ハ行-ア段-ナウ-なふ */
#define KATA_BUNGOYODAN_HAGYOU_ADAN_TAMAU_IPPAN   4056 /* 文語四段-ハ行-ア段-給ウ-一般 */
#define KATA_BUNGOYODAN_HAGYOU_ADAN_TAMAU_MAU   4057 /* 文語四段-ハ行-ア段-給ウ-まふ */
#define KATA_BUNGOYODAN_HAGYOU_IDAN_IPPAN   4060 /* 文語四段-ハ行-イ段-一般 */
#define KATA_BUNGOYODAN_HAGYOU_IDAN_IU   4061 /* 文語四段-ハ行-イ段-イウ */
#define KATA_BUNGOYODAN_HAGYOU_UDAN   4070 /* 文語四段-ハ行-ウ段 */
#define KATA_BUNGOYODAN_HAGYOU_EDAN   4080 /* 文語四段-ハ行-エ段 */
#define KATA_BUNGOYODAN_HAGYOU_ODAN   4090 /* 文語四段-ハ行-オ段 */
#define KATA_BUNGOYODAN_HAGYOU_HU   4050 /* 文語四段-ハ行-ふ */
#define KATA_BUNGOYODAN_BAGYOU   4100 /* 文語四段-バ行 */
#define KATA_BUNGOYODAN_MAGYOU   4110 /* 文語四段-マ行 */
#define KATA_BUNGOYODAN_RAGYOU   4120 /* 文語四段-ラ行 */
#define KATA_BUNGONIDAN_KAGYOU   5010 /* 文語上二段-カ行 */
#define KATA_BUNGOKAMINIDAN_GAGYOU   5020 /* 文語上二段-ガ行 */
#define KATA_BUNGOKAMINIDAN_TAGYOU   5030 /* 文語上二段-タ行 */
#define KATA_BUNGOKAMINIDAN_DAGYOU   5040 /* 文語上二段-ダ行 */
#define KATA_BUNGOKAMINIDAN_HAGYOU   5050 /* 文語上二段-ハ行 */
#define KATA_BUNGOKAMINIDAN_BAGYOU   5060 /* 文語上二段-バ行 */
#define KATA_BUNGOKAMINIDAN_MAGYOU   5070 /* 文語上二段-マ行 */
#define KATA_BUNGOKAMINIDAN_YAGYOU   5080 /* 文語上二段-ヤ行 */
#define KATA_BUNGOKAMINIDAN_RAGYOU   5090 /* 文語上二段-ラ行 */
#define KATA_BUNGOSHIMONIDAN_AGYOU_IPPAN   5510 /* 文語下二段-ア行-一般 */
#define KATA_BUNGOSHIMONIDAN_AGYOU_U   5511 /* 文語下二段-ア行-う */
#define KATA_BUNGOSHIMONIDAN_AGYOU    5510 /* 文語下二段-ア行 */
#define KATA_BUNGOSHIMONIDAN_KAGYOU   5520 /* 文語下二段-カ行 */
#define KATA_BUNGOSHIMONIDAN_GAGYOU   5530 /* 文語下二段-ガ行 */
#define KATA_BUNGOSHIMONIDAN_SAGYOU   5540 /* 文語下二段-サ行 */
#define KATA_BUNGOSHIMONIDAN_ZAGYOU   5550 /* 文語下二段-ザ行 */
#define KATA_BUNGOSHIMONIDAN_TAGYOU   5560 /* 文語下二段-タ行 */
#define KATA_BUNGOSHIMONIDAN_DAGYOU_IPPAN   5570 /* 文語下二段-ダ行-一般 */
#define KATA_BUNGOSHIMONIDAN_DAGYOU_DU   5571 /* 文語下二段-ダ行-づ */
#define KATA_BUNGOSHIMONIDAN_NAGYOU_IPPAN   5580 /* 文語下二段-ナ行-一般 */
#define KATA_BUNGOSHIMONIDAN_NAGYOU_NU   5581 /* 文語下二段-ナ行-ぬ */
#define KATA_BUNGOSHIMONIDAN_NAGYOU   5580 /* 文語下二段-ナ行 */
#define KATA_BUNGOSHIMONIDAN_HAGYOU_IPPAN   5590 /* 文語下二段-ハ行-一般 */
#define KATA_BUNGOSHIMONIDAN_HAGYOU   5590 /* 文語下二段-ハ行 */
#define KATA_BUNGOSHIMONIDAN_HAGYOU_KEI_IPPAN   5591 /* 文語下二段-ハ行-経-一般 */
#define KATA_BUNGOSHIMONIDAN_HAGYOU_KEI_HU   5592 /* 文語下二段-ハ行-経-ふ */
#define KATA_BUNGOSHIMONIDAN_BAGYOU   5600 /* 文語下二段-バ行 */
#define KATA_BUNGOSHIMONIDAN_MAGYOU   5610 /* 文語下二段-マ行 */
#define KATA_BUNGOSHIMONIDAN_YAGYOU   5620 /* 文語下二段-ヤ行 */
#define KATA_BUNGOSHIMONIDAN_RAGYOU   5630 /* 文語下二段-ラ行 */
#define KATA_BUNGOSHIMONIDAN_RA   5640 /* 文語下二段-ワ行 */
#define KATA_BUNGOKAGYOUHENKAKU_IPPAN   6010 /* 文語カ行変格-一般 */
#define KATA_BUNGOKAGYOUHENKAKU   6010 /* 文語カ行変格 */
#define KATA_BUNGOKAGYOUHENKAKU_KU   6020 /* 文語カ行変格-く */
#define KATA_BUNGOSAGYOUHENKAKU_SU   6110 /* 文語サ行変格-ス */
#define KATA_BUNGOSAGYOUHENKAKU_ZU   6120 /* 文語サ行変格-ズ */
#define KATA_BUNGOSAGYOUHENKAKU   6100 /* 文語サ行変格 */
#define KATA_BUNGONAGYOUHENKAKU   6210 /* 文語ナ行変格 */
#define KATA_BUNGORAGYOUHENKAKU   6310 /* 文語ラ行変格 */
#define KATA_KEIYOUSHI_ADAN_KAI_IPPAN   7010 /* 形容詞-ア段-カイ-一般 */
#define KATA_KEIYOUSHI_ADAN_KAI_KAI   7011 /* 形容詞-ア段-カイ-かい */
#define KATA_KEIYOUSHI_ADAN_GAI_IPPAN   7020 /* 形容詞-ア段-ガイ-一般 */
#define KATA_KEIYOUSHI_ADAN_GAI_GAI   7021 /* 形容詞-ア段-ガイ-がい */
#define KATA_KEIYOUSHI_ADAN_SAI_IPPAN   7030 /* 形容詞-ア段-サイ-一般 */
#define KATA_KEIYOUSHI_ADAN_SAI_SAI   7031 /* 形容詞-ア段-サイ-さい */
#define KATA_KEIYOUSHI_ADAN_TAI_IPPAN   7040 /* 形容詞-ア段-タイ-一般 */
#define KATA_KEIYOUSHI_ADAN_TAI_TAI   7041 /* 形容詞-ア段-タイ-たい */
#define KATA_KEIYOUSHI_ADAN_CHAI_IPPAN   7050 /* 形容詞-ア段-チャイ-一般 */
#define KATA_KEIYOUSHI_ADAN_CHAI_CHAI   7051 /* 形容詞-ア段-チャイ-ちゃい */
#define KATA_KEIYOUSHI_ADAN_NAI_IPPAN   7060 /* 形容詞-ア段-ナイ-一般 */
#define KATA_KEIYOUSHI_ADAN_NAI_NAI   7061 /* 形容詞-ア段-ナイ-ない */
#define KATA_KEIYOUSHI_ADAN_BAI_IPPAN   7070 /* 形容詞-ア段-バイ-一般 */
#define KATA_KEIYOUSHI_ADAN_BAI_BAI   7071 /* 形容詞-ア段-バイ-ばい */
#define KATA_KEIYOUSHI_ADAN_PAI_IPPAN   7080 /* 形容詞-ア段-パイ-一般 */
#define KATA_KEIYOUSHI_ADAN_PAI_PAI   7081 /* 形容詞-ア段-パイ-ぱい */
#define KATA_KEIYOUSHI_ADAN_MAI_IPPAN   7090 /* 形容詞-ア段-マイ-一般 */
#define KATA_KEIYOUSHI_ADAN_MAI_MAI   7091 /* 形容詞-ア段-マイ-まい */
#define KATA_KEIYOUSHI_ADAN_YAI_IPPAN   7100 /* 形容詞-ア段-ヤイ-一般 */
#define KATA_KEIYOUSHI_ADAN_YAI_YAI   7101 /* 形容詞-ア段-ヤイ-やい */
#define KATA_KEIYOUSHI_ADAN_RAI_IPPAN   7110 /* 形容詞-ア段-ライ-一般 */
#define KATA_KEIYOUSHI_ADAN_RAI_RAI   7111 /* 形容詞-ア段-ライ-らい */
#define KATA_KEIYOUSHI_ADAN_WAI_IPPAN   7120 /* 形容詞-ア段-ワイ-一般 */
#define KATA_KEIYOUSHI_ADAN_WAI_WAI   7121 /* 形容詞-ア段-ワイ-わい */
#define KATA_KEIYOUSHI_ADAN_KNAI_IPPAN   7120 /* 形容詞-ア段-無イ-一般 */
#define KATA_KEIYOUSHI_ADAN_KNAI_NAI   7121 /* 形容詞-ア段-無イ-ない */
#define KATA_KEIYOUSHI_IDAN_IPPAN   7200 /* 形容詞-イ段-一般 */
#define KATA_KEIYOUSHI_IDAN_YOI   7210 /* 形容詞-イ段-良イ */
#define KATA_KEIYOUSHI_UDAN_UI_IPPAN   7310 /* 形容詞-ウ段-ウイ-一般 */
#define KATA_KEIYOUSHI_UDAN_UI_UI   7311 /* 形容詞-ウ段-ウイ-うい */
#define KATA_KEIYOUSHI_UDAN_KUI_IPPAN   7320 /* 形容詞-ウ段-クイ-一般 */
#define KATA_KEIYOUSHI_UDAN_KUI_KUI   7321 /* 形容詞-ウ段-クイ-くい */
#define KATA_KEIYOUSHI_UDAN_GUI_IPPAN   7330 /* 形容詞-ウ段-グイ-一般 */
#define KATA_KEIYOUSHI_UDAN_GUI_GUI   7331 /* 形容詞-ウ段-グイ-ぐい */
#define KATA_KEIYOUSHI_UDAN_SUI_IPPAN   7340 /* 形容詞-ウ段-スイ-一般 */
#define KATA_KEIYOUSHI_UDAN_SUI_SUI   7341 /* 形容詞-ウ段-スイ-すい */
#define KATA_KEIYOUSHI_UDAN_ZUI_IPPAN   7350 /* 形容詞-ウ段-ズイ-一般 */
#define KATA_KEIYOUSHI_UDAN_ZUI_ZUI   7351 /* 形容詞-ウ段-ズイ-ずい */
#define KATA_KEIYOUSHI_UDAN_TUI_IPPAN   7360 /* 形容詞-ウ段-ツイ-一般 */
#define KATA_KEIYOUSHI_UDAN_TUI_TUI   7361 /* 形容詞-ウ段-ツイ-つい */
#define KATA_KEIYOUSHI_UDAN_BUI_IPPAN   7370 /* 形容詞-ウ段-ブイ-一般 */
#define KATA_KEIYOUSHI_UDAN_BUI_BUI   7371 /* 形容詞-ウ段-ブイ-ぶい */
#define KATA_KEIYOUSHI_UDAN_MUI_IPPAN   7380 /* 形容詞-ウ段-ムイ-一般 */
#define KATA_KEIYOUSHI_UDAN_MUI_MUI   7381 /* 形容詞-ウ段-ムイ-むい */
#define KATA_KEIYOUSHI_UDAN_YUI_IPPAN   7390 /* 形容詞-ウ段-ユイ-一般 */
#define KATA_KEIYOUSHI_UDAN_YUI_YUI   7391 /* 形容詞-ウ段-ユイ-ゆい */
#define KATA_KEIYOUSHI_UDAN_RUI_IPPAN   7400 /* 形容詞-ウ段-ルイ-一般 */
#define KATA_KEIYOUSHI_UDAN_RUI_RUI   7401 /* 形容詞-ウ段-ルイ-るい */
#define KATA_KEIYOUSHI_EDAN   7500 /* 形容詞-エ段 */
#define KATA_KEIYOUSHI_ODAN_OI_IPPAN_IPPAN   7510 /* 形容詞-オ段-オイ-一般-一般 */
#define KATA_KEIYOUSHI_ODAN_OI_IPPAN_ODAN   7511 /* 形容詞-オ段-オイ-一般-オ段 */
#define KATA_KEIYOUSHI_ODAN_OI_IPPAN   7520 /* 形容詞-オ段-オイ-おい-一般 */
#define KATA_KEIYOUSHI_ODAN_OI_ODAN   7521 /* 形容詞-オ段-オイ-おい-オ段 */
#define KATA_KEIYOUSHI_ODAN_KOI_IPPAN   7530 /* 形容詞-オ段-コイ-一般 */
#define KATA_KEIYOUSHI_ODAN_KOI_KOI   7531 /* 形容詞-オ段-コイ-こい */
#define KATA_KEIYOUSHI_ODAN_GOI_IPPAN   7540 /* 形容詞-オ段-ゴイ-一般 */
#define KATA_KEIYOUSHI_ODAN_GOI_GOI   7541 /* 形容詞-オ段-ゴイ-ごい */
#define KATA_KEIYOUSHI_ODAN_SHOI_IPPAN   7550 /* 形容詞-オ段-ショイ-一般 */
#define KATA_KEIYOUSHI_ODAN_SHOI_SHOI   7551 /* 形容詞-オ段-ショイ-しょい */
#define KATA_KEIYOUSHI_ODAN_SOI_IPPAN   7560 /* 形容詞-オ段-ソイ-一般 */
#define KATA_KEIYOUSHI_ODAN_SOI_SOI   7561 /* 形容詞-オ段-ソイ-そい */
#define KATA_KEIYOUSHI_ODAN_ZOI_IPPAN   7570 /* 形容詞-オ段-ゾイ-一般 */
#define KATA_KEIYOUSHI_ODAN_ZOI_ZOI   7571 /* 形容詞-オ段-ゾイ-ぞい */
#define KATA_KEIYOUSHI_ODAN_TOI_IPPAN   7580 /* 形容詞-オ段-トイ-一般 */
#define KATA_KEIYOUSHI_ODAN_TOI_TOI   7581 /* 形容詞-オ段-トイ-とい */
#define KATA_KEIYOUSHI_ODAN_DOI_IPPAN   7590 /* 形容詞-オ段-ドイ-一般 */
#define KATA_KEIYOUSHI_ODAN_DOI_DOI   7591 /* 形容詞-オ段-ドイ-どい */
#define KATA_KEIYOUSHI_ODAN_BOI_IPPAN   7600 /* 形容詞-オ段-ボイ-一般 */
#define KATA_KEIYOUSHI_ODAN_BOI_BOI   7601 /* 形容詞-オ段-ボイ-ぼい */
#define KATA_KEIYOUSHI_ODAN_POI_IPPAN   7610 /* 形容詞-オ段-ポイ-一般 */
#define KATA_KEIYOUSHI_ODAN_POI_POI   7611 /* 形容詞-オ段-ポイ-ぽい */
#define KATA_KEIYOUSHI_ODAN_MOI_IPPAN   7620 /* 形容詞-オ段-モイ-一般 */
#define KATA_KEIYOUSHI_ODAN_MOI_MOI   7621 /* 形容詞-オ段-モイ-もい */
#define KATA_KEIYOUSHI_ODAN_YOI_IPPAN   7630 /* 形容詞-オ段-ヨイ-一般 */
#define KATA_KEIYOUSHI_ODAN_YOI_YOI   7631 /* 形容詞-オ段-ヨイ-よい */
#define KATA_KEIYOUSHI_ODAN_ROI_IPPAN   7640 /* 形容詞-オ段-ロイ-一般 */
#define KATA_KEIYOUSHI_ODAN_ROI_ROI   7641 /* 形容詞-オ段-ロイ-ろい */
#define KATA_KEIYOUSHI_ODAN_KYOI_IPPAN   7650 /* 形容詞-オ段-良イ-一般 */
#define KATA_KEIYOUSHI_ODAN_KYOI_YOI   7651 /* 形容詞-オ段-良イ-よい */
#define KATA_BUNKEIYOUSHI_KU   7910 /* 文語形容詞-ク */
#define KATA_BUNKEIYOUSHI_OOSHI  7910 /* 文語形容詞-多シ */
#define KATA_BUNKEIYOUSHI_SHIKU   7920 /* 文語形容詞-シク */
#define KATA_KEIYOUSHI  7000 /* 形容詞 */
#define KATA_JODOUSHI_JA   8010 /* 助動詞-ジャ */
#define KATA_JODOUSHI_TA   8020 /* 助動詞-タ */
#define KATA_JODOUSHI_TAI   8030 /* 助動詞-タイ */
#define KATA_JODOUSHI_DA   8040 /* 助動詞-ダ */
#define KATA_JODOUSHI_DESU   8050 /* 助動詞-デス */
#define KATA_JODOUSHI_NAI   8060 /* 助動詞-ナイ */
#define KATA_JODOUSHI_NU   8090 /* 助動詞-ヌ */
#define KATA_JODOUSHI_MASU   8100 /* 助動詞-マス */
#define KATA_JODOUSHI_YA   8110 /* 助動詞-ヤ */
#define KATA_JODOUSHI_YASU   8120 /* 助動詞-ヤス */
#define KATA_JODOUSHI_RASHII   8130 /* 助動詞-ラシイ */
#define KATA_BUNGOJODOUSHI_KI   9010 /* 文語助動詞-キ */
#define KATA_BUNGOJODOUSHI_KEMU   9020 /* 文語助動詞-ケム */
#define KATA_BUNGOJODOUSHI_KERI   9030 /* 文語助動詞-ケリ */
#define KATA_BUNGOJODOUSHI_GOTOSHI   9040 /* 文語助動詞-ゴトシ */
#define KATA_BUNGOJODOUSHI_ZAMASU   9050 /* 文語助動詞-ザマス */
#define KATA_BUNGOJODOUSHI_ZU   9060 /* 文語助動詞-ズ */
#define KATA_BUNGOJODOUSHI_TARI   9070 /* 文語助動詞-タリ */
#define KATA_BUNGOJODOUSHI_TU   9080 /* 文語助動詞-ツ */
#define KATA_BUNGOJODOUSHI_NARI   9090 /* 文語助動詞-ナリ */
#define KATA_BUNGOJODOUSHI_NU   9100 /* 文語助動詞-ヌ */
#define KATA_BUNGOJODOUSHI_BESHI   9110 /* 文語助動詞-ベシ */
#define KATA_BUNGOJODOUSHI_MAJI   9120 /* 文語助動詞-マジ */
#define KATA_BUNGOJODOUSHI_MU   9130 /* 文語助動詞-ム */
#define KATA_BUNGOJODOUSHI_RASHI   9140 /* 文語助動詞-ラシ */
#define KATA_BUNGOJODOUSHI_RAMU   9150 /* 文語助動詞-ラム */
#define KATA_BUNGOJODOUSHI_RI   9160 /* 文語助動詞-リ */
#define KATA_BUNGOJODOUSHI_NSU   9170 /* 文語助動詞-ンス */
#define KATA_MUHENKAGATA   9900 /* 無変化型 */


/* 活用形のID */

#define KEI_GOKAN_IPPAN           110  /* 語幹-一般 */
#define KEI_GOKAN_SA              120  /* 語幹-サ */
#define KEI_MIZEN_IPPAN           210  /* 未然形-一般 */
#define KEI_MIZEN_IPPAN_HE        211  /* 未然形-一般:ヘ */
#define KEI_MIZEN_HATSUON         220  /* 未然形-撥音便 */
#define KEI_MIZEN_ZU              230  /* 未然形-ズ接続 */
#define KEI_MIZEN_SERU            240  /* 未然形-セル接続 */
#define KEI_MIZEN_HOJO            250  /* 未然形-補助 */
#define KEI_ISHISUIRYOU_IPPAN     310  /* 意志推量形-一般 */
#define KEI_ISHISUIRYOU_IPPAN_TAN 311  /* 意志推量形-一般:短縮 */
#define KEI_ISHISUIRYOU_SOKUON    320  /* 意志推量形-促音便 */
#define KEI_ISHISUIRYOU           310  /* 意志推量形 */
#define KEI_RENYOU_IPPAN          410  /* 連用形-一般 */
#define KEI_RENYOU_IPPAN_SHI      411  /* 連用形-一般:シ */
#define KEI_RENYOU_IONBIN         420  /* 連用形-イ音便 */
#define KEI_RENYOU_UONBIN         430  /* 連用形-ウ音便 */
#define KEI_RENYOU_SOKUONBIN      440  /* 連用形-促音便 */
#define KEI_RENYOU_SOKUONBIN_SU   441  /* 連用形-促音便:スッ */
#define KEI_RENYOU_HATSUONBIN     450  /* 連用形-撥音便 */
#define KEI_RENYOU_YUUGOU         460  /* 連用形-融合 */
#define KEI_RENYOU_YUUGOU_CHA     461  /* 連用形-融合:チャ */
#define KEI_RENYOU_HOJO           470  /* 連用形-補助 */
#define KEI_RENYOU_TO             480  /* 連用形-ト */
#define KEI_RENYOU_NI             490  /* 連用形-ニ */
#define KEI_KIHON_IPPAN           510  /* 基本形-一般 */
#define KEI_KIHON_IPPAN_CHA       511  /* 基本形-一般:チャ */
#define KEI_KIHON_UONBIN          520  /* 基本形-ウ音便 */
#define KEI_KIHON_SOKUONBIN       530  /* 基本形-促音便 */
#define KEI_KIHON_HATSUONBIN      540  /* 基本形-撥音便 */
#define KEI_KIHON_E               550  /* 基本形-エ */
#define KEI_RENTAI_IPPAN          560  /* 連体形-一般 */
#define KEI_RENTAI_IPPAN_TAN      561  /* 連体形-一般:短縮 */
#define KEI_RENTAI_SHOURYAKU      570  /* 連体形-省略 */
#define KEI_RENTAI_HOJO           580  /* 連体形-補助 */
#define KEI_RENTAI_E_TAN          590  /* 連体形-エ:短縮 */
#define KEI_KATEI_IPPAN           610  /* 仮定形-一般 */
#define KEI_KATEI_YUUGOU          620  /* 仮定形-融合 */
#define KEI_KATEI_YUUGOU_KYA      621  /* 仮定形-融合:キャ */
#define KEI_IZEN_IPPAN            710  /* 已然形-一般 */
#define KEI_IZEN_HOJO             720  /* 已然形-補助 */
#define KEI_IZEN                  710  /* 已然形 */
#define KEI_MEIREI_IPPAN          810  /* 命令形-一般 */
#define KEI_MEIREI_I              820  /* 命令形-イ */
#define KEI_MEIREI_KO             830  /* 命令形-コ */
#define KEI_MEIREI_SHI            840  /* 命令形-シ */
#define KEI_MEIREI_RO             850  /* 命令形-ロ */
#define KEI_MEIREI                810  /* 命令形 */

#ifdef WIN32
#include "pos_sjis.h"
#else
#include "pos_eucjp.h"
#endif
