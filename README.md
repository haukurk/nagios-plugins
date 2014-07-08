#### Nagios Related ####
This repository is for useful Nagios related plugins, binaries and scripts that I've been working on or found over the years. 

#### Plugin Installation ####
These have only been tested on Centos 6.5 or AIX, depending on which OS the plugin is made for.

Each plugin includes a installation script which you can just run:
```
cd plugin-name
sh install.sh
```

#### List of plugins ####

* AIX file-system checks *(deprecated, please use check disks plugin)*
* Yum Checks
* Check uptime for Linux
* Check CPU utilization for Linux
* Check disks (from df outputs) Linux/UNIX/Windows

#### Unofficial Binaries ####

* AIX Binaries for NRPE 2.12
** Needs openSSL
** Compiled with argument support

