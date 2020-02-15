#!/bin/sh
set -ex

USER_NAME=$1
USER_UID=$2
USER_GID=$3

# Create a non-root user to use
groupadd --gid $USER_GID $USER_NAME 
useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USER_NAME

# [Optional] Add sudo support for non-root user
apt-get install -y sudo
echo $USER_NAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USER_NAME
chmod 0440 /etc/sudoers.d/$USER_NAME

# Add user to the docker group
usermod -aG docker $USER_NAME