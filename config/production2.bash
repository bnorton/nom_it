#!/bin/bash

mkdir -p src
cd src
wget http://production.cf.rubygems.org/rubygems/rubygems-1.8.10.tgz
tar zxf rubygems-1.8.10.tgz
cd rubygems-1.8.10
sudo ruby setup.rb
cd ~/

rvmsudo rvm pkg install 'openssl 0.9.8n'

rvmsudo rvm install ree
rvm --default use ree
rvm gemset create nom
rvm --default use ree@nom

rvmsudo gem update --system
rvmsudo gem install bundler rails rake rack unicorn mysql2 json bson bson_ext --no-ri --no-rdoc

cd ~/src

wget http://fastdl.mongodb.org/linux/mongodb-linux-x86_64-2.0.1.tgz
tar -xzf mongodb-linux-x86_64-2.0.1.tgz
sudo cp mongodb-linux-x86_64-2.0.1/bin/* /usr/bin/

sudo mkdir /data && sudo mkdir -p /data/db && sudo mkdir -p /log && sudo mkdir -p /log/mongodb
sudo touch /log/mongodb/production.log

sudo /usr/bin/mongod --dbpath=/data/db --logpath=/log/mongodb/production.log --journal &

cd ~/
sudo mkdir -p /var /var/log /var/log/nginx/
sudo mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.original

sudo cat > /etc/nginx/nginx.conf <<NGINX_CONF
user root root;

# Change this depending on your hardware
worker_processes 4;
pid /var/run/nginx.pid;

events {
    worker_connections 1024;
    multi_accept on;
}

http {
    sendfile on;
    tcp_nopush on;
    tcp_nodelay off;
    # server_tokens off;

    # server_names_hash_bucket_size 64;
    # server_name_in_redirect off;

    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;

    gzip on;
    gzip_disable "msie6";

    # gzip_vary on;
    gzip_proxied any;
    gzip_min_length 500;
    # gzip_comp_level 6;
    # gzip_buffers 16 8k;
    # gzip_http_version 1.1;
    gzip_types text/plain text/css application/json application/x-javascript text/xml application/x\$

    ##
    # Virtual Host Configs
    ##

    include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/sites-enabled/*;
}
NGINX_CONF

sudo cat > /etc/nginx/sites-enabled/default <<DEFAULT
upstream nom {
  server unix:/apps/nom/shared/sockets/unicorn.socket fail_timeout=0;
}

server {
    listen 80 default;
    server_name _;

    root /apps/nom/current/public;
    access_log /var/log/nginx/nom_access.log;
    rewrite_log on;

    location / {
        #all requests are sent to the UNIX socket
        proxy_pass  http://nom;
        proxy_redirect     off;

        proxy_set_header   Host             \$host;
        proxy_set_header   X-Real-IP        \$remote_addr;
        proxy_set_header   X-Forwarded-For  \$proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto \$scheme;

        client_max_body_size       128m;

        proxy_connect_timeout      90;
        proxy_send_timeout         90;
        proxy_read_timeout         90;

        proxy_buffer_size          64k;
        proxy_buffers              32 16k;
        proxy_busy_buffers_size    64k;
        proxy_temp_file_write_size 64k;
    }

    location ~ ^/(images|javascripts|stylesheets|system)/  {
      root /apps/nom/current/public;
      expires max;
      break;
    }
}
DEFAULT

sudo /etc/init.d/nginx stop
sudo /etc/init.d/nginx start

scp -r root@justnom.it:~/.ssh .ssh
# echo 'scp .ssh files into the right places'
# read -p 'done? [y|n]> '
# if [[ $REPLY =~ ^[Yy]$ ]]
#   then
#     echo 'checking git config'
ssh -T git@github.com
# fi

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

