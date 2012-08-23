#!/bin/bash
DONE_FLAG="/tmp/$0_done"

echo '#### Start servers ####'
if [ -f $DONE_FLAG ]; then exit; fi
echo '-- PRESS ENTER KEY --'
read KEY

ubuntu() {
  echo 'Ubuntu will be supported shortly.'
}

centos() {
  echo "It's CentOS!"

  service httpd stop
  service httpd configtest && service httpd start && chkconfig httpd on

  service mysqld stop
  service mysqld start && chkconfig mysqld on
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
