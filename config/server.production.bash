#!/bin/bash

sudo apt-get update -y && apt-get upgrade -y
apt-get install -y curl git-core build-essential zlib1g-dev libssl-dev libreadline6-dev cmake make
bash < <(curl -s https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer )

apt-get install -y build-essential openssl libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev libssl-dev 
apt-get install -y libyaml-dev libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev automake libtool bison
apt-get install -y python-software-properties

wget http://mysql.he.net/Downloads/MySQL-5.5/mysql-5.5.17.tar.gz
wget http://fastdl.mongodb.org/linux/mongodb-linux-i686-2.0.1.tgz
# [[ -s "/usr/local/lib/rvm" ]] && source "/usr/local/lib/rvm"

rvm install 1.9.2
rvm --default ruby-1.9.2
rvm use 1.9.2
gem install rails
gem install rake rack

nginx=stable # use nginx=development for latest development version
add-apt-repository -y ppa:nginx/$nginx
apt-get update && apt-get -y install nginx

tar -xzf mongodb-linux-i686-2.0.1.tgz
cp ~/mongodb-linux-i686-2.0.1/bin/* /usr/bin/
mkdir /data && mkdir /data/db
/usr/bin/mongod --journal &

tar -zxvf mysql-5.5.17.tar.gz 
cd mysql-5.5.17
mkdir /usr/local/mysql

groupadd mysql
useradd -g mysql mysql

cmake .
make && make install

cd /usr/local/mysql
chown -R mysql .
chgrp -R mysql .
scripts/mysql_install_db --user=mysql --basedir=/usr/local/mysql
chown -R root .
chown -R mysql data
# Next command is optional
cp support-files/my-medium.cnf /etc/my.cnf

/bin/mysqld_safe --user=mysql &
/usr/local/mysql/bin/mysql_secure_installation
# Next command is optional
cp support-files/mysql.server /etc/init.d/mysql.server

# cleanup 
cd ~/
rm *.gz
rm -rf mysql-5.5.17/
rm -rf mongodb-linux-i686-2.0.1


gem install unicorn

mkdir config
curl -o config/unicorn.rb https://raw.github.com/defunkt/unicorn/master/examples/unicorn.conf.rb
nano config/unicorn.rb
#### COPY INTO unicorn.conf.rb
# APP_PATH = "/var/www/unicorn"
# working_directory APP_PATH
# 
# stdeer_path APP_PATH + "/log/unicorn.stderr.log"
# stdout_path APP_PATH + "/log/unicorn.stderr.log"
# 
# pid APP_PATH + "/tmp/pid/unicorn.pid"


mkdir -p /log
mkdir -p /var
mkdir -p /var/www
cd /var/www

## make sure to have the right keys for this to work
gem instal mysql -- --with-mysql-config=/usr/local/mysql/bin/mysql_config
git clone git@github.com:bnorton/nom_it.git 
cd nom_it
bundle install