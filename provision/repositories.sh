#!/bin/bash
set +ex

LOCATION="${HOME}/Git"
REPOSITORIES=("$@")

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
    echo "REPOSITORY: unknown exit code in attempt to ssh into git@github.com"
  fi
  return 2
}

# check if location exists
if [ ! -d $LOCATION ]; then
    echo "${LOCATION} doesn't exist, creating one..."
    mkdir -p $LOCATION
    chown $USER:$USER $LOCATION
fi

# check if git is authenticated.
echo "REPOSITORY: Checking GitHub access..."
if github-authenticated; then
    echo "REPOSITORY: GitHub access successful"
    for repository in "${REPOSITORIES[@]}"
    do
        echo "REPOSITORY: Cloning $repository"
        repo_name=`basename "${repository%.*}"`
        repo_location="${LOCATION}/${repo_name}"
        if [ ! -d $repo_location ]; then
          cd $LOCATION
          git clone $repository
        else
          echo "REPOSITORY: Repo ${repo_name} already exist's in ${LOCATION}, skipping..."
        fi
    done
else
 echo "REPOSITORY: Couldn't authenticate with Github, Please check your keys manually."
fi
