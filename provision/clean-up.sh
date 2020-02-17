#!/bin/sh
set -ex

# Clean up dependencies no longer needed
apt-get autoremove -y
# Clean up cache
apt-get clean -y
# Clean up temp files ffrom package manager
rm -rf /var/lib/apt/lists/*
# Clean up pip bootstrap file
rm -rf /tmp/get-pip.py
# Restart
shutdown -r now