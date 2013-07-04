#!/bin/bash

EPEL_RPM_URL="http://dl.fedoraproject.org/pub/epel/6/`uname -i`/epel-release-6-8.noarch.rpm"
INSTALL_SCRIPTS_URL='https://raw.github.com/zomeki/zomeki/master/doc/install_scripts'

echo '#### Prepare to install ####'

ubuntu() {
  echo 'Ubuntu will be supported shortly.'
}

centos() {
  echo "It's CentOS!"

  rpm -ivh $EPEL_RPM_URL
  yum install -y wget

  cd /usr/local/src

  files=('install_ruby.sh' 'install_zomeki.sh' 'install_apache.rb' 'install_mysql.rb'
         'configure_zomeki.rb' 'install_zomeki_kana_read.sh' 'start_servers.sh' 'install_cron.sh')

  rm -f install_scripts.txt
  for file in ${files[@]}; do
    echo "$INSTALL_SCRIPTS_URL/$file" >> install_scripts.txt
  done

  wget -i install_scripts.txt

  for file in ${files[@]}; do
    chmod 755 $file
  done

  rm -f install_all.sh
  for file in ${files[@]}; do
    echo "./$file" >> install_all.sh
  done
cat <<'EOF' >> install_all.sh

echo "
-- インストールを完了しました。 --

  公開画面: `ruby -ryaml -e "puts YAML.load_file('/var/share/zomeki/config/core.yml')['production']['uri']"`

  管理画面: `ruby -ryaml -e "puts YAML.load_file('/var/share/zomeki/config/core.yml')['production']['uri']"`_system

    管理者（システム管理者）
    ユーザID   : zomeki
    パスワード : zomeki

１．MySQL の root ユーザはパスワードが rootpass に設定されています。適宜変更してください。
    # mysqladmin -u root -prootpass password 'newpass'
２．MySQL の zomeki ユーザはパスワードが zomekipass に設定されています。適宜変更してください。
    mysql> SET PASSWORD FOR zomeki@localhost = PASSWORD('newpass');
    また、変更時には /var/share/zomeki/config/database.yml も合わせて変更してください。
    # vi /var/share/zomeki/config/database.yml
３．OS の zomeki ユーザに cron が登録されています。運用時には有効化してください。
    # crontab -u zomeki -e
"
EOF
  chmod 755 install_all.sh

echo '
-- インストールを続けるには以下のコマンドを実行してください。 --

# cd /usr/local/src && /usr/local/src/install_all.sh
'
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
