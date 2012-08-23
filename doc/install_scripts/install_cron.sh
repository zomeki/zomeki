#!/bin/bash
DONE_FLAG="/tmp/$0_done"

echo '#### Install cron ####'
if [ -f $DONE_FLAG ]; then exit; fi
echo '-- PRESS ANY KEY --'
read KEY

ubuntu() {
  echo 'Ubuntu will be supported shortly.'
}

centos() {
  echo "It's CentOS!"

cat <<EOF > cron_jobs.txt
# 記事の公開/非公開処理を行います。
#10,25,40,55 * * * * /usr/local/bin/ruby /var/share/zomeki/script/rails runner -e production "Script.run('sys/script/tasks/exec')"

# トップページや中間ページを静的ファイルとして書き出します。
#*/15 * * * * /usr/local/bin/ruby /var/share/zomeki/script/rails runner -e production "Script.run('cms/script/nodes/publish')"

# 音声ファイルを静的ファイルとして書き出します。
#*/15 * * * * /usr/local/bin/ruby /var/share/zomeki/script/rails runner -e production "Script.run('cms/script/talk_tasks/exec')"

# 新着記事ポータルで設定したAtomフィードを取り込みます。
#0 * * * * /usr/local/bin/ruby /var/share/zomeki/script/rails runner -e production "Script.run('cms/script/feeds/read')"
EOF

 crontab -u zomeki cron_jobs.txt
}

others() {
  echo 'This OS is not supported.'
  exit
}

if [ -f /etc/lsb-release ]; then
  if grep -qs Ubuntu /etc/lsb-release; then
    ubuntu
  else
    others
  fi
elif [ -f /etc/centos-release ]; then
  centos
else
  others
fi

touch $DONE_FLAG
