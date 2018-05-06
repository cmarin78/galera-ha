#!/bin/bash

echo -e "\e[44;1mDownloading and Installing Maxscale Package... \e[0m"
sleep 5

wget https://downloads.mariadb.com/MaxScale/2.1.10/centos/7/x86_64/maxscale-2.1.10-1.centos.7.x86_64.rpm

yum -y install ./maxscale-2.1.10-1.centos.7.x86_64.rpm

usermod maxscale -s /bin/bash

echo -e "\e[44;1mConfiguring Maxscale Files... \e[0m"
sleep 5

mv /etc/maxscale.cnf /etc/maxscale.cnf.old

cat <<EOL> /etc/maxscale.cnf
# Globals
[maxscale]
threads=4

# Servers
[galera01]
type=server
address=10.10.0.210
port=3306
protocol=MySQLBackend

[galera02]
type=server
address=10.10.0.211
port=3306
protocol=MySQLBackend

[galera03]
type=server
address=10.10.0.212
port=3306
protocol=MySQLBackend

# Monitoring for the Servers
[Galera Monitor]
type=monitor
module=galeramon
servers=galera01,galera02,galera03
user=maxscale
passwd=maxscale
monitor_interval=1000

# Galera Router Service
[Galera Service]
type=service
router=readwritesplit
servers=galera01,galera02,galera03
user=maxscale
passwd=maxscale

# MaxAdmin Service
[MaxAdmin Service]
type=service
router=cli

# Galera Cluster Listener
[Galera Listener]
type=listener
service=Galera Service
protocol=MySQLClient
port=3306

# Maxadmin Listener
[MaxAdmin Listener]
type=listener
service=MaxAdmin Service
protocol=maxscaled
socket=default
EOL

echo -e "\e[44;1mInstalling Pacemaker Pakages and Prerrequisites... \e[0m"


yum install -y pacemaker pcs psmisc policycoreutils-python
echo 'hacluster' | passwd --stdin 'hacluster'
systemctl start pcsd.service
systemctl enable pcsd.service

echo -e "\e[44;1mEnding Instance... \e[0m"
sleep 5
