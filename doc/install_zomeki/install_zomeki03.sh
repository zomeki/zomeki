#!/bin/bash
cd /var/share/zomeki/
echo "
# ======================================================================
#  7.3 VirtualHost の反映
# ======================================================================
# 
# Apacheに設定を追加します。
#   $ su -
#   # ln -s /var/share/zomeki/config/virtual-hosts/zomeki.conf \
#   > /etc/httpd/conf.d/
# 
# Apache を再起動します。
#   # /sbin/service httpd configtest
#   # /sbin/service httpd restart
# 
# ここまでの手順で ZOMEKI にアクセスすることができます。
# 
#   公開画面 : http://zomeki.example.com/
# 
#   管理画面 : http://zomeki.example.com/_system
# 
# 次のユーザが登録されています。
# 
#     管理者（システム管理者）
#       ユーザID   : zomeki
#       パスワード : zomeki
"
echo whoami
whoami

echo "press Enter"
read Enter

ln -s /var/share/zomeki/config/virtual-hosts/zomeki.conf \
/etc/httpd/conf.d/
/sbin/service httpd configtest
/sbin/service httpd restart

echo "press Enter"
read Enter


echo "
# **********************************************************************
#  8 ZOMEKI のインストール (ふりがな・読み上げ機能)
# **********************************************************************
# 
# LAMEをインストールします。
# 
#   # cd /usr/local/src
#   # tar xvzf lame-3.99.1.tar.gz
#   # cd lame-3.99.1
#   # ./configure --prefix=/usr
#   # make && make install
"
cd /usr/local/src
tar xvzf lame-3.99.1.tar.gz
cd lame-3.99.1
./configure --prefix=/usr
make && make install

echo "press Enter"
read Enter


echo "
# Dartsをインストールします。
# 
#   # cd /usr/local/src
#   # tar xvzf darts-0.32.tar.gz
#   # cd darts-0.32
#   # ./configure --prefix=/usr
#   # make && make install
"
cd /usr/local/src
tar xvzf darts-0.32.tar.gz
cd darts-0.32
./configure --prefix=/usr
make && make install

echo "press Enter"
read Enter


echo "
# ChaSenをインストールします。
# 
#   # cd /usr/local/src
#   # tar xvzf chasen-2.4.4.tar.gz
#   # cd chasen-2.4.4
#   # ./configure --prefix=/usr
#   # make && make install
"
cd /usr/local/src
tar xvzf chasen-2.4.4.tar.gz
cd chasen-2.4.4
./configure --prefix=/usr
make && make install

echo "press Enter"
read Enter


echo "
# IPAdicをインストールします。
# 
#   # cd /usr/local/src
#   # tar xvzf ipadic-2.7.0.tar.gz
#   # cd ipadic-2.7.0
#   # ./configure --prefix=/usr
"
cd /usr/local/src
tar xvzf ipadic-2.7.0.tar.gz
cd ipadic-2.7.0
./configure --prefix=/usr

echo "press Enter"
read Enter


echo "
#   辞書をUTF8に変換します。
# 
#   # vi to_utf8.sh    #新規作成
#   - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   #!/bin/sh
#   for file in *.dic *.cha chasenrc
#   do
#   if [ -f $file ]; then
#       nkf --utf8 $file > tmpfile
#       mv tmpfile $file
#   fi
#   done
#   exit
#   - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 
#   # chmod 744 to_utf8.sh
#   # ./to_utf8.sh
#   # ldconfig
#   # `chasen-config --mkchadic`/makemat -i w
#   # `chasen-config --mkchadic`/makeda -i w chadic *.dic
#   # make install
"

cp /var/share/zomeki/doc/install_zomeki/to_utf8.sh /usr/local/src/ipadic-2.7.0/
chmod 744 to_utf8.sh
./to_utf8.sh
ldconfig
`chasen-config --mkchadic`/makemat -i w
`chasen-config --mkchadic`/makeda -i w chadic *.dic
make install

echo "press Enter"
read Enter


echo "
# ChaOneをインストールします。
# 
#   # cd /var/share/zomeki/ext/morph/chaone
#   # chmod 775 configure
#   # ./configure
#   # make && make install
"
cd /var/share/zomeki/ext/morph/chaone
chmod 775 configure
./configure
make && make install

echo "press Enter"
read Enter


echo "
# GalateaTalkをインストールします。
# 
#   # cd /var/share/zomeki/ext/gtalk
#   # chmod 775 configure
#   # ./configure
#   # make
#   # chmod 747 /var/share/zomeki/ext/gtalk_filter.rb
"
cd /var/share/zomeki/ext/gtalk
chmod 775 configure
./configure
make
chmod 747 /var/share/zomeki/ext/gtalk_filter.rb

echo "press Enter"
read Enter


echo "
# **********************************************************************
#  9 定期実行設定
# **********************************************************************
# 
#   # su - zomeki
#   $ crontab -e
#   - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   # 記事の公開/非公開処理を行います。
#   10,25,40,55 * * * * /usr/local/bin/ruby /var/share/zomeki/script/rails runner -e production \"Script.run('sys/script/tasks/exec')\"
# 
#   # トップページや中間ページを静的ファイルとして書き出します。
#   */15 * * * * /usr/local/bin/ruby /var/share/zomeki/script/rails runner -e production \"Script.run('cms/script/nodes/publish')\"
# 
#   # 音声ファイルを静的ファイルとして書き出します。
#   */15 * * * * /usr/local/bin/ruby /var/share/zomeki/script/rails runner -e production \"Script.run('cms/script/talk_tasks/exec')\"
# 
#   # 新着記事ポータルで設定したAtomフィードを取り込みます。
#   0 * * * * /usr/local/bin/ruby /var/share/zomeki/script/rails runner -e production \"Script.run('cms/script/feeds/read')\"
#   - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 
# **********************************************************************
"


echo "これでインストール作業は全て終了です。
crontabの設定は上記を参考に別途行なって下さい。"
echo "press Enter"
read Enter

