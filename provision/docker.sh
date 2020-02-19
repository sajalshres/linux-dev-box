#!/bin/sh
set -ex

# Add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
# Add Docker's stable repository
add-apt-repository -y \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable"
# Update package index
apt-get update
# Install latest version of Docker Engine - Community and containerd
apt-get -y install docker-ce docker-ce-cli containerd.io
# Install docker-compose
curl -L "https://github.com/docker/compose/releases/download/1.25.3/docker-compose-$(uname -s)-$(uname -m)" \
    -o /usr/local/bin/docker-compose -s
# Apply executable permissions to the binary
chmod +x /usr/local/bin/docker-compose
