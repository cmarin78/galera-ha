#!/bin/bash
echo -e "\e[41;1mStarting Cluster Setup... \e[0m"
sleep 2
echo -e "\e[41;1mRunning Ansible Tasks... \e[0m"
ansible-playbook galera-cluster.yml -i inventory-cluster
echo -e "\e[41;1mEnding VMs Config... \e[0m"
sleep 2
echo -e "\e[41;1mStarting Galera Setup... \e[0m"
./scripts/galera-init.sh
echo -e "\e[41;1mEnding Galera Setup... \e[0m"
sleep 2
echo -e "\e[41;1mStarting Maxscale and Pacemaker Cluster Setup... \e[0m"
sleep 2
./scripts/maxscale-init.sh
echo -e "\e[41;1mEnding Cluster Setup... \e[0m"
sleep 2
