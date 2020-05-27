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

# Install nvm as default vagrant user
runuser -l vagrant -c "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash"
