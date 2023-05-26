#!/bin/bash

echo "Update App Source ..."
apt update

echo "Install System Environment ..."
apt install -y net-tools sudo curl unzip wget

echo "Install Develop Environment ..."
apt install -y build-essential openssh-server openssh-client cmake clang-format ripgrep
apt install -y zsh git gdb tmux vim bash-completion language-pack-en language-pack-zh-hans language-pack-zh-hant
apt install -y libssl-dev libpython3-dev python3-dev man libmysqlclient-dev libcurl4-openssl-dev

echo "Install Manual ..."
apt install -y manpages-de  manpages-de-dev  manpages-dev glibc-doc manpages-posix-dev manpages-posix manpages-zh

echo "/usr/local/lib" >> /etc/ld.so.conf.d/usr_local_lib
echo "kernel.core_pattern=core.%e.%p.%t" >> /etc/sysctl.conf
echo "*               soft    core            unlimited" >> /etc/security/limits.conf
echo "*               hard 	  core            unlimited" >> /etc/security/limits.conf
sysctl -w kernel.core_pattern=core.%e.%p.%t

echo "Install YouCompleteMe ..."
git clone https://github.com/ycm-core/YouCompleteMe.git /usr/src/YouCompleteMe
cd /usr/src/YouCompleteMe && git submodule update --init --recursive && ./install.py  --clangd-completer

echo "Install Protobuf ..."
wget https://github.com/protocolbuffers/protobuf/releases/download/v3.19.4/protobuf-all-3.19.4.zip
unzip protobuf-all-3.19.4.zip
mv protobuf-3.19.4 /usr/src/
cd /usr/src/protobuf-3.19.4 && ./configure && make && make install

# 安装wsl工具
# add-apt-repository ppa:wslutilities/wslu
# apt update
# apt upgrade
# apt install wslu
