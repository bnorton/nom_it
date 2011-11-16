#!/bin/bash

sudo apt-get update -y && sudo apt-get upgrade -y
sudo apt-get install -y python-software-properties 
nginx=stable # use nginx=development for latest development version
add-apt-repository ppa:nginx/$nginx
sudo apt-get update -y && sudo apt-get upgrade -y

sudo apt-get install -y build-essential imagemagick ruby-full openssl libmagickcore-dev libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev automake libtool bison cmake make
# now after adding the ppa just install
sudo apt-get install -y nginx
sudo apt-get install -y mysql-server mysql-client libmysqlclient16-dev libmysqlclient16 libmysql-ruby libmysqlclient-dev

wget http://mysql.he.net/Downloads/MySQL-5.5/mysql-5.5.17.tar.gz
tar xzf mysql-5.5.17.tar.gz 
cd mysql-5.5.17
cmake .
make && make install

# post install stuffs
cd /usr/local/mysql
scripts/mysql_install_db

cp support-files/my-medium.cnf /etc/my.cnf
bin/mysqld_safe --user=mysql &

# Next command is optional
cp support-files/mysql.server /etc/init.d/mysql.server

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

