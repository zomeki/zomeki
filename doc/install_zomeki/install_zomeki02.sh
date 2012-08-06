#!/bin/bash
echo "
# **********************************************************************
#   7 ZOMEKI のインストール
# **********************************************************************
# 
# zomekiユーザに変更します。
# 
#   # su - zomeki
#   $ cd /var/share/zomeki

zomekiユーザでない場合はzomekiユーザになって下さい。
"
echo whoami
whoami
cd /var/share/zomeki

echo "press Enter"
read Enter

echo "
# ======================================================================
#  7.1 設定ファイル
# ======================================================================
# 
# 環境に応じて設定ファイルを編集します。
# 
# ZOMEKI基本設定
# 
#   $ vi config/core.yml
#   - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   production:
#     title: ZOMEKI
#     uri: http://zomeki.example.com/
#     proxy: ※プロキシ
#   - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 
#   ※production部を編集してください。
# 
#   ※プロキシ
#   プロキシサーバが導入されている場合は
#   http://example:8080/ の様に記述してください。
# 
# DB接続情報
# 
#   $ vi config/database.yml
# 
#   ※production部を編集してください。
# 
# VirtualHost設定
# 
#   $ vi config/virtual-hosts/zomeki.conf
"

echo "press Enter"
read Enter

vim config/core.yml
vim config/database.yml
vim config/virtual-hosts/zomeki.conf

echo "press Enter"
read Enter

echo "
# ======================================================================
#  7.2 データベースの作成
# ======================================================================
# 
# データベースとテーブルを作成し、初期データを登録します。
# 
#   $ bundle exec rake db:setup RAILS_ENV=production
"
bundle exec rake db:setup RAILS_ENV=production

echo "press Enter"
read Enter


echo "
# ======================================================================
#  zomekiユーザでのインストールはここまで。
#  続きはrootユーザにて行なって下さい。
# ======================================================================
"
