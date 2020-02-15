#!/bin/sh
set -ex

# Install Node.js
curl -sL https://deb.nodesource.com/setup_13.x | bash -
apt-get install -y nodejs
# Install eslint
npm install -g eslint