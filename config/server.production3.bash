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

cd ~/

sudo /etc/init.d/nginx stop
sudo /etc/init.d/nginx start

sudo /usr/bin/mongod --dbpath=/data/db --logpath=/log/mongodb/production.log --journal &

bin/mysqld_safe &
