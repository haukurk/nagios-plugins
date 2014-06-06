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

echo "installing CHECK_CPU plug-in"
cp check_cpu_perf $LIBPLUGS/
chmod +x $LIBPLUGS/check_cpu_perf
rm -rf /etc/nrpe.d/check_cpu_perf.conf
touch /etc/nrpe.d/check_cpu_perf.conf
echo "command[check_cpu]="$LIBPLUGS"/check_cpu_perf 75 60 " >> /etc/nrpe.d/check_cpu_perf.conf