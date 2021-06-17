#!/bin/bash
set +ex

for ARGUMENT in "$@"
do
    KEY=$(echo $ARGUMENT | cut -f1 -d=)
    VALUE=$(echo $ARGUMENT | cut -f2 -d=)

    case "$KEY" in
        host)
            # Setup hostname variable
            HOST=$VALUE
            ;;
        port)
            # Setup port variable
            PORT=$VALUE
            ;;
        username)
            # Setup username variable
            USER_NAME=$VALUE
            ;;
        password)
            # Setup password variable
            PASSWORD=$VALUE
            ;;
        email)
            # Setup email variable
            EMAIL=$VALUE
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
SSH_CONFIG_FILE="${HOME}/.ssh/config"
PRIVATE_KEY_FILE="${HOME}/.ssh/id_rsa"
PUBLIC_KEY_FILE="${HOME}/.ssh/id_rsa.pub"
BITBUCKET_PRIVATE_KEY_FILE="${HOME}/.ssh/id_rsa_bitbucket"
BITBUCKET_PUBLIC_KEY_FILE="${HOME}/.ssh/id_rsa_bitbucket.pub"

function bitbucket-authenticated() {
    TMP_FILE="/tmp/bitbucket_authentication_output.txt"
    STATUS=0
    # Attempt to ssh to bitbucket
    ssh -vT "git@$HOST" -p $PORT &> $TMP_FILE
    
    if grep -Rq 'Authentication succeeded' $TMP_FILE; then
        STATUS=0
    else
        STATUS=1
    fi

    rm -f $TMP_FILE

    return $STATUS
}

function generate-ssh-config() {
    echo "BITBUCKET: updating SSH config"
    # Update ssh config
    if [ -f $SSH_CONFIG_FILE ]; then
        echo "BITBUCKET: ssh config $SSH_CONFIG_FILE file already exists"
    else
        echo "BITBUCKET: $SSH_CONFIG_FILE doesn't exists, creating."
        touch $SSH_CONFIG_FILE
    fi

    if grep -Rq "HostName $HOST" $SSH_CONFIG_FILE; then
        echo "BITBUCKET: $HOST config already exists."
        return 0
    fi

    echo "" >> $SSH_CONFIG_FILE
    echo "Host $HOST" >> $SSH_CONFIG_FILE
    echo "    HostName $HOST" >> $SSH_CONFIG_FILE
    echo "    User git" >> $SSH_CONFIG_FILE
    echo "    Port $PORT" >> $SSH_CONFIG_FILE
    echo "    IdentityFile $BITBUCKET_PRIVATE_KEY_FILE" >> $SSH_CONFIG_FILE
    echo "    IdentitiesOnly yes" >> $SSH_CONFIG_FILE
    echo "" >> $SSH_CONFIG_FILE
    echo "BITBUCKET: $HOST config updated."
}

function generate-ssh-keys() {
    echo "BITBUCKET: generating SSH keys"
    # Generate the ssh key
    ssh-keygen -t rsa -b 4096 -N '' -C "$EMAIL" -f $BITBUCKET_PRIVATE_KEY_FILE <<< y &>/dev/null

    # Update the ssh config
    generate-ssh-config

    # Get the content of public key
    PUBLIC_KEY=$(cat $BITBUCKET_PUBLIC_KEY_FILE)

    # Post the key to bitbucket cloud/server
    curl -s -H "Authorization: Basic $(echo -n "$USER_NAME:$PASSWORD" | base64)" \
        -H "Content-Type: application/json" \
        -X POST "https://$HOST/rest/ssh/latest/keys" \
        -d "{\"text\":\"$PUBLIC_KEY\",\"label\":\"$TITLE_WITH_DATE\"}" $>/dev/null
}

echo "BITBUCKET: Checking if $HOST is a known hosts"
ssh-keygen -H -F $HOST &>/dev/null
RET=$?
if [ $RET == 1 ]; then
    # Add bitbucket to known host
    ssh-keyscan -p $PORT -H $HOST >> ~/.ssh/known_hosts
    dig -t a +short $HOST | grep ^[0-9] | xargs -r -n1 ssh-keyscan -H -p 7999 >> ~/.ssh/known_hosts
else
    echo "BITBUCKET: $HOST is already a known host"
fi

echo "BITBUCKET: Checking if bitbucket can be authenticated"
if ! bitbucket-authenticated; then
    echo "BITBUCKET: Couldn't authenticate..."
    generate-ssh-keys
fi

# Check if ssh key pair works
if bitbucket-authenticated; then
    echo "BITBUCKET: SSH key pair setup successfully"
    # Git Config
    echo "BITBUCKET: Setting config username ${USER_NAME}"
    git config --global user.name "${USER_NAME}"
    echo "BITBUCKET: Setting config email ${EMAIL}"
    git config --global user.email "${EMAIL}"
    exit 0
else
    echo "BITBUCKET: Some problem in SSH key pair generation, please check logs"
    exit 1
fi
