#!/bin/sh

echo "Please notice that this is only used for CentOS/RHEL distros"

# Detecting type of the box
echo "Detecting type of the machine"
MACHINE_TYPE=`uname -m`
if [ ${MACHINE_TYPE} == 'x86_64' ]; then
  LIBPLUGS=/usr/lib64/nagios/plugins
else
  LIBPLUGS=/usr/lib/nagios/plugins
fi

echo "installing CHECK_YUM plugin"
cp check_yum $LIBPLUGS/
chmod +x $LIBPLUGS/check_yum
rm -rf /etc/nrpe.d/check_yum.conf
touch /etc/nrpe.d/check_yum.conf
echo "command[check_updates]=sudo "$LIBPLUGS"/check_yum" >> /etc/nrpe.d/check_yum.conf
echo "nrpe            ALL = (root) NOPASSWD: "$LIBPLUGS"/check_yum" >> /etc/sudoers