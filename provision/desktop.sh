#!/bin/sh
set -ex

# https://askubuntu.com/questions/1067929/on-18-04-package-virtualbox-guest-utils-does-not-exist
apt-add-repository -y multiverse
# Update package index
apt-get update

# Set password for default "ubuntu" user
echo "ubuntu:ubuntu" | chpasswd

# Install xfce and virtualbox additions.
# (Not sure if these packages could be helpful as well: virtualbox-guest-utils-hwe virtualbox-guest-x11-hwe)
apt-get install -y xfce4 virtualbox-guest-dkms virtualbox-guest-utils virtualbox-guest-x11
# Permit anyone to start the GUI
# TODO - needed?
#sed -i 's/allowed_users=.*$/allowed_users=anybody/' /etc/X11/Xwrapper.config

# Optional: Use LightDM login screen (-> not required to run "startx")
apt-get install -y lightdm lightdm-gtk-greeter
# Optional: Install a more feature-rich applications menu
apt-get install -y xfce4-whiskermenu-plugin