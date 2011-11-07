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
user deployer staff;

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
  server unix:/tmp/unicorn.nom_it.socket fail_timeout=0;
}

server {
    listen 80 default;
    server_name localhost justnom.it;

    root /home/deployer/apps/justnom.it/current/public;
    access_log /var/log/nginx/justnom_it_access.log;
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
      root /home/deployer/apps/justnom.it/current/public;
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
