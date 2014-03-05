#!/bin/bash
DONE_FLAG="/tmp/$0_done"

echo '#### Install ZOMEKI ####'
if [ -f $DONE_FLAG ]; then exit; fi
echo '-- PRESS ENTER KEY --'
read KEY

ubuntu() {
  echo 'Ubuntu will be supported shortly.'
}

centos() {
  echo "It's CentOS!"

  if [ -d /var/share/zomeki ]; then
    echo 'ZOMEKI is already installed.'
    exit
  fi

  id zomeki || useradd -m zomeki

  yum install -y ImageMagick-devel libxml2-devel libxslt-devel mysql-devel openldap-devel

  git clone https://github.com/zomeki/zomeki-development.git /var/share/zomeki
  chown -R zomeki:zomeki /var/share/zomeki
  su - zomeki -c 'cd /var/share/zomeki && bundle install --path vendor/bundle --without development test'

  cp /var/share/zomeki/config/samples/zomeki_logrotate /etc/logrotate.d/.
}

others() {
  echo 'This OS is not supported.'
  exit
}

if [ -f /etc/centos-release ]; then
  centos
elif [ -f /etc/lsb-release ]; then
  if grep -qs Ubuntu /etc/lsb-release; then
    ubuntu
  else
    others
  fi
else
  others
fi

touch $DONE_FLAG
