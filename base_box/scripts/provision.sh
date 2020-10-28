#!/bin/sh
set +ex

# Update locale
sudo locale-gen en_US.UTF-8
sudo update-locale LANG=en_US.UTF-8

# Configure apt and install packages
apt-get update
#
# Add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
#
# Add Docker's stable repository
add-apt-repository -y \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable"
#
# Add Python Ubuntu repository
add-apt-repository -y ppa:deadsnakes/ppa
#
# Add NodeJS repository
curl -sL https://deb.nodesource.com/setup_14.x | bash -
#
# Update package index after adding repositories
apt-get update
#
# Install common packages
apt-get -y install --no-install-recommends apt-transport-https ca-certificates curl gnupg-agent software-properties-common
#
# Install networking toolkit: ifconfig, netstat, telnet etc.
apt-get -y install net-tools xinetd telnetd
#
# Install audio
apt install -y pulseaudio
systemctl --user enable pulseaudio
#
# Install vim
apt-get -y install vim
#
# Install firefox
apt-get -y install firefox
#
# Install chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -P /tmp
apt install -y /tmp/google-chrome-stable_current_amd64.deb
#
# Install latest version of Docker Engine - Community and containerd
apt-get -y install docker-ce docker-ce-cli containerd.io
#
# Install docker-compose
curl -L "https://github.com/docker/compose/releases/download/1.25.3/docker-compose-$(uname -s)-$(uname -m)" \
    -o /usr/local/bin/docker-compose -s
chmod +x /usr/local/bin/docker-compose
usermod -aG docker vagrant
#
# Install python and pip
apt-get -y install python3.7
curl https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py -s
python3.7 /tmp/get-pip.py
rm -f /tmp/get-pip.py
pip3.7 install virtualenv
#
# Update default python to 3.7
rm -f /usr/bin/python
ln -s /usr/bin/python3.7 /usr/bin/python
#
# Install Node.js
apt-get -y install nodejs
#
# npm global default directory to default user
runuser -l vagrant -c "mkdir ~/.npm-global"
runuser -l vagrant -c "npm config set prefix '~/.npm-global'"
runuser -l vagrant -c "echo '' >> ~/.profile"
runuser -l vagrant -c "echo '# npm global added to path' >> ~/.profile"
runuser -l vagrant -c "echo 'export PATH=~/.npm-global/bin:\$PATH' >> ~/.profile"
#
# Install npm packages
npm install -g eslint webpack webpack-cli
#
# Install nvm as default vagrant user
runuser -l vagrant -c "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash"
#
# Install viber
#If you try to install Viber on Debian 9 you will probably get the following error:
# dpkg: dependency problems prevent configuration of viber: viber depends on libssl1.0.0; however: Package libssl1.0.0 is not installed.
# This is cause because libssl1.0.0 is not installed be default and is no longer available through the repos.
wget http://security.debian.org/debian-security/pool/updates/main/o/openssl/libssl1.0.0_1.0.1t-1+deb8u12_amd64.deb -P /tmp
apt install -y /tmp/libssl1.0.0_1.0.1t-1+deb8u12_amd64.deb
wget https://download.cdn.viber.com/cdn/desktop/Linux/viber.deb -P /tmp
apt install -y /tmp/viber.deb
#
# Increase amount of inotify watches
echo '' >> /etc/sysctl.conf
echo '# Inotify watches for larger workspace' >> /etc/sysctl.conf
echo 'fs.inotify.max_user_watches=524288' >> /etc/sysctl.conf
echo '' >> /etc/sysctl.conf
sysctl -p
#
# Install Desktop environment
apt -y install kde-plasma-desktop
#
# Clean up
apt-get autoremove -y
apt-get clean -y
rm -rf /var/lib/apt/lists/*
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY
cat /dev/null > ~/.bash_history 
history -c
#
# Exit
exit 0
