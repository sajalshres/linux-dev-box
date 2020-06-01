#!/bin/bash
set -ex

echo "$@"
for ARGUMENT in "$@"
do
    echo "Argument is ${ARGUMENT}"
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
    echo "unknown exit code in attempt to ssh into git@github.com"
  fi
  return 2
}

function generate-ssh-keys() {
    # Generate the ssh key
    ssh-keygen -t rsa -b 4096 -N '' -C "$EMAIL" -f ~/.ssh/id_rsa <<< y

    # Add the ssh key to ssh-agent
    # ssh-add ~/.ssh/id_rsa

    # Add GitHub to known host
    ssh-keyscan -H github.com >> ~/.ssh/known_hosts

    # Get the content of public key
    PUBLIC_KEY=`cat ~/.ssh/id_rsa.pub`

    curl -s  -u "$USER_NAME:$TOKEN" -X POST -d "{\"title\":\"`hostname`\",\"key\":\"$PUBLIC_KEY\"}" \
        https://api.github.com/user/keys > /dev/null
}

if [ ! -f "${PRIVATE_KEY_FILE}" ] && [ ! -f "${PUBLIC_KEY_FILE}" ]; then
    # SSH key pair doesnot exists
    generate-ssh-keys
else
    # SSH Key pair exists
    # Check if the key works
    if ! github-authenticated; then
        # Existing key is not working, generate again.
        generate-ssh-keys
    fi
fi

# Check if ssh key pair works
if github-authenticated; then
    echo "SSH key pair generated and validated successfully"
else
    echo "Some problem in SSH key pair generation, please check logs"
    exit 1
fi