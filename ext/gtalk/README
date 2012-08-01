
GalateaTalk: Speech synthesis module for Galatea
                                                               2008.7.31
------------------------------------------------------------------------

GalateaTalk は Galetea システムの音声合成モジュール (SSM) として動作します。

=============
1. コンパイル
=============

音声合成システムのソースパッケージを適当なディレクトリにコピーし、
    tar zxfv gtalk-080731.tar.gz
    cd gtalk-080731
    ./configure
    make
でコンパイルし、合成モジュールの実行プログラム gtalk を作成する。
readline ライブラリがインストールされている環境では、コマンド入力に
おいてライン編集が可能になる。

Linux あるいは Solaris (on SPARC) で実行が確認されている。

サウンドの設定のしてあるマシンの場合、合成音声の出力ができるように
自動設定される。

===================
2. 実行に必要なもの
===================

2.1 gtalk
  1. で作成した音声合成プログラム

2.2 形態素解析プログラム chasen 関連

2.2.1 形態素解析プログラム chasen [CHASEN]
  音声合成プログラムが内部でテキスト解析を行なうために、形態素解析
システム chasen を内部で呼び出して用いている。chasen-2.3.3 以上が
必要である。さらに辞書データとして unidic-1.3.0 以上が必要である。
  [ ] 内は、設定ファイル中での変数名で、以下同様。

2.2.2 chasen のライブラリ [CHASEN-DLL] (Windows版のみ有効)
　chasen のライブラリ libchasen.dll へのパスを指定する。

2.2.3 chasenrc [CHASEN-RC]
  chasen の設定ファイル

2.3 複合語・音韻交替処理プログラム chaone　関連

2.3.1 ChaOne [CHAONE]
  複合語・音韻交替処理プログラム chaone のパスを指定する。
　アクセント句の生成を行う chaone-1.3.2 以上の ChaOne が必要である。

2.3.2 XML ファイルへのパス [CHAONE-XSL-FILE] (chaone組み込み版のみ有効)
　chaone が用いる XML ファイルを指定する。

2.4 音素モデルのリスト [PHONEME-LIST]
  合成部で使う音素セットのリスト
  mono.lst が用意されている。

2.5 話者モデル
  合成を行うための話者モデルは、１話者あたり
    話者のIDコード [SPEAKER-ID]
    話者の性別     [GENDER]
    時間長の決定木 [DUR-TREE-FILE]
    ピッチの決定木 [PIT-TREE-FILE]
    メルケプストラムの決定木 [MCEP-TREE-FILE]
    時間長の分布ファイル [DUR-MODEL-FILE]
    ピッチの分布ファイル [PIT-MODEL-FILE]
    メルケプストラムの分布ファイル [MCEP-MODEL-FILE]
の８つの情報を与える必要がある。
4. で述べる設定ファイル中で、話者モデルのパスを指定する。

2.6 設定ファイル
  これらのデータファイルは、gtalk の設定ファイル中で記述し、
    gtalk -C 設定ファイル
のようにプログラムを起動する。

==========================
3. ChaOne のインストール
==========================

　ChaOne 本体の変換ロジックはすべて XSLT で書かれている。このため、
ChaOne in C のコンパイル及び実行には、Gnome プロジェクトで開発された
XSLT Cライブラリである libxslt が必要である。
　最近の Linux ディストリビューションには、はじめから含まれていること
が多い。
　xsltlib の配布元は、http://xmlsoft.org/XSLT/ である。
　具体的なインストール手順は ChaOne のパッケージを参照のこと。

==========================
4. 設定ファイル
==========================

  設定ファイルの例として、ssm.conf が与えられており、

    ----------
    # configuratiuon file for gtalk (GalateaTalk)

    # path name of 'chasen'
    CHASEN: /usr/local/bin/chasen

    # path name of 'libchasen.dll' (only for Windows)
    CHASEN-DLL:  ../chasen-2.4.1/lib/libchasen.dll

    # configuration file for 'chasen'
    CHASEN-RC: ./chasenrc

    # command of running 'chaone'
    CHAONE: ../morph/chaone-1.3.2/chaone

    # path name of 'chaone.xsl' (only for Windows)
	CHAONE-XSL-FILE: ../chaone-win-1.3.2/chaone4gtalk_win.xsl

    # default for numbers and alphabets
    NUMBER: DECIMAL
    ALPHABET: WORD
    DATE: YMD
    TIME: hms

    # dictionary
    DICTIONARY: ./gtalk-eucjp.dic

    # automatic play of synthesized speech
    AUTO-PLAY: NO
 
    # time delay [msec] for autuomatic play
    AUTO-PLAY-DELAY: 250

    # file of phoneme list
    PHONEME-LIST: mono.lst

    # parameter files for each speaker
    SPEAKER-ID: male01
    GENDER: male
    DUR-TREE-FILE:   ../speakers/male01/tree-dur.inf
    PIT-TREE-FILE:   ../speakers/male01/tree-lf0.inf
    MCEP-TREE-FILE:  ../speakers/male01/tree-mcep.inf
    DUR-MODEL-FILE:  ../speakers/male01/duration.pdf
    PIT-MODEL-FILE:  ../speakers/male01/lf0.pdf
    MCEP-MODEL-FILE: ../speakers/male01/mcep.pdf

    (以下、省略)
    ----------

のように、
    変数名: 値
の形式で記述する。 : の前後のスペースは読み飛ばされる。
また、行頭が # の行および空行はコメント行として扱われる。

4.1 読み指定
4.1.1 数字の読み方 [NUMBER]
  アラビア数字連続を位取りして読む(DECIMAL)か否(NO)か
4.1.2 英字の読み方 [ALPHABET]
  英字連続を英単語として読む(WORD)か否(NO)か
4.1.3 日付の読み方 [DATE]
  ISO 8601に基づく日付表記を読む(YMD)か否(NO)か
4.1.4 時刻の読み方 [TIME]
  ISO 8601に基づく時刻表記を読む(hms)か否(NO)か

4.2 辞書
  GalateaTalk で利用する辞書ファイルを変数 DICTIONARY で指定する。
辞書は，
----------
南草津 ミナミクサツ 4
GalateaTalk ガラテアトーク 5
----------
のように
    単語 読み アクセント型
をスペースで区切って１行に１エントリを行頭から記述する。
辞書ファイルの漢字コードは UNIX 版では EUC，Windows では SJIS とすること。
  GalateaTalkでの辞書は，入力テキストに対する PRON タグへの文字列置換として
実装されている (後述の 4.4 節を参照のこと)。 例えば，入力テキストに
「南草津」があると，それが「<PRON SYM=\"ミナミク’サツ\">南草津</PRON>」に
置換される。この文字列置換では，単語境界は考慮されないことに注意のこと。
辞書の中に競合する複数のエントリがある場合には，先に記述されたエントリが
優先される。

4.3 話者モデル
  複数の話者データを利用する場合には、SPEAKER-ID の記述に
続いて、その話者のデータを列挙する。GENDER、*-TREE-FILE、
*.MODEL-FILE の記述は、直前の SPEAKER-ID の話者に対する
記述であると解釈される。
また、SPEAKER-ID に対しては、任意の文字列が利用できる。
GENDER に対しては、male あるいは female を指定する。

4.4 自動音声出力
　音声出力すべき文を入力した後，音声波形を合成しながら同時に自動的に
音声出力が始まるようにするには，変数 AUTO-PLAY を YES にしておく。
この時，音声波形が合成され始めてから，音声の自動出力が開始されるまでの
時間遅れを変数 AUTO-PLAY-DELAY で指定する。適切な AUTO-PLAY-DELAY の値は，
処理系の演算速度，動作時の負荷，文の長さに依存する。

4.5 デフォールトの設定
　gtalk の実行時に設定ファイルが指定されない場合には、
デフォールトとして、
    ----------
    CHASEN: /usr/local/bin/chasen
    CHASEN-RC: chasenrc
    CHAONE: chaone
    NUMBER: DECIMAL
    ALPHABET: WORD
    DATE: YMD
    TIME: hms
    PHONEME-LIST: mono.lst
    AUTO-PLAY: NO
    AUTO-PLAY-DELAY: 250
    SPEAKER-ID: male01
    GENDER: male
    DUR-TREE-FILE:   tree-dur.inf
    PIT-TREE-FILE:   tree-lf0.inf
    MCEP-TREE-FILE:  tree-mcep.inf
    DUR-MODEL-FILE:  duration.pdf
    PIT-MODEL-FILE:  lf0.pdf
    MCEP-MODEL-FILE: mcep.pdf
    ----------
が設定される。

===========
5. 発話記述
===========

発話内容は、
    set Text = 音声合成の研究者は、何人くらいいますか。
のように、漢字仮名混じり文で与える。
文中でJEIDA-62-2000に基づいたタグを記述することにより、韻律の変更などができる。

5.1 SILENCE タグ
  ポーズを挿入する。

MSEC 属性
  msec単位で長さを指定してポーズを挿入する。
  例)
    set Text = 東京<SILENCE MSEC="400"/>じゃなくて京都です。
  とすることにより、「東京」の後に400msのポーズが挿入される。
  指定した値が 0 より小さいときには、0ms のポーズが挿入される。
  また、
    set Text = 東京<SILENCE/>じゃなくて京都です。
  のようにポーズ長を指定しない場合には、システムが適当な長さのポーズを
  挿入する。

その他の属性は無視される。

5.2 EMPH タグ
  韻律的な強調を行う。
  指定すべき属性はない。

  例)
    set Text = 私が欲しいのは、お金ではなく<EMPH>時間</EMPH>です。
  とすることにより、「時間」が強調されて発話される。

5.3 SPELL タグ
  数字や英字などの綴り読みを指定する。
  指定すべき属性はない。

  例)
    set Text = ＳＭＡＲＴのつづりは<SPELL>ＳＭＡＲＴ</SPELL>です。
  とすることにより、
    「スマートのつづりはエスエムエーアールティーです」
  と読み上げる。

    set Text = これは<SPELL>1234</SPELL>です。
  とすることにより、
    「これは一二三四です」
  と読み上げる。

5.4 PRON タグ
  発音を指定する。

SYM 属性
  カナ表記によって、読みとアクセント型を指定する。
  例)
    set Text = 最寄り駅は<PRON SYM="ミナミク’サツ">南草津</PRON>です。
  とすることにより、「南草津」が「ク」にアクセント核をおき、「ミナミクサツ」
  と読まれる。

POS 属性
  PRONタグでマークした語の品詞を指定する。
  例)
    set Text = 最寄り駅は<PRON SYM="ミナミク’サツ"
                   POS="名詞-固有名詞-地名-一般">南草津</PRON>です。
  のように品詞を指定する。
  品詞の分類は unidic での分類にしたがっており、pos.h で一覧できる。

その他の属性は無視される。

5.5 SPEECH タグ
  タグのスコープを指定する。
  指定すべき属性はない。

5.6 VOICE タグ
  話者を指定する。

OPTIONAL 属性
  話者を指定して発話する。
  例)
    set Text = 彼女は、<VOICE OPTIONAL="female01">はい。</VOICE>と言った。
  とすることにより、「はい。」だけが female01 の声で発話され、それ以外の
  「彼女は、」「と言った。」は、その時の Speaker スロットで指定されている
  話者の声で発話される。

その他の属性は無視される。

5.7 RATE タグ
  発話速度を指定する。

SPEED 属性
  通常の発声に対する相対的時間長を指定する。
  例)
    set Text = 私は<RATE SPEED="2.0">東京</RATE>へ行きます。
  とすることにより、「東京」が2.0倍の時間長で(ゆっくりと)発話される。
  指定した値が 0.2 より小さいときには、0.2 倍として処理される。

その他の属性は無視される。

5.8 VOLUME タグ
  音量を指定する。

LEVEL 属性
  通常の発声に対する音量を相対的に指定する。
  例)
    set Text = 私は<VOLUME LEVEL="2">東京</VOLUME>へ行きます。
  とすることにより、「東京」が1.5倍の音量で(大きい声で)発話される。
  指定した値が 0.01 より小さいときには、0.01 倍として処理される。

その他の属性は無視される。

5.9 PITCH タグ
  基本周波数を指定する。

LEVEL 属性
  通常の発声に対するピッチを相対的に指定する。
  例)
    set Text = 私は<PITCH LEVEL="1.5">東京</PITCH>へ行きます。
  とすることにより、「東京」が1.5倍のピッチで(高い声で)発話される。
  指定した値が 0.1 より小さいときには、0.1 倍として処理される。

RANGE 属性 (JEIDA-62-2000 からの拡張)
  通常の発声に対するピッチの振れ幅を相対的に指定する。
  例)
    set Text = 私は<PITCH RANGE="1.5">東京</PITCH>へ行きます。
  とすることにより、「東京」がその平均ピッチを維持したまま振れ幅を1.5倍にして
  発話される。
  指定した値が 0 より小さいときには、0 倍として処理される。

その他の属性は無視される。

5.10 CONTEXT タグ  (JEIDA規格の一部を実装、一部拡張)
  データ内容に関する情報を指定する。
  数字および一部の記号を対象として、読み上げ型を TYPE 属性で指定する。
  TYPE属性の指定がない場合は、タグは無視される。

TYPE 属性
  値として、NUMBER, DIGITS, DATE, TIME, PHONE のいずれかを指定する。
  (NUMBER, DIGITS は JEIDA-62-2000 からの拡張である。)
  これ以外の値を TYPE 属性に指定した場合にはタグ全体が無視される。

  例)
    set Text = 人数は<CONTEXT TYPE="NUMBER">1234</CONTEXT>です。
  とすることにより、
    「人数は千二百三十四です」
  と読み上げる。
  デフォルトでは小数点は'.'、位取り区切り記号は','を用いる。
  よって
    <CONTEXT TYPE="NUMBER">1,234.5</CONTEXT>
  は「千二百三十四点五」と読まれる。FORMAT属性にISOを指定することで
    <CONTEXT TYPE="NUMBER" FORMAT="ISO">1 234,5</CONTEXT>
  のように、小数点に','、位取り区切り記号に' 'を用いることができる。

    set Text = これは<CONTEXT TYPE="DIGITS">1234</CONTEXT>です。
  とすることにより、
    「これは一二三四です」
  と読み上げる。

    set Text = 今日は<CONTEXT TYPE="DATE">2003-8-3</CONTEXT>です。
  とすることにより、
    「今日は二千三年八月三日です」
  と読み上げる。
  デフォルトの日時の表記法にはISO 8601を採用している。
  FORMAT属性に"MDY"、DELIM属性に"/"と書くことにより
    <CONTEXT TYPE="DATE" FORMAT="MDY" DELIM="/">8/3/2003</CONTEXT>
  を二千三年八月三日と読み上げることができる。

    set Text = 時刻は<CONTEXT TYPE="TIME">12:34</CONTEXT>です。
  とすることにより、
    「時刻は十二時三十四分です」
  と読み上げる。
    set Text = 時刻は<CONTEXT TYPE="TIME">12:34:56</CONTEXT>です。
  とすることにより、
    「時刻は十二時三十四分五十六秒です」
  と読み上げる。
  
    set Text = 電話番号は<CONTEXT TYPE="PHONE">0120-123-4567</CONTEXT>です。
  とすることにより、
    「電話番号は〇一二〇、一二三、四五六七です」
  と読み上げる。

(参考)
  CONTEXTタグを用いない場合の数字、英字のデフォルトの読み上げ方は以下の
  とおりである。

  数字はNUMBER (位取りして読み上げ)、英字は辞書にあればその読みで、
  なければALPHABETとして読み上げられる。
  ただし、設定ファイルの既述によりこれをかえることができる。

5.11 APB タグ 
  アクセント句境界を明示的に指定する。(このタグは，JEIDA規格にはない，
独自に追加したタグである。)

  例)
    set Text = 草津<APB/>太郎
  とすることにより、「草津」と「太郎」の間に強制的にアクセント句境界が
  置かれる。


=========
6. 実行例
=========

話者の選択は
    set Speaker = male01
のように話者 ID を設定して行なう。
指定しなければ、デフォールトの話者として "male01" が使われる。
発話内容の記述では、
    set Text = 音声合成の研究者は、何人くらいいますか
により、合成音を生成し、
    set Speak = NOW
とすると合成音声を出力する(-DLINUXでコンパイルした場合)。

最後に合成した合成音声波形を
    set SaveRAW = <filename>
    (あるいは set Save = <filename> )
で <filename> に出力することができる。
ファイル形式は 16kHz, 16bit, signed linear raw file, Big Endian である。
同時に、音素時間長などの情報が <filename>.info のファイルに
書き出される。
このようにファイルにセーブした合成音声波形は
    set LoadRAW = <filename>
    (あるいは set SpeechFile = <filename>)
によってデータが読み込まれ、
    set Speak = NOW
などによって合成音声が出力される。

また，最後に合成した合成音声波形を
    set SaveWAV = <filename>
で <filename> に WAV 形式で出力することができる。
ファイル形式は 16kHz, 16bit である。
同時に、音素時間長などの情報が <filename>.info のファイルに
書き出される。
このようにファイルにセーブした合成音声波形は
    set LoadWAV = <filename>
によってデータが読み込まれ、
    set Speak = NOW
などによって合成音声が出力される。

最後に合成した合成音声の韻律情報を
    set SavePros = <filename>
で <filename> に出力することができる。
出力ファイルはテキストファイルで、

    input_text: 最寄り駅は<EMPH>京都</EMPH>です。
    spoken_text: 最寄り駅は京都です。
    number_of_phonemes: 23
    total_duration: 2075
    -----
    sil [10]
    m [60]
    ...
    pau [315]
    sil [10]
    -----
    total_frame: 546
    -----
    0: 0.000000 1.015440
    1: 0.000000 1.268129
    ...
    545: 0.000000 0.000000
    546: 0.000000 0.000000
    -----

のように

    input_text: <入力テキスト>
    spoken_text: <発話されるテキスト>
    number_of_phonemes: <音素数>
    total_duration: <発話長[ms]>
    -----
    <音素名> [<時間長[ms]>]
    ...
    -----
    total_frame: <フレーム数>
    -----
    <フレーム番号>: <F0の対数値> <パワー値>
    ...
    -----

となっている。
このようにファイルにセーブした韻律情報は
    set LoadFile = <filename>
    ( あるいは set ProsFile = <filename> )
によってデータが読み込まれ、音声波形が生成され
    set Speak = NOW
などによって合成音声が出力される。
韻律情報ファイルの音素系列およびその時間長は
(現在は)変更できないが、F0およびパワーの値は変更可能である。

また、
    set ParsedText = data/sentence1.data
    set ParsedText = data/sentence2.data
など、手で作成した茶筌の解析結果を読み込んで音声を合成することが
できる。

合成音声の出力では、
    set Speak = 12:34:56.000
で発話開始時刻を指定しての出力、また、
    set Speak = +1000
で発話開始を msec 単位で遅らせての出力ができる。

合成音声出力中に
    set Speak = STOP
を与えると、音声出力が途中で停止し、途中停止するまでに音声出力された
音素列が出力される。

    set Run = EXIT
とするとこによって、GalateaTalk は終了する。

===========
7. スロット
===========

  GalateaTalk は内部にいくつかのスロットを持ち、そこに外部から値をセット
したり、内部の処理で値を決定したりして処理を進める。定義されている
スロットは、以下の通りである。

    Run : 動作状態 ( 起動時に LIVE に設定され、EXIT をセットすれば終了する)
    ProtocolVersion : 通信プロトコルのバージョン
    ModuleVersion : プログラムのバージョン
    SpeakerSet : 利用可能な話者ID
    Speaker : 現在の話者ID
    Text.text : 発話内容 ( 4. で述べた set Text = ... でセットされる)
    Text.pho : 音素系列と音素時間長
    Text.dur : 総発話時間
    Speak.text : 合成された発話テキスト
    Speak.pho : 音素系列と音素時間長 (Text.pho と同じ)
    Speak.dur : 総発話時間 (Text.dur と同じ)
    Speak.utt : 既に発声した音素系列
    Speak.len : 既に発声した総時間長
    Speak.stat : 合成プログラムの状態 ( IDLE, READY, PROCESSING, SPEAKING )
    AutoPlay : 自動音声出力の有無
    AutoPlayDelay : 自動音声出力における時間遅れ

これらのスロットの値を知るには、
    inq Text.text
のように inq コマンドを用いる。

  さらに、スロットの値が新たにセットされた場合に、セットされた値を自動的に
出力するかどうかをスロットのプロパティによって制御できる。
各スロットは、プロパティとして AutoOutput か NoAutoOutput のどちらかの
値をとり、それぞれ自動出力する、自動出力しないを表す。
プロパティの値を変更するには、
    prop Text.text = NoAutoOutput
    prop Text.text = AutoOutput
のように prop コマンドによって行なう。
初期値としては、全て AutoOutput が設定されている。

===================
8. 内部データの出力
===================

    set Log = ファイル名
のように、Log スロットにファイル名を与えることにより、
選択されている内部データ (形態素やアクセント句など) を
ファイルに書き出すことができる。指定したファイルがすでに
存在する場合には、ファイルの末尾に追加される。
    set Log = CONSOLE
とした時には、標準エラー (stderr) に出力され、
    set Log = NO
とすれば、出力を中止する。
Log スロットの初期値は NO となっており、内部データの出力は行なわれない。
書き出す内部データは、
    Log.conf (ssm.conf による設定)
    Log.text (入力テキスト)
    Log.arrangedText (整形された入力テキスト)
    Log.chasen (茶筌の解析結果)
    Log.tag (タグの一覧(CONTEXT,SPELLタグ以外))
    Log.phoneme (音素情報)
    Log.mora (モーラ情報)
    Log.morph (形態素情報)
    Log.aphrase (アクセント句情報)
    Log.breath (呼気段落情報)
    Log.sentence (文情報)
の各スロットに対し、
    set Log.chasen = YES
のように YES の値をセットすることにより、選択する。
( ) が出力される情報を示している。
初期値では全ての Log.* のスロットは NO となっている。

===============
9. エラーの出力
===============

    set Err = ファイル名
のように、Err スロットにファイル名を与えることにより、
実行時のエラー出力をファイルへ出力することができる。
    set Err = CONSOLE
とした時には、標準エラー出力 (stderr) に出力される。
Err スロットの初期値は CONSOLE となっている。

=================
10. 実行スクリプト
=================

gtalk で音声を出力する perl の実行スクリプトが
    RUN
として用意されている。

==========
11. ソース
==========

    --------------- 合成プログラム
    main.c:               メインプログラム
    read_conf.c          設定ファイルの読み込み
    ---テキスト解析部
    text.c:              テキスト解析結果の読み込み
    tag.c:               発話内容記述タグの解析
    accent.c:            アクセント処理
    chasen.c:            茶筌プロセス
    make_sentence.c:     SENTENCE 構造体作成
    make_breath.c:       BREATH 構造体作成
    make_aphrase.c:      APHRASE 構造体作成
    make_phoneme.c:      PHONEME 構造体作成
    morph.c:             MORPH 構造体作成
    make_mora.c:         MORA 構造体作成
    kannjiyomi.c:        単漢字の読み付与
    send.c:              統合部への情報の転送
    sleep.c:             遅延処理
    fileIO.c:            ファイル入出力
    util.c:              その他
    ---音声合成部
    make_duration.c:     音素継続長の決定
    make_parameter.c:    パラメータ生成
    modify_parameter.c:  タグの指定に基づく韻律の修正
    do_synthesis.c:      波形生成
    do_output.c:         出力(LINUXでは、DA変換)
    hmmsynth.c:          refresh(),init(),コンテキストラベル生成
    mlpg.c:              HMMからのパラメータ生成
    model.c:             音素HMMの構造体
    tree.c:              決定木探索
    vocoder.c:           メルケプストラムボコーダ
    misc.c:              その他

    synthesis.h:         構造体定義、グローバル変数
    confpara.h:          データファイルのパス、話者情報など
    command.h:           コマンド定義
    tag.h:               発話内容記述のタグ情報
    slot.h:              スロット定義
    pronunciation.h:     発音辞書
    accent.h:            品詞、アクセント変形の定義
    kannjiyomi.h         単漢字の読み情報

    hmmsynth.h:          header for hmmsynth.c グローバル変数  
    vocoder.h:           header for vocoder.c  関数プロトタイプ宣言など
    tree.h:              header for tree.c     決定木構造体 Tree
    model.h:             header for model.c    モデル構造体 Model
    mlpg.h:              header for mlpg.c     パラメータ生成構造体 PStream
    misc.h:              header for misc.c    関数プロトタイプ宣言など
    da.h:                header for do_output.c:音声出力の定義
    defaults.h:          HMM合成のデフォルトパラメータの設定

    --------------- モデルファイル等
    ssm.conf:            設定ファイル
    mono.lst:            音素リスト
    chasenrc:            茶筌出力フォーマット定義
    data/sentence1.data: サンプル茶筌結果1
    data/sentence2.data: サンプル茶筌結果2
    data/sentence3.data: サンプル茶筌結果3
    data/sentence4.data: サンプル茶筌結果4
    --------------- その他
    README:              このファイル
    Changelog:           開発履歴
    License:             ライセンス

==============
12. 音素モデル
==============

    duration.pdf:        継続長の分布
    mcep.pdf:            メルケプストラムの分布
    lf0.pdf:             基本周波数の分布
    tree-mcep.inf:       メルケプストラムに対する決定木
    tree-dur.inf:        継続長に対する決定木
    tree-lf0.inf:        基本周波数に対する決定木
