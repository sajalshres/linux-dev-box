#!/bin/sh
set -ex

# Add NodeJS repository
curl -sL https://deb.nodesource.com/setup_13.x | bash -
# Update package index
apt-get update
# Install Node.js
apt-get install -y nodejs
# Install eslint
npm install -g eslint