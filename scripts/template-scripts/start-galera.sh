#!/bin/bash
rm -rf /mysql-data/mysql/grastate.dat
cat galera.txt | while read output
do
  	ping -c 1 "$output" > /dev/null
        if [ $? -eq 0 ]; then
        systemctl start	mariadb
        else
        galera_new_cluster
        fi
done
