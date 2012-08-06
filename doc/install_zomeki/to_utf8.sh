#!/bin/sh
for file in *.dic *.cha chasenrc
do
if [ -f $file ]; then
    nkf --utf8 $file > tmpfile
    mv tmpfile $file
fi
done
exit

