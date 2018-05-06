#!/bin/bash
echo -e "\e[44;1mInstalling Base Packages... \e[0m"
sleep 2
yum -y update && yum -y upgrade
yum -y install nano mc nmap telnet parted policycoreutils-python
yum provides /usr/sbin/semanage
yum install -y ntp
systemctl enable ntpd
ntpdate pool.ntp.org
systemctl start ntpd

echo -e "\e[44;1mBase Packages Installed and Running... \e[0m"
sleep 5
