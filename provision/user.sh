#!/bin/sh
set -ex

for ARGUMENT in "$@"
do
    KEY=$(echo $ARGUMENT | cut -f1 -d=)
    VALUE=$(echo $ARGUMENT | cut -f2 -d=)

    case "$KEY" in
        user)
            # Setup user variable
            USER_NAME=$VALUE
            ;;
        uid)
            # Setup user id variable
            USER_UID=$VALUE
            ;;
        gid)
            # Setup group id variable
            USER_GID=$VALUE
            ;;
        *)
            echo "Invalid argument ${KEY}"
            ;;
    esac
done

if [ ! $(getent passwd $USER_NAME) ] ; then
    # Create a non-root user to use
    groupadd --gid $USER_GID $USER_NAME 
    useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USER_NAME
    
    # [Optional] Add sudo support for non-root user
    apt-get install -y sudo
    echo $USER_NAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USER_NAME
    chmod 0440 /etc/sudoers.d/$USER_NAME

    # Create docker group if not exist
    if [ ! $(getent group docker) ]; then
        groupadd docker
    fi
    
    # Add user to the docker group
    usermod -aG docker $USER_NAME
fi
