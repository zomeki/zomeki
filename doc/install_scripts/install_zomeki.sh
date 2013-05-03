#!/bin/bash
DONE_FLAG="/tmp/$0_done"

if [ -z "$ZOMEKI_VERSION" ]; then ZOMEKI_VERSION='v1.0.5'; fi

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
    echo 'ZOMEKI is already exist.'
    exit
  fi

  id zomeki || useradd -m zomeki

  yum install -y ImageMagick-devel mysql-devel openldap-devel
  cd /usr/local/src
  rm -rf zomeki-$ZOMEKI_VERSION.tar.gz zomeki-zomeki-*
  curl -L -o zomeki-$ZOMEKI_VERSION.tar.gz https://github.com/zomeki/zomeki/tarball/$ZOMEKI_VERSION
  mkdir -p /var/share
  tar zxf zomeki-$ZOMEKI_VERSION.tar.gz && mv zomeki-zomeki-* /var/share/zomeki && chown -R zomeki:zomeki /var/share/zomeki
  cd /var/share/zomeki && gem install bundler && bundle install --without test development

  ln -s /var/share/zomeki/script/logrotation/zomeki /etc/logrotate.d/
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
