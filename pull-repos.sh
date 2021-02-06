#!/bin/bash
. ~/.bash_profile

if [ ! -d "$sites" ]; then
    sudo mkdir $sites && sudo chown -R $USER:staff $sites
    echo -e "${green}Created a new $sites folder.${c}"
fi

cat data/repos.txt | while read repo; do
    if collaborator $repo -eq 0; then
        filename=$(basename $repo .git)
        git clone $repo $sites/$filename
        github $sites/$filename
    else
        alert -t danger "Permission denied for $repo. Are you a collaborator?"
    fi
done
