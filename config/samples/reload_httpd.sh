#!/bin/sh

RELOAD_FLAG_FILE='/var/share/zomeki/tmp/reload_virtual_hosts.txt'

if [ -e $RELOAD_FLAG_FILE ]; then
  /sbin/service httpd reload > /dev/null 2>&1
  rm -f $RELOAD_FLAG_FILE
fi
