#!/bin/bash
set +ex

LOCATION="${HOME}/Git"
REPOSITORIES=("$@")

# check if location exists
if [ ! -d $LOCATION ]; then
    echo "${LOCATION} doesn't exist, creating one..."
    mkdir -p $LOCATION
    chown $USER:$USER $LOCATION
fi

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