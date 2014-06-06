#!/bin/sh 

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

# String replacement
echo "Modifying configuration file for NRPE"
sed -i 's/allowed_hosts=127.0.0.1/allowed_hosts=192.168.174.46,127.0.0.1/g' $NRPE_LOCATION 
sed -i 's/dont_blame_nrpe=0/dont_blame_nrpe=1/g' $NRPE_LOCATION

# Enabling plugins
grep -w "include_dir=/etc/nrpe.d" $NRPE_LOCATION >/dev/null
if [ $? -eq 0 ]
then
   echo "/etc/nrpe.d/ is already included in the configuration file. SKIP."
else
   echo "+ Added /etc/nrpe.d/ include to nrpe"; echo "include_dir=/etc/nrpe.d/" >> $NRPE_LOCATION
fi

# Installing plugins from GIT.
# TODO

echo "configuring NRPE to run at boot."
chkconfig nrpe on
service nrpe restart

echo "allowing ports in the firewall."
iptables -A INPUT -m state --state NEW -p tcp --dport 5666 -j ACCEPT
service iptables restart
