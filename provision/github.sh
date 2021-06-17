#!/bin/bash
set +ex

for ARGUMENT in "$@"
do
    KEY=$(echo $ARGUMENT | cut -f1 -d=)
    VALUE=$(echo $ARGUMENT | cut -f2 -d=)

    case "$KEY" in
        username)
            # Setup username variable
            USER_NAME=$VALUE
            ;;
        email)
            # Setup username variable
            EMAIL=$VALUE
            ;;
        token)
            # Setup token varibale
            TOKEN=$VALUE
            ;;
        title)
            # Setup token varibale
            TITLE=$VALUE
            ;;
        *)
            echo "Invalid argument ${KEY}"
            ;;
    esac
done

# Variables
TITLE_WITH_DATE="$TITLE-$(date +%d-%b-%H-%M)"
HOST="github.com"
SSH_CONFIG_FILE="${HOME}/.ssh/config"
PRIVATE_KEY_FILE="${HOME}/.ssh/id_rsa"
PUBLIC_KEY_FILE="${HOME}/.ssh/id_rsa.pub"
GITHUB_PRIVATE_KEY_FILE="${HOME}/.ssh/id_rsa_github"
GITHUB_PUBLIC_KEY_FILE="${HOME}/.ssh/id_rsa_github.pub"



function github-authenticated() {
  # Attempt to ssh to GitHub
  ssh -T git@github.com &>/dev/null
  RET=$?
  if [ $RET == 1 ]; then
    # user is authenticated, but fails to open a shell with GitHub 
    return 0
  elif [ $RET == 255 ]; then
    # user is not authenticated
    return 1
  else
    echo "unknown exit code $RET in attempt to ssh into git@github.com"
  fi
  return 2
}

function generate-ssh-config() {
    echo "GITHUB: updating SSH config"
    # Update ssh config
    if [ -f $SSH_CONFIG_FILE ]; then
        echo "GITHUB: $SSH_CONFIG_FILE exists"
    else
        echo "GITHUB: $SSH_CONFIG_FILE doesn't exists, creating."
        touch $SSH_CONFIG_FILE
    fi

    if grep -Rq "HostName $HOST" $SSH_CONFIG_FILE; then
        echo "GITHUB: $HOST config already exists."
        return 0
    fi

    echo "" >> $SSH_CONFIG_FILE
    echo "Host $HOST" >> $SSH_CONFIG_FILE
    echo "    HostName $HOST" >> $SSH_CONFIG_FILE
    echo "    User git" >> $SSH_CONFIG_FILE
    echo "    IdentityFile $GITHUB_PRIVATE_KEY_FILE" >> $SSH_CONFIG_FILE
    echo "    IdentitiesOnly yes" >> $SSH_CONFIG_FILE
    echo "" >> $SSH_CONFIG_FILE
    echo "GITHUB: $HOST config updated."
}

function generate-ssh-keys() {
    echo "GITHUB: generating SSH keys"
    # Generate the ssh key
    ssh-keygen -t rsa -b 4096 -N '' -C "$EMAIL" -f $GITHUB_PRIVATE_KEY_FILE <<< y &>/dev/null

    # Update the ssh config
    generate-ssh-config

    # Get the content of public key
    PUBLIC_KEY=$(cat $GITHUB_PUBLIC_KEY_FILE)

    curl -s  -u "$USER_NAME:$TOKEN" -X POST -d "{\"title\":\"$TITLE_WITH_DATE\",\"key\":\"$PUBLIC_KEY\"}" \
        https://api.github.com/user/keys > /dev/null
}

echo "GITHUB: Checking if github.com is a known hosts"
ssh-keygen -H -F github.com &>/dev/null
RET=$?
if [ $RET == 1 ]; then
    # Add GitHub to known host
    ssh-keyscan -H github.com >> ~/.ssh/known_hosts
else
    echo "GITHUB: github.com is already a known host"
fi

echo "GITHUB: Checking if github can be authenticated"
if ! github-authenticated; then
    echo "GITHUB: Couldn't authenticate..."
    generate-ssh-keys
fi

# Check if ssh key pair works
if github-authenticated; then
    echo "GITHUB: SSH key pair setup successfully"
    # Git Config
    echo "GITHUB: Setting config username ${USER_NAME}"
    git config --global user.name "${USER_NAME}"
    echo "GITHUB: Setting config email ${EMAIL}"
    git config --global user.email "${EMAIL}"
    exit 0
else
    echo "GITHUB: Some problem in SSH key pair generation, please check logs"
    exit 1
fi
