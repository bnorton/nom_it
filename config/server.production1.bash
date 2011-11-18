#!/bin/bash

sudo apt-get update -y && sudo apt-get upgrade -y
sudo apt-get install -y python-software-properties 
nginx=stable # use nginx=development for latest development version
add-apt-repository ppa:nginx/$nginx
sudo apt-get update -y && sudo apt-get upgrade -y

sudo apt-get install -y build-essential imagemagick ruby-full openssl libmagickcore-dev libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev automake libtool bison cmake make
# now after adding the ppa just install
sudo apt-get install -y nginx

wget http://mysql.he.net/Downloads/MySQL-5.5/mysql-5.5.17.tar.gz
tar xzf mysql-5.5.17.tar.gz 
cd mysql-5.5.17
cmake .
make && make install

# post install stuffs
cd /usr/local/mysql
scripts/mysql_install_db

# cp support-files/my-medium.cnf /etc/my.cnf
# bin/mysqld_safe --user=mysql &

# Next command is optional
cp support-files/mysql.server /etc/init.d/mysql.server

sudo apt-get install -y mysql-client libmysqlclient16-dev libmysqlclient16 libmysql-ruby libmysqlclient-dev

git config --global user.name "Nom Production"
git config --global user.email "deployer@justnom.it"
git config --global github.user bnorton
git config --global github.token a97228eb813ef5b0734ebc3dee4ce5e5

cat > ~/.gemrc <<GEMRC
---
:verbose: true
:bulk_threshold: 1000
install: --no-ri --no-rdoc --env-shebang
:sources:
- http://gemcutter.org
- http://gems.rubyforge.org/
- http://gems.github.com
:benchmark: false
:backtrace: false
update: --no-ri --no-rdoc --env-shebang
:update_sources: true
GEMRC

cat > ~/.rvmrc <<RVMRC
rvm_trust_rvmrcs_flag=1
RVMRC

echo 'RAILS_ENV=production' >> /etc/environment

cat > /etc/my.cnf <<MY_CNF
#---------------------------------------------------------------------------
# Example MySQL config file for large systems.
#
# This is for a large system with memory = 512M where the system runs mainly
# MySQL.
#
# You can copy this file to
# /etc/my.cnf to set global options,
# mysql-data-dir/my.cnf to set server-specific options (in this
# installation this directory is @localstatedir@) or
# ~/.my.cnf to set user-specific options.
#
# In this file, you can use all long options that a program supports.
# If you want to know which options a program supports, run the program
# with the "--help" option.

# The following options will be passed to all MySQL clients
[client]
#password	= your_password
port  = 8008
socket  = /tmp/mysql.sock

# Here follows entries for some specific programs

# The MySQL server
[mysqld]
port  = 8008
socket  = /tmp/mysql.sock
skip-locking

# Caches and Buffer Sizes
key_buffer = 256M
max_allowed_packet=16M
table_cache = 256
sort_buffer_size = 2M
read_buffer_size = 2M
read_rnd_buffer_size = 4M
record_buffer = 1M
myisam_sort_buffer_size = 128M
thread_cache = 128
query_cache_limit = 2M
query_cache_type = 1
query_cache_size = 32M
key_buffer = 16M
join_buffer = 2M
table_cache = 1024

#Time Outs
interactive_timeout = 100
wait_timeout = 100
connect_timeout = 10

# Try number of CPU's*2 for thread_concurrency
thread_concurrency = 2

# Maximum connections allowed
max_connections = 500
max_user_connections = 50
max_connect_errors = 10

# Don't listen on a TCP/IP port at all. This can be a security enhancement,
# if all processes that need to connect to mysqld run on the same host.
# All interaction with mysqld must be made via Unix sockets or named pipes.
# Note that using this option without enabling named pipes on Windows
# (via the "enable-named-pipe" option) will render mysqld useless!
# 
#skip-networking

# Replication Master Server (default)
# binary logging is required for replication
log-bin

# required unique id between 1 and 2^32 - 1
# defaults to 1 if master-host is not set
# but will not function as a master if omitted
server-id	= 1

# Replication Slave (comment out master section to use this)
#
# To configure this host as a replication slave, you can choose between
# two methods :
#
# 1) Use the CHANGE MASTER TO command (fully described in our manual) -
#    the syntax is:
#
#    CHANGE MASTER TO MASTER_HOST=<host>, MASTER_PORT=<port>,
#    MASTER_USER=<user>, MASTER_PASSWORD=<password> ;
#
#    where you replace <host>, <user>, <password> by quoted strings and
#    <port> by the master's port number (3306 by default).
#
#    Example:
#
#    CHANGE MASTER TO MASTER_HOST='125.564.12.1', MASTER_PORT=3306,
#    MASTER_USER='joe', MASTER_PASSWORD='secret';
#
# OR
#
# 2) Set the variables below. However, in case you choose this method, then
#    start replication for the first time (even unsuccessfully, for example
#    if you mistyped the password in master-password and the slave fails to
#    connect), the slave will create a master.info file, and any later
#    change in this file to the variables' values below will be ignored and
#    overridden by the content of the master.info file, unless you shutdown
#    the slave server, delete master.info and restart the slaver server.
#    For that reason, you may want to leave the lines below untouched
#    (commented) and instead use CHANGE MASTER TO (see above)
#
# required unique id between 2 and 2^32 - 1
# (and different from the master)
# defaults to 2 if master-host is set
# but will not function as a slave if omitted
#server-id      = 2
#
# The replication master for this slave - required
#master-host    =  <hostname>
#
# The username the slave will use for authentication when connecting
# to the master - required
#master-user    =  <username>
#
# The password the slave will authenticate with when connecting to
# the master - required
#master-password =  <password>
#
# The port the master is listening on.
# optional - defaults to 3306
#master-port    =  <port>
#
# binary logging - not required for slaves, but recommended
#log-bin

# Point the following paths to different dedicated disks
#tmpdir  = /tmp/  
#log-update  = /path-to-dedicated-directory/hostname

# Uncomment the following if you are using BDB tables
#bdb_cache_size = 64M
#bdb_max_lock = 100000

# Uncomment the following if you are using InnoDB tables
innodb_data_home_dir = /var/lib/mysql/
innodb_data_file_path = ibdata1:10M:autoextend
innodb_log_group_home_dir = /var/log/innodblogs/
innodb_log_arch_dir = /var/log/innodblogsarchive/
# You can set .._buffer_pool_size up to 50 - 80 %
# of RAM but beware of setting memory usage too high
innodb_buffer_pool_size = 160M
innodb_additional_mem_pool_size = 20M
# Set .._log_file_size to 25 % of buffer pool size
innodb_log_file_size = 40M
innodb_log_buffer_size = 8M
innodb_flush_log_at_trx_commit = 1
innodb_lock_wait_timeout = 50

[mysqldump]
quick
max_allowed_packet = 16M

[safe_mysqld]
#err-log=/var/log/mysqld.log
#pid-file=/var/lib/mysql/mysql.pid <-- Not necessary
open_files_limit=8192


[mysql]
no-auto-rehash
# Remove the next comment character if you are not familiar with SQL
#safe-updates

[isamchk]
key_buffer = 128M
sort_buffer_size = 128M
read_buffer = 2M
write_buffer = 2M

[myisamchk]
key_buffer = 128M
sort_buffer_size = 128M
read_buffer = 2M
write_buffer = 2M

[mysqlhotcopy]
interactive-timeout/log
#------------------------------------------------------------------------------------------
MY_CNF

