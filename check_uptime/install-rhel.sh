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

echo "installing CHECK_UPTIME plugin"
cp check_uptime $LIBPLUGS/
chmod +x $LIBPLUGS/check_uptime
rm -rf /etc/nrpe.d/check_uptime.conf
touch /etc/nrpe.d/check_uptime.conf
echo "command[check_uptime]=sudo "$LIBPLUGS"/check_uptime" >> /etc/nrpe.d/check_uptime.conf                                                                    