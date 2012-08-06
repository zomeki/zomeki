#!/bin/bash
echo "
# ## ZOMEKI v1.0.1    インストールマニュアル                  2012-08-06
# 
# **********************************************************************
#  1 想定環境
# **********************************************************************
# 
# [システム]
# OS         : CentOS 6.3
# Webサーバ  : Apache 2.2
# DBシステム : MySQL 5.1
# Ruby       : 1.9.3
# Rails      : 3.1.6
# 
# [設定]
# ドメイン   : zomeki.example.com
# 
# **********************************************************************
#  2 CentOS のインストール
# **********************************************************************
# 
# CentOSをインストールします。
# 
# rootユーザに変更します。
# 
#   $ su -
# 
# ======================================================================
#  2.1 SELinux の無効化
# ======================================================================
"
# 
echo " SELinuxを無効にします。"
# 
echo "/usr/sbin/setenforce 0"
/usr/sbin/setenforce 0

echo "press Enter"
read Enter

echo " 自動起動を無効にします。"

echo "press Enter"
read Enter

# 
echo " vim /etc/sysconfig/selinux"
echo "
#   - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   SELINUX=disabled    #変更
#   - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
"
vim /etc/sysconfig/selinux
# 
echo "#   ※セキュリティ設定は環境に応じて適切に設定してください。"
# 
echo "
# **********************************************************************
#  3 事前準備
# **********************************************************************
# 
# 必要なパッケージをインストールします。
"

echo "press Enter"
read Enter

# 
echo "
#   # yum -y install \
#   #   wget make gcc-c++ \
#   #   libxslt libxslt-devel libxml2-devel libyaml-devel readline-devel \
#   #   libjpeg-devel libpng-devel \
#   #   librsvg2-devel ghostscript-devel \
#   #   ImageMagick ImageMagick-devel \
#   #   curl-devel nkf openldap-devel \
#   #   shared-mime-info \
#   #   httpd httpd-devel \
#   #   mysql-server mysql-devel
"
yum -y install \
  wget make gcc-c++ \
  libxslt libxslt-devel libxml2-devel libyaml-devel readline-devel \
  libjpeg-devel libpng-devel \
  librsvg2-devel ghostscript-devel \
  ImageMagick ImageMagick-devel \
  curl-devel nkf openldap-devel \
  shared-mime-info \
  httpd httpd-devel \
  mysql-server mysql-devel

echo "press Enter"
read Enter


# 
echo " 必要なパッケージをダウンロードします。
# 
#   # cd /usr/local/src
#   # wget https://github.com/zomeki/zomeki/tarball/v1.0.1 -O zomeki-1.0.1.tar.gz
#   # wget ftp://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.3-p194.tar.gz
#   # wget http://chasen.org/~taku/software/darts/src/darts-0.32.tar.gz
#   # wget "http://sourceforge.jp/frs/redir.php?m=jaist&f=%2Fchasen-legacy%2F32224%2Fchasen-2.4.4.tar.gz"
#   # wget "http://sourceforge.jp/frs/redir.php?m=iij&f=%2Fipadic%2F24435%2Fipadic-2.7.0.tar.gz"
#   # wget http://jaist.dl.sourceforge.net/project/lame/lame/3.99/lame-3.99.1.tar.gz
"
cd /usr/local/src
wget https://github.com/zomeki/zomeki/tarball/v1.0.1 -O zomeki-1.0.1.tar.gz
wget ftp://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.3-p194.tar.gz
wget http://chasen.org/~taku/software/darts/src/darts-0.32.tar.gz
wget "http://sourceforge.jp/frs/redir.php?m=jaist&f=%2Fchasen-legacy%2F32224%2Fchasen-2.4.4.tar.gz"
wget "http://sourceforge.jp/frs/redir.php?m=iij&f=%2Fipadic%2F24435%2Fipadic-2.7.0.tar.gz"
wget http://jaist.dl.sourceforge.net/project/lame/lame/3.99/lame-3.99.1.tar.gz

echo "press Enter"
read Enter


# 
echo " zomekiユーザを作成します。
# 
#   # useradd -m zomeki
#   # passwd zomeki
"
useradd -m zomeki
passwd zomeki

echo "press Enter"
read Enter


# 
echo " ZOMEKIソースコードを設置します。
# 
#   # mkdir /var/share
#   # tar xvzf zomeki-1.0.1.tar.gz -C /var/share
#   # mv /var/share/zomeki-zomeki-* /var/share/zomeki
#   # chown -R zomeki:zomeki /var/share/zomeki
"
mkdir /var/share
tar xvzf zomeki-1.0.1.tar.gz -C /var/share
mv /var/share/zomeki-zomeki-* /var/share/zomeki
chown -R zomeki:zomeki /var/share/zomeki

echo "press Enter"
read Enter


echo "
# **********************************************************************
#  4 Apache の設定
# **********************************************************************
# 
# 設定ファイルを編集します。
# 
#   # vi /etc/httpd/conf/httpd.conf
#   - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   ServerName zomeki.example.com    #変更
#   - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 
# 設定ファイルにエラーがないことを確認し、Apacheを起動します。
# 
#   # /sbin/service httpd configtest
#   # /sbin/service httpd start
# 
# 自動起動に設定します。
# 
#   # /sbin/chkconfig httpd on
# 
"
vim /etc/httpd/conf/httpd.conf
/sbin/service httpd configtest
/sbin/service httpd start

echo "press Enter"
read Enter


echo "
# **********************************************************************
#  5 MySQL の設定
# **********************************************************************
# 
# 文字エンコーディングの標準を UTF-8 に設定します。
# 
#   # vi /etc/my.cnf
#   - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   [mysqld]
#   character-set-server=utf8    #追加
# 
#   [client]                      #追加（末尾に追加）
#   default-character-set=utf8    #追加
#   - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 
# MySQLを起動します。
# 
#   # /usr/bin/mysql_install_db --user=mysql
#   # /sbin/service mysqld start
# 
# 自動起動に設定します。
# 
#   # /sbin/chkconfig mysqld on
# 
# rootユーザのパスワードを設定します。
#   # /usr/bin/mysqladmin -u root password "pass"
# 
#   ※パスワードは環境に応じて適切に設定してください。
# 
# zomekiユーザを作成します。
#   # /usr/bin/mysql -u root -ppass \
#   > -e "GRANT ALL ON zomeki_production.* TO zomeki@localhost IDENTIFIED BY 'pass'"
# 
#   ※パスワードは環境に応じて適切に設定してください。
# 
"
vim /etc/my.cnf
/usr/bin/mysql_install_db --user=mysql
/sbin/service mysqld start
/sbin/chkconfig mysqld on
/usr/bin/mysqladmin -u root password "pass"
/usr/bin/mysql -u root -ppass \
-e "GRANT ALL ON zomeki_production.* TO zomeki@localhost IDENTIFIED BY 'pass'"

echo "press Enter"
read Enter


echo "
# **********************************************************************
#  6 Ruby on Rails のインストール
# **********************************************************************
# 
# ======================================================================
#  6.1 Ruby のインストール
# ======================================================================
# 
# Rubyをインストールします。
# 
#   # cd /usr/local/src
#   # tar xvzf ruby-1.9.3-p194.tar.gz
#   # cd ruby-1.9.3-p194
#   # ./configure
#   # make && make install
"
cd /usr/local/src
tar xvzf ruby-1.9.3-p194.tar.gz
cd ruby-1.9.3-p194
./configure
make && make install

echo "press Enter"
read Enter


echo "
# ======================================================================
#  6.2 gemライブラリ のインストール
# ======================================================================
# 
# 必要ライブラリをインストールします。
# 
#   # cd /var/share/zomeki
#   # gem install bundler
#   # bundle install --without test development
"
cd /var/share/zomeki
gem install bundler
bundle install --without test development

echo "press Enter"
read Enter


echo "
# ======================================================================
#  6.3 Phusion Passenger のインストール
# ======================================================================
# 
# Phusion Passengerをインストールします。
# 
#   # gem install passenger -v 3.0.14
#   # passenger-install-apache2-module
# 
#   ( 画面の内容を確認して Enterキーを押してください。 )
# 
# Apacheに設定を追加します。
# 
#   # cp /var/share/zomeki/config/samples/passenger.conf \
#   > /etc/httpd/conf.d/passenger.conf
"
gem install passenger -v 3.0.14
passenger-install-apache2-module
cp /var/share/zomeki/config/samples/passenger.conf \
/etc/httpd/conf.d/passenger.conf

echo "press Enter"
read Enter


echo "
# **********************************************************************
#   rootでのインストールはここまで。
#   次はzomekiユーザにて作業を続行してください。
# **********************************************************************
cp cp /root/install_zomeki/install_zome/install_zomeki02.sh /home/zomeki/
chmod 777 /home/zomeki/install_zomeki02.sh
"
cp /root/install_zomeki/install_zomeki02.sh /home/zomeki/
chmod 777 /home/zomeki/install_zomeki02.sh

