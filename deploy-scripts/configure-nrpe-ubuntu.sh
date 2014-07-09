#!/bin/sh 

echo "double check if nrpe and plugins are there from EPEL"
apt-get install nrpe -y
apt-get install nagios-plugins-extra nagios-plugins-standard nagios-plugins -y

# Configuration - Default for CentOS NRPE (EPEL).
NRPE_LOCATION=/etc/nagios/nrpe.cfg
if [[ ! -f $NRPE_LOCATION ]]; then
    echo "Config file not found!"
	exit 1
fi

# Detecting type of the box
echo "Detecting type of the machine"
MACHINE_TYPE=`uname -m`
if [ ${MACHINE_TYPE} == 'x86_64' ]; then
  LIBPLUGS=/usr/lib64/nagios/plugins
else
  LIBPLUGS=/usr/lib/nagios/plugins
fi

# If you don't know how to configure SElinux, put it in permissive mode:
sed -i "s/SELINUX=enforcing/SELINUX=permissive/" /etc/sysconfig/selinux
setenforce 0

# String replacement
echo "Modifying configuration file for NRPE"
sed -i 's/allowed_hosts=127.0.0.1/allowed_hosts=192.168.174.46,127.0.0.1/g' $NRPE_LOCATION 
sed -i 's/dont_blame_nrpe=0/dont_blame_nrpe=1/g' $NRPE_LOCATION

# Enabling plugins
mkdir /etc/nrpe.d # Create the folder first.
grep -w "include_dir=/etc/nrpe.d" $NRPE_LOCATION >/dev/null
if [ $? -eq 0 ]
then
   echo "/etc/nrpe.d/ is already included in the configuration file. SKIP."
else
   echo "+ Added /etc/nrpe.d/ include to nrpe"; echo "include_dir=/etc/nrpe.d/" >> $NRPE_LOCATION
fi

# Installing plugins from GIT master.
echo "bundle proxy for built-in linux commands to checks."
rm -rf /etc/nrpe.d/checks-bundle.cfg
touch /etc/nrpe.d/checks-bundle.cfg
echo "command[get_disks]=/bin/df -k -x none -x tmpfs -x shmfs -x unknown -x iso9660" >> /etc/nrpe.d/checks-bundle.cfg
echo "command[get_time]=/bin/date +%s" >> /etc/nrpe.d/checks-bundle.cfg
echo "command[get_uptime]=uptime" >> /etc/nrpe.d/checks-bundle.cfg
echo "command[get_selinux]=getenforce" >> /etc/nrpe.d/checks-bundle.cfg
echo "command[check_procs]="$LIBPLUGS"/check_procs -w '\$ARG1\$' -c '\$ARG2\$' -C '\$ARG3\$'" >> /etc/nrpe.d/checks-bundle.cfg
echo "command[check_total_procs]="$LIBPLUGS"/check_procs -w '\$ARG1\$' -c '\$ARG2\$'" >> /etc/nrpe.d/checks-bundle.cfg
echo "command[check_swap]="$LIBPLUGS"/check_swap -w '\$ARG1\$'% -c '\$ARG2\$'% --allswaps" >> /etc/nrpe.d/checks-bundle.cfg
echo "command[check_disk]="$LIBPLUGS"/check_disk -w '\$ARG1\$' -c '\$ARG2\$' -p '\$ARG3\$'" >> /etc/nrpe.d/checks-bundle.cfg

echo "installing CHECK_YUM plugin"
curl -o $LIBPLUGS/check_yum https://raw.githubusercontent.com/haukurk/nagios-plugins/master/check_yum/check_yum 
chmod +x $LIBPLUGS/check_yum
rm -rf /etc/nrpe.d/check_yum.cfg
touch /etc/nrpe.d/check_yum.cfg
echo "command[check_updates]=sudo "$LIBPLUGS"/check_yum" >> /etc/nrpe.d/check_yum.cfg
#echo "ALL ALL= (root) NOPASSWD: "$LIBPLUGS"/check_yum" >> /etc/sudoers
echo "Defaults:nrpe   !requiretty" >> /etc/sudoers
echo "nrpe ALL = (root) NOPASSWD: "$LIBPLUGS"/check_yum" >> /etc/sudoers
# TODO: sometimes nagios is the user.

echo "installing CHECK_UPTIME plugin"
curl -o $LIBPLUGS/check_uptime https://raw.githubusercontent.com/haukurk/nagios-plugins/master/check_uptime/check_uptime 
chmod +x $LIBPLUGS/check_uptime
rm -rf /etc/nrpe.d/check_uptime.cfg
touch /etc/nrpe.d/check_uptime.cfg
echo "command[check_uptime]="$LIBPLUGS"/check_uptime" >> /etc/nrpe.d/check_uptime.cfg

echo "installing CHECK_CPU_PERF plugin"
curl -o $LIBPLUGS/check_cpu_perf https://raw.githubusercontent.com/haukurk/nagios-plugins/master/check_cpu_perf/check_cpu_perf
chmod +x $LIBPLUGS/check_cpu_perf
rm -rf /etc/nrpe.d/check_cpu_perf.cfg
touch /etc/nrpe.d/check_cpu_perf.cfg
echo "command[check_cpu]="$LIBPLUGS"/check_cpu_perf 75 60 " >> /etc/nrpe.d/check_cpu_perf.cfg

echo "configuring NRPE to run at boot."
chkconfig nrpe on
service nrpe restart

echo "allowing ports in the firewall."
iptables -A INPUT -m state --state NEW -p tcp --dport 5666 -j ACCEPT
service iptables restart
