#!/bin/sh
set -ex


for ARGUMENT in "$@"
do

    KEY=$(echo $ARGUMENT | cut -f1 -d=)
    VALUE=$(echo $ARGUMENT | cut -f2 -d=)
    echo "Key is ${KEY}"

    case "$KEY" in
            python)
                echo "Repository setup for ${KEY}"
                # Add Python Ubuntu repository
                add-apt-repository -y ppa:deadsnakes/ppa
                ;;
            docker)
                echo "Repository setup for ${KEY}"
                # Add Docker’s official GPG key
                curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
                # Add Docker's stable repository
                add-apt-repository -y \
                    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
                    $(lsb_release -cs) \
                    stable"
                ;;
            web-development)
                echo "Repository setup for ${KEY}"
                # Add NodeJS repository
                curl -sL https://deb.nodesource.com/setup_13.x | bash -
                ;;
            desktop)
                echo "Repository setup for ${KEY}"
                # https://askubuntu.com/questions/1067929/on-18-04-package-virtualbox-guest-utils-does-not-exist
                apt-add-repository -y multiverse
                ;;
            *)
                echo "Repository settings not found for ${KEY}"
                ;;
    esac
done
