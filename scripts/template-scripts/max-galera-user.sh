#!/bin/bash
# creating and enabling repication users and admin users.
echo -e "\e[44;1mCreating Admin and Replication Users... \e[0m"
sleep 5
mysql -u root -pmariadb << Mysql_script
create user 'maxscale'@'%' identified by 'maxscale';
GRANT SELECT ON mysql.user TO 'maxscale'@'%' with grant option;
GRANT SELECT ON mysql.db TO 'maxscale'@'%' with grant option;
GRANT SELECT ON mysql.tables_priv TO 'maxscale'@'%' with grant option;
GRANT SHOW DATABASES ON *.* TO 'maxscale'@'%' with grant option;
GRANT REPLICATION SLAVE on *.* to 'maxscale'@'%' with grant option;
GRANT REPLICATION CLIENT on *.* to 'maxscale'@'%' with grant option;
show grants for 'maxscale'@'%';
create user 'galera'@'%' identified by 'galera';
grant all on *.* to 'galera'@'%' with grant option;
flush privileges;
quit
Mysql_script

echo -e "\e[44;1mEnding Instance... \e[0m"
sleep 5
