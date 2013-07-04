#!/bin/bash
DONE_FLAG="/tmp/$0_done"

RUBY_VERSION='ruby-1.9.3-p448'
RUBY_SOURCE_URL="ftp://ftp.ruby-lang.org/pub/ruby/1.9/$RUBY_VERSION.tar.gz"

echo "#### Install $RUBY_VERSION ####"
if [ -f $DONE_FLAG ]; then exit; fi
echo '-- PRESS ENTER KEY --'
read KEY

ubuntu() {
  echo 'Ubuntu will be supported shortly.'
}

centos() {
  echo "It's CentOS!"

  yum install -y gcc-c++ libffi-devel libyaml-devel make openssl-devel readline-devel zlib-devel
  cd /usr/local/src
  rm -rf $RUBY_VERSION.tar.gz $RUBY_VERSION
  wget $RUBY_SOURCE_URL
  tar zxf $RUBY_VERSION.tar.gz && cd $RUBY_VERSION && ./configure && make && make install
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
