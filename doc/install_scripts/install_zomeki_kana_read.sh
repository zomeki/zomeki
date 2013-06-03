#!/bin/bash
DONE_FLAG="/tmp/$0_done"

echo '#### Install ZOMEKI (kana, read) ####'
if [ -f $DONE_FLAG ]; then exit; fi
echo '-- PRESS ENTER KEY --'
read KEY

ubuntu() {
  echo 'Ubuntu will be supported shortly.'
}

centos() {
  echo "It's CentOS!"

  cd /usr/local/src
  rm -rf darts-0.32.tar.gz darts-0.32
  wget http://chasen.org/~taku/software/darts/src/darts-0.32.tar.gz
  tar zxf darts-0.32.tar.gz && cd darts-0.32 && ./configure && make && make install

  cd /usr/local/src
  rm -rf lame-3.99.5.tar.gz lame-3.99.5
  wget http://jaist.dl.sourceforge.net/project/lame/lame/3.99/lame-3.99.5.tar.gz
  tar zxf lame-3.99.5.tar.gz && cd lame-3.99.5 && ./configure && make && make install

  cd /usr/local/src
  rm -rf chasen-2.4.4.tar.gz chasen-2.4.4
  wget http://jaist.dl.sourceforge.jp/chasen-legacy/32224/chasen-2.4.4.tar.gz
  tar zxf chasen-2.4.4.tar.gz && cd chasen-2.4.4 && ./configure && make && make install

  yum install -y nkf
  cd /usr/local/src
  rm -rf ipadic-2.7.0.tar.gz ipadic-2.7.0
  wget http://iij.dl.sourceforge.jp/ipadic/24435/ipadic-2.7.0.tar.gz
  tar zxf ipadic-2.7.0.tar.gz && cd ipadic-2.7.0 && ./configure
cat <<'EOF' > to_utf8.sh
#!/bin/bash
for file in *.dic *.cha chasenrc
do
if [ -f $file ]; then
  nkf --utf8 $file > tmpfile
  mv tmpfile $file
fi
done
exit
EOF
  chmod 755 to_utf8.sh
  ./to_utf8.sh
  ldconfig
  `chasen-config --mkchadic`/makemat -i w
  `chasen-config --mkchadic`/makeda -i w chadic *.dic
  make install

  yum install -y libxslt-devel
  cd /var/share/zomeki/ext/morph/chaone
  chmod 775 configure
  ./configure && make && make install

  cd /var/share/zomeki/ext/gtalk
  chmod 775 configure
  ./configure && make
  chmod 755 /var/share/zomeki/ext/gtalk_filter.rb
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
