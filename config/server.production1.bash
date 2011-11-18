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

cp support-files/mysql.server /etc/init.d/mysql.server

sudo apt-get install -y mysql-client libmysqlclient16-dev libmysqlclient16 libmysql-ruby libmysqlclient-dev

git config --global user.name "Nom Production"
git config --global user.email "deployer@justnom.it"
git config --global github.user bnorton
git config --global github.token a97228eb813ef5b0734ebc3dee4ce5e5

sudo mkdir ~/.ssh
cat > ~/.ssh/id_rsa <<ID_RSA
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEA8U534rcKwr/HzPp7rFHDCNlsoeik3en2TROkdyrIwpCpCU4B
vFps+f/J/0Rkorjimw4XmvSc5xju8Jd0ZJqp4p+pOlHyvTvmxvEYeiICcaLkeVFC
YavidCEc+4NdHP/3S7zdIMPksGQ/NkjNiW01xDlqXwoCjaZUK7XBgXviQ0N5/Ahx
L1oQHGmIM8LQY7lAemreTaakKCSSc+gWnawz/mCsEChsHBUblhgQk++iII+JU2k7
+/oSkPNnR3FuHdJQAH3AUnno0eGmnkglzT0pimzRNwpMB/NqL3Fn49NYfwT1uCm0
DLB3xLOIeZofVnc/c2QZ3u2ESmSIw5j/EKKXTwIDAQABAoIBADSmFTwvCbcCFvrf
L/qiADa/EZel5crRUD7y6TBi8liZLXhtP62z4REOwSjj6D0kr7R696WEd3NomkF+
GhQVNrnOciLaXGbzWd/QHLIRF41pqAXcN+qNkSQbUXKC797y7iblNy3977iYtr4G
VmoEnPWKPW4tBe+X+cdrqaOxvuVDuDOLqbbT+D0538rpomrUsryYuCpVoFS0nSVy
9fCl+p8ubz2dENttH6/PhIr8ZEDyiWoSX6JJpfer6AsAWtpvAWfkPlo/M1dBxha2
nNIEVeLRA5GNgcOhiva1WrOixTcfERkSPrpUeTUQiQIqRRABtzs6AMAi1OOgdOgf
EUw0sckCgYEA+5oa2R52xMV9e9vb3IOUezzGF21imLd75Po2OA6OmYQqx69qR221
sh5ENAGgMRy3yieEjvhvqkd+OzR1E1sFwhsPp/w+TWPMxlg3LZQa+R4sV4gxEk2g
wkl4nQ60bLzVb+yofFEP4QnzVINlzj6Fks5NbcEKPqkVK033mfSILR0CgYEA9YZK
z+XRbPDMoKQAbFbAUpCHK0JYFaOYTHlRIW9f2+AdiTaTKrSszl9eMchO2KtZqjax
WinG87HRjv3oCW4HeiH8R3MeczFnsNbIzz/BR7HKTmsZ1UBzA7PD4W08smXstBKX
wvmRvL8fsrkKojoAC+jdz8uu3lHQHc2AJBR1ZlsCgYEAjYA7/UQO09emHRSncDto
NG8XkXFpdC4tNbgq6hf1xwz36loTUZy4BTbUcNNBPp3CF6Vl/epnEsMmkTGNbpdQ
g7wob/eDKo8oSZyvW6jiCp0XnxrvTjXuZZZgiSQOAOGqwEm+8Du+zHeGLE/B3951
zPzNux5IHrmFOFefGyzVsVkCgYAmj6nuTwT+XC93R2q9mT5peUOResEE3QXNdPxW
CP0ANonNBCJHActmOjo8DV68zuStRBvEsm0J1zK3h49K89n+x5msyxrMMsU7U/CE
BFph3T2N5WpQQOgPe8tW+2YeCr4LZiQpvjKydz4OPtu5sOxS8obr3OyhBC5wj9cB
U6lAowKBgQC+UnMjZXT1/lovR5uqTGQcnPHnHQq79mqj5Kf212Wp1iF2vBv3LZCw
L7PaaevRcwsmJfyW3Ex2YAY4Uc/eb/c2IGza6mHZxVQk2Vus+Cu+r13THyueyWcA
Upiibnn0anHDNv5sbELbrf1fNV6T6OkL1NJaKDR7hHWnOsNurJxgzw==
-----END RSA PRIVATE KEY-----
ID_RSA

cat > ~/.ssh/id_rsa.pub <<ID_RSA_PUB
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDxTnfitwrCv8fM+nusUcMI2Wyh6KTd6fZNE6R3KsjCkKkJTgG8Wmz5/8n/RGSiuOKbDhea9JznGO7wl3Rkmqnin6k6UfK9O+bG8Rh6IgJxouR5UUJhq+J0IRz7g10c//dLvN0gw+SwZD82SM2JbTXEOWpfCgKNplQrtcGBe+JDQ3n8CHEvWhAcaYgzwtBjuUB6at5NpqQoJJJz6BadrDP+YKwQKGwcFRuWGBCT76Igj4lTaTv7+hKQ82dHcW4d0lAAfcBSeejR4aaeSCXNPSmKbNE3CkwH82ovcWfj01h/BPW4KbQMsHfEs4h5mh9Wdz9zZBne7YRKZIjDmP8QopdP brian.nort@gmail.com
ID_RSA_PUB

cat > ~/.ssh/authorized_keys <<AUTH
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCQxUAAvFjYWQ3BRlvuAkamL/aeSxraa8w6IuSakjBYnHcg4PmSxDF2Hxlnaq26LUUxm3aLOZdQsgsppmZuWcCopHcwsujLLlfDzUOzWmvvtyKG4Ubq45Uc8jHHGaGF1ObZOxALAvHKenBrzU9DG29FmJX0TwrIZySKOqKdTbExvR2R4kt204cN18sTsOi8CjBd3Ba+PA0W0TQS5sDi7KAuaY35HzXt+j3Ljrho2p6Qus+QHtuIVnLnQTNBab3/dQ0guosjEgU+lLmwJbT4GonvM9S2VQ25d0xqvXARgUMn4QMAwYaiDqtBumH65AaDfgvad5v6J73StCkx6FUEBTST bnorton_10-4_32bit_server
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDxTnfitwrCv8fM+nusUcMI2Wyh6KTd6fZNE6R3KsjCkKkJTgG8Wmz5/8n/RGSiuOKbDhea9JznGO7wl3Rkmqnin6k6UfK9O+bG8Rh6IgJxouR5UUJhq+J0IRz7g10c//dLvN0gw+SwZD82SM2JbTXEOWpfCgKNplQrtcGBe+JDQ3n8CHEvWhAcaYgzwtBjuUB6at5NpqQoJJJz6BadrDP+YKwQKGwcFRuWGBCT76Igj4lTaTv7+hKQ82dHcW4d0lAAfcBSeejR4aaeSCXNPSmKbNE3CkwH82ovcWfj01h/BPW4KbQMsHfEs4h5mh9Wdz9zZBne7YRKZIjDmP8QopdP brian.nort@gmail.com
AUTH

cat > ~/.ssh/known_hosts <<KNOWN
github.com,207.97.227.239 ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==
|1|EkdpYNUylA9W9SipZJrNw8m3kps=|lw6SOxc2Hgw5Wg0IKK9tUDMsWqk= ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==
|1|vN+zFVFo3PuK1okybPzEuiA3bFg=|veNWwSfP5t6xJTBdv/H5pbOUvKU= ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==
KNOWN

cat > ~/.ssh/environment <<ENV
SSH_AUTH_SOCK=/tmp/ssh-ICqeeMAh3658/agent.3658; export SSH_AUTH_SOCK;
SSH_AGENT_PID=3660; export SSH_AGENT_PID;
ENV

chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_rsa
chmod 600 ~/.ssh/authorized_keys

cd ~/; git clone git@github.com:bnorton/nom_it.git

sudo mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.original
sudo mkdir -p /var /var/log /var/log/nginx/


sudo cp ~/nom_it/config/nginx.conf.sample /etc/nginx/nginx.conf
sudo cp ~/nom_it/config/my.cnf.sample /etc/my.cnf

cd ~/src

wget http://fastdl.mongodb.org/linux/mongodb-linux-x86_64-2.0.1.tgz
tar -xzf mongodb-linux-x86_64-2.0.1.tgz
sudo cp mongodb-linux-x86_64-2.0.1/bin/* /usr/bin/

sudo mkdir /data && sudo mkdir -p /data/db && sudo mkdir -p /log && sudo mkdir -p /log/mongodb
sudo touch /log/mongodb/production.log

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
