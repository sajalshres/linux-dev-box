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
PRIVATE_KEY_FILE="${HOME}/.ssh/id_rsa"
PUBLIC_KEY_FILE="${HOME}/.ssh/id_rsa.pub"



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

function generate-ssh-keys() {
    # Generate the ssh key
    ssh-keygen -t rsa -b 4096 -N '' -C "$EMAIL" -f ~/.ssh/id_rsa <<< y

    # Add the ssh key to ssh-agent
    # ssh-add ~/.ssh/id_rsa

    # Get the content of public key
    PUBLIC_KEY=`cat ~/.ssh/id_rsa.pub`

    curl -s  -u "$USER_NAME:$TOKEN" -X POST -d "{\"title\":\"$TITLE\",\"key\":\"$PUBLIC_KEY\"}" \
        https://api.github.com/user/keys > /dev/null
}

echo "GIT: Checking if github.com is a known hosts"
ssh-keygen -H -F github.com
RET=$?
if [ $RET == 1 ]; then
    # Add GitHub to known host
    ssh-keyscan -H github.com >> ~/.ssh/known_hosts
else
    echo "GIT: github.com is already a known host"
fi


if [ ! -f "${PRIVATE_KEY_FILE}" ] && [ ! -f "${PUBLIC_KEY_FILE}" ]; then
    # SSH key pair doesnot exists
    echo "GIT: ${PRIVATE_KEY_FILE} and ${PUBLIC_KEY_FILE} does not exists"
    echo "GIT: Generating new ssh key pair"
    generate-ssh-keys
else
    # SSH Key pair exists
    # Check if the key works
    echo "GIT: ${PRIVATE_KEY_FILE} and ${PUBLIC_KEY_FILE} already exists"
    echo "GIT: Checking is github can be authenticated"
    if ! github-authenticated; then
        # Existing key is not working, generate again.
        echo "GIT: Couldn't authenticate with existing, generating new one"
        generate-ssh-keys
    fi
fi

# Check if ssh key pair works
if github-authenticated; then
    echo "GIT: SSH key pair setup successfully"
    exit 0
else
    echo "GIT: Some problem in SSH key pair generation, please check logs"
    exit 1
fi