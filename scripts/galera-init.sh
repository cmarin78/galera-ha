#!/bin/bash
USER='root'
PASSWD='<your password>'
SERVER=$(sed -n -e '/PublicIP/ s/.*\= *//p' inventory-cluster)
START=$(sed -n -e '/GalStart/ s/.*\= *//p' inventory-cluster)
END=$(sed -n -e '/GalEnd/ s/.*\= *//p' inventory-cluster)

echo -e "\e[44;1mConfiguring Galera Hostnames... \e[0m"

sshpass -p $PASSWD ssh -o StrictHostKeyChecking=no $USER@$SERVER -p 23000 hostnamectl set-hostname galera01
sshpass -p $PASSWD ssh -o StrictHostKeyChecking=no $USER@$SERVER -p 23001 hostnamectl set-hostname galera02
sshpass -p $PASSWD ssh -o StrictHostKeyChecking=no $USER@$SERVER -p 23002 hostnamectl set-hostname galera03

echo -e "\e[44;1mCreating Galera Service files... \e[0m"

sshpass -p $PASSWD ssh $USER@$SERVER -p 23000 "echo -e 'galera02\ngalera03' >> galera.txt"
sshpass -p $PASSWD ssh $USER@$SERVER -p 23001 "echo -e 'galera01\ngalera03' >> galera.txt"
sshpass -p $PASSWD ssh $USER@$SERVER -p 23002 "echo -e 'galera02\ngalera03' >> galera.txt"

PORT=$START
while [ "$PORT" -le $END ]; do
  sshpass -p $PASSWD ssh $USER@$SERVER -p $PORT sh base-install.sh
  sshpass -p $PASSWD ssh $USER@$SERVER -p $PORT sh mysql-disks.sh
  sshpass -p $PASSWD ssh $USER@$SERVER -p $PORT sh galera.sh
  PORT=$(( PORT + 1 ))
done
sleep 10

echo -e "\e[44;1mStarting Galera Cluster... \e[0m"

sshpass -p $PASSWD ssh $USER@$SERVER -p 23000 galera_new_cluster
sleep 20
sshpass -p $PASSWD ssh $USER@$SERVER -p 23001 systemctl start mariadb
sleep 20
sshpass -p $PASSWD ssh $USER@$SERVER -p 23002 systemctl start mariadb
sleep 20

echo -e "\e[44;1mCreating and Configuring MySQL Users... \e[0m"

sshpass -p $PASSWD ssh $USER@$SERVER -p 23000 sh max-galera-user.sh

echo -e "\e[44;1mEnding Instance .. \e[0m"
sleep 5
