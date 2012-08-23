#!/bin/bash
DONE_FLAG="/tmp/$0_done"

RUBY_19='ruby-1.9.3-p194'

echo "#### Install $RUBY_19 ####"
if [ -f $DONE_FLAG ]; then exit; fi
echo '-- PRESS ANY KEY --'
read KEY

ubuntu() {
  echo 'Ubuntu will be supported shortly.'
}

centos() {
  echo "It's CentOS!"

  yum install -y gcc-c++ libffi-devel libyaml-devel make openssl-devel readline-devel zlib-devel
  cd /usr/local/src
  rm -rf $RUBY_19.tar.gz $RUBY_19
  wget ftp://ftp.ruby-lang.org/pub/ruby/1.9/$RUBY_19.tar.gz
  tar zxf $RUBY_19.tar.gz && cd $RUBY_19 && ./configure && make && make install
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
