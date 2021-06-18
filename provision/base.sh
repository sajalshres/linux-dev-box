#!/bin/bash
set +ex

for ARGUMENT in "$@"
do
    KEY=$(echo $ARGUMENT | cut -f1 -d=)
    VALUE=$(echo $ARGUMENT | cut -f2 -d=)

    case "$KEY" in
        timezone)
            # Setup hostname variable
            TIMEZONE=$VALUE
            ;;
        git_username)
            # Setup hostname variable
            GIT_USERNAME=$VALUE
            ;;
        git_email)
            # Setup hostname variable
            GIT_EMAIL=$VALUE
            ;;
        *)
            echo "Invalid argument ${KEY}"
            ;;
    esac
done

echo "BASE: setting timezone to $TIMEZONE"
sudo timedatectl set-timezone $TIMEZONE

# Git Config
echo "BASE: Setting git config username ${GIT_USERNAME}"
git config --global user.name "${GIT_USERNAME}"
echo "BASE: Setting git config email ${GIT_EMAIL}"
git config --global user.email "${GIT_EMAIL}"
