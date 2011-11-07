#!/bin/bash

mkdir -p src
cd src
wget http://production.cf.rubygems.org/rubygems/rubygems-1.8.10.tgz
tar zxf rubygems-1.8.10.tgz
cd rubygems-1.8.10
sudo ruby setup.rb
cd ~/

# cat > ~/.gemrc <<GEMRC
# ---
# :verbose: true
# :bulk_threshold: 1000
# install: --no-ri --no-rdoc --env-shebang
# :sources:
# - http://gemcutter.org
# - http://gems.rubyforge.org/
# - http://gems.github.com
# :benchmark: false
# :backtrace: false
# update: --no-ri --no-rdoc --env-shebang
# :update_sources: true
# GEMRC
# 
# cat > ~/.rvmrc <<RVMRC
# rvm_trust_rvmrcs_flag=1
# RVMRC

rvmsudo rvm pkg install 'openssl 0.9.8n'

# cd ~/.rvm/src/ree-1.8.7-2011.03/source/ext/openssl  
# 
# cat > openssl.patch <<OPENSSL_PATCH
# From b983e73adf7a7d3fd07fdf493eee51c22881a6e6 Mon Sep 17 00:00:00 2001
# From: Nobuhiro Iwamatsu <iwamatsu@nigauri.org>
# Date: Wed, 6 Apr 2011 02:28:09 +0900
# Subject: [PATCH] Add option which enable SSLv2 support
# 
# From openssl 1.0, SSLv2 becomes disable by default.
# If you want to use SSLv2 in ruby, you need config with --enable-opensslv2.
# The SSLv2 support is disable by default.
# 
# Signed-off-by: Nobuhiro Iwamatsu <iwamatsu@nigauri.org>
# ---
#  ext/openssl/extconf.rb |    8 ++++++++
#  ext/openssl/ossl_ssl.c |    2 ++
#  2 files changed, 10 insertions(+), 0 deletions(-)
# 
# diff --git a/ext/openssl/extconf.rb b/ext/openssl/extconf.rb
# index b1f2d88..89c6f19 100644
# --- a/ext/openssl/extconf.rb
# +++ b/ext/openssl/extconf.rb
# @@ -33,6 +33,14 @@ if with_config("debug") or enable_config("debug")
#    end
#  end
#  
# +## 
# +## From openssl 1.0, SSLv2 becomes disable by default.
# +## If you want to use SSLv2 in ruby, you need config with --enable-opensslv2.
# +##
# +if enable_config("opensslv2")
# +  $defs << "-DENABLE_OPENSSLV2"
# +end
# +
#  message "=== Checking for system dependent stuff... ===\n"
#  have_library("nsl", "t_open")
#  have_library("socket", "socket")
# diff --git a/ext/openssl/ossl_ssl.c b/ext/openssl/ossl_ssl.c
# index d8951fb..d0c9059 100644
# --- a/ext/openssl/ossl_ssl.c
# +++ b/ext/openssl/ossl_ssl.c
# @@ -107,9 +107,11 @@ struct {
#      OSSL_SSL_METHOD_ENTRY(TLSv1),
#      OSSL_SSL_METHOD_ENTRY(TLSv1_server),
#      OSSL_SSL_METHOD_ENTRY(TLSv1_client),
# +#if defined(ENABLE_OPENSSLV2)
#      OSSL_SSL_METHOD_ENTRY(SSLv2),
#      OSSL_SSL_METHOD_ENTRY(SSLv2_server),
#      OSSL_SSL_METHOD_ENTRY(SSLv2_client),
# +#endif
#      OSSL_SSL_METHOD_ENTRY(SSLv3),
#      OSSL_SSL_METHOD_ENTRY(SSLv3_server),
#      OSSL_SSL_METHOD_ENTRY(SSLv3_client),
# -- 
# 1.7.4.1
# 
# OPENSSL_PATCH
# 
# rm *.o
# patch < openssl.patch
# ruby extconf.rb
# make && sudo make install
# cd ~/

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
# sudo chown -R deployer:staff /log

sudo /usr/bin/mongod --dbpath=/data/db --logpath=/log/mongodb/production.log --journal &

# sudo chown -R deployer:staff /var/log
# sudo chown -R deployer:staff /etc/nginx

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

echo 'scp .ssh files into the right places'
read -p 'done? [y|n]> '
if [[ $REPLY =~ ^[Yy]$ ]]
  then
    echo 'checking git config'
    ssh -T git@github.com
fi
