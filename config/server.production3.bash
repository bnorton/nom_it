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
NGINX_CONF

sudo cat > /etc/nginx/sites-enabled/default <<DEFAULT
DEFAULT

sudo /etc/init.d/nginx stop
sudo /etc/init.d/nginx start

echo 'scp .ssh files into the right places'
read -p 'done? [y|n]> '
if [[ $REPLY =~ ^[Yy]$ ]]
  then
    echo 'checking git config'
    ssh -T git@github.com
fi
