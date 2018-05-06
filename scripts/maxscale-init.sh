#!/bin/bash
USER='root'
PASSWD='<your password>'
SERVER=$(sed -n -e '/PublicIP/ s/.*\= *//p' inventory-cluster)
START=$(sed -n -e '/MaxStart/ s/.*\= *//p' inventory-cluster)
END=$(sed -n -e '/MaxEnd/ s/.*\= *//p' inventory-cluster)

echo -e "\e[44;1mConfiguring Maxscale Hostnames... \e[0m"

sshpass -p $PASSWD ssh -o StrictHostKeyChecking=no $USER@$SERVER -p 23003 hostnamectl set-hostname maxscale01
sshpass -p $PASSWD ssh -o StrictHostKeyChecking=no $USER@$SERVER -p 23004 hostnamectl set-hostname maxscale02
sshpass -p $PASSWD ssh -o StrictHostKeyChecking=no $USER@$SERVER -p 23005 hostnamectl set-hostname maxscale03

echo -e "\e[44;1mCreating Maxscale Cluster... \e[0m"
PORT=$START
while [ "$PORT" -le $END ]; do
  sshpass -p $PASSWD ssh $USER@$SERVER -p $PORT sh base-install.sh
  sshpass -p $PASSWD ssh $USER@$SERVER -p $PORT sh maxscale.sh
  PORT=$(( PORT + 1 ))
done
sleep 10

echo -e "\e[44;1mStarting Pacemaker Cluster Config Files and Services... \e[0m"

sshpass -p $PASSWD ssh $USER@$SERVER -p 23003 sh pacemaker.sh
sleep 10

echo -e "\e[44;1mEnding Maxscale-Pacemaker Cluster Starting and Configuration... \e[0m"
sleep 5
