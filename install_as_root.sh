#!/bin/bash

echo "Update App Source ..."
apt update

echo "Install System Environment ..."
apt install -y net-tools sudo curl unzip wget

echo "Install Develop Environment ..."
apt install -y build-essential openssh-server openssh-client cmake clang-format ripgrep mysql-client subversion
apt install -y zsh git gdb tmux vim bash-completion language-pack-en language-pack-zh-hans language-pack-zh-hant
apt install -y libssl-dev libpython3-dev python3-dev python3-pip man libmysqlclient-dev libcurl4-openssl-dev

echo "Install Manual ..."
apt install -y manpages-de  manpages-de-dev  manpages-dev glibc-doc manpages-posix-dev manpages-posix manpages-zh

echo "/usr/local/lib" >> /etc/ld.so.conf.d/usr_local_lib
echo "kernel.core_pattern=core.%e.%p.%t" >> /etc/sysctl.conf
echo "*               soft    core            unlimited" >> /etc/security/limits.conf
echo "*               hard 	  core            unlimited" >> /etc/security/limits.conf
sysctl -w kernel.core_pattern=core.%e.%p.%t

echo "Install Protobuf ..."
wget https://github.com/protocolbuffers/protobuf/releases/download/v3.20.3/protobuf-all-3.20.3.zip
unzip protobuf-all-3.20.3.zip
mv protobuf-3.20.3 /usr/src/
cd /usr/src/protobuf-3.20.3 && ./configure && make && make install

# 安装wsl工具
# add-apt-repository ppa:wslutilities/wslu
# apt update
# apt upgrade
# apt install wslu
