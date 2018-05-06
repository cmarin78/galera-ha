#!/bin/bash

echo -e "\e[44;1mConfiguring MariaDB Repos... \e[0m"


cat <<EOL> /etc/yum.repos.d/MariaDB10.1.repo
# MariaDB 10.1 CentOS repository list - created 2017-08-10 00:39 UTC
# http://downloads.mariadb.org/mariadb/repositories/
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.1/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
EOL
sleep 2

echo -e "\e[44;1mInstalling MariaDB Servers and Clients... \e[0m"


yum install boost-devel.x86_64 socat MariaDB-server MariaDB-client \
MariaDB-compat MariaDB-common galera socat jemalloc rsync galera lsof -y

sleep 10
echo -e "\e[44;1mStarting MariaDB service... \e[0m"

systemctl start mariadb
sleep 10

echo -e "\e[44;1mConfiguring Root User... \e[0m"

mysql -e "UPDATE mysql.user SET Password = PASSWORD('mariadb') WHERE User = 'root'"
mysql -e "DROP USER ''@'localhost'"
mysql -e "DROP USER ''@'$(hostname)'"
mysql -e "DROP DATABASE test"
mysql -e "FLUSH PRIVILEGES"
sleep 5
systemctl stop mariadb
sleep 2
echo -e "\e[44;1mConfiguring Data Directories... \e[0m"

rsync -av /var/lib/mysql /mysql-data/
mv /var/lib/mysql /var/lib/mysql.bak
touch /mysql-data/mariadb.log

echo -e "\e[44;1mCreating and Editing New Files and Backuping the Old Ones... \e[0m"

mv /etc/my.cnf.d/client.cnf /etc/my.cnf.d/client.cnf.old

cat <<EOL> /etc/my.cnf.d/client.cnf
#
# These two groups are read by the client library
# Use it for options that affect all clients, but not the server
#


[client]
port=3306
socket=/mysql-data/mysql/mysql.sock

# This group is not read by mysql client library,
# If you use the same .cnf file for MySQL and MariaDB,
# use it for MariaDB-only client options
[client-mariadb]
EOL

mv /etc/my.cnf.d/server.cnf /etc/my.cnf.d/server.cnf.old

cat <<EOL> /etc/my.cnf.d/server.cnf
#
# These groups are read by MariaDB server.
# Use it for options that only the server (but not clients) should see
#
# See the examples of server my.cnf files in /usr/share/mysql/
#

# this is read by the standalone daemon and embedded servers
[server]

# this is only for the mysqld standalone daemon
[mysqld]
datadir=/mysql-data/mysql
socket=/mysql-data/mysql/mysql.sock
log-error=/mysql-data/mariadb.log

#
# * Galera-related settings
#
# Mandatory settings
#wsrep_on=ON
#wsrep_provider=
#wsrep_cluster_address=
#binlog_format=row
#default_storage_engine=InnoDB
#innodb_autoinc_lock_mode=2
#
# Allow server to accept connections on all interfaces.
#
#bind-address=0.0.0.0
#
# Optional setting
#wsrep_slave_threads=1
#innodb_flush_log_at_trx_commit=0

# this is only for embedded server
[embedded]

# This group is only read by MariaDB servers, not by MySQL.
# If you use the same .cnf file for MySQL and MariaDB,
# you can put MariaDB-only options here
[mariadb]

# This group is only read by MariaDB-10.1 servers.
# If you use the same .cnf file for MariaDB of different versions,
# use this group for options that older servers don't understand
[mariadb-10.1]
EOL

chown -R mysql:mysql /mysql-data
semanage fcontext -a -t mysqld_db_t "/mysql-data/mysql(/.*)?"
restorecon -R /mysql-data/mysql
sleep 2

systemctl disable mariadb
systemctl disable mysql


IP=$(hostname --ip-address)
NAME=$(hostname)
cat <<EOL>> /etc/my.cnf.d/server.cnf

[galera]
wsrep_on=ON
wsrep_provider=/usr/lib64/galera/libgalera_smm.so
wsrep_cluster_address='gcomm://10.10.0.210,10.10.0.211,10.10.0.212'
wsrep_cluster_name='galera_cluster'
wsrep_node_address='$IP'
wsrep_node_name='$NAME'
wsrep_sst_method=rsync
binlog_format=row
default_storage_engine=InnoDB
innodb_autoinc_lock_mode=2

# Allow server to accept connections on all interfaces.
#
bind-address=0.0.0.0
EOL

echo -e "\e[44;1mCreating and Enabling New System Services... \e[0m"

cat <<EOL> /etc/systemd/system/start-galera.service
[Unit]
Description = starting mariadb service
After = network.target

[Service]
ExecStart = /root/start-galera.sh

[Install]
WantedBy = multi-user.target
EOL

systemctl enable start-galera.service

echo -e "\e[44;1mEnding Instance... \e[0m"
sleep 10
