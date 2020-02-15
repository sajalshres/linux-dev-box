#!/bin/sh
set -ex

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