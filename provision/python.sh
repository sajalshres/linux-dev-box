#!/bin/sh
set -ex

# Add Python Ubuntu repository
add-apt-repository -y ppa:deadsnakes/ppa
# Update package index
apt-get update
# Install Python
apt-get -y install python3.7
# Install pip
curl https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py -s
python3.7 /tmp/get-pip.py
# Install base Python packages
pip3.7 install virtualenv