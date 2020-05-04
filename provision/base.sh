#!/bin/sh
set -ex
# Update locale
sudo locale-gen en_US.UTF-8
sudo update-locale LANG=en_US.UTF-8
# Update package index
apt-get update
# Allow apt to use repository over HTTPS
apt-get -y install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
# Install networking toolkit: ifconfig, netstat etc.
apt-get -y install net-tools
# Install telnet
apt-get -y install xinetd telnetd
# Install vim
apt-get -y install vim
# Install firefox
apt-get -y install firefox
# Install chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -P /tmp
apt install /tmp/google-chrome-stable_current_amd64.deb