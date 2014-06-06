#!/bin/sh

echo "Please notice that this is only used for Centos distros"

ARCH=`arch`
LIB=/usr/lib

if [ $ARCH == "x86_64" ]; then
  LIB=/usr/lib64
fi

cp check_yum $LIB/nagios/plugins/check_yum
chmod +x $LIB/nagios/plugins/check_yum