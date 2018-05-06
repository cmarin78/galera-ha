#!/bin/bash
echo -e "\e[44;1mStarting Disk and Data-dir Configuration... \e[0m"
sleep 5
parted /dev/xvdb mklabel gpt
parted -a opt /dev/xvdb mkpart primary xfs 0% 100%
mkfs.xfs /dev/xvdb1 -f
mkdir -p /mysql-data/
mount /dev/xvdb1 /mysql-data/
echo "/dev/xvdb1 /mysql-data  xfs  defaults 0 0" >> /etc/fstab

echo -e "\e[44;1mEnding Disk Partition and Configuration... \e[0m"
sleep 5
