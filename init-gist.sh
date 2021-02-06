#!/bin/bash

# Simple Alert Function
alert () {
	tput bold; tput setaf 11; echo "$1"; tput sgr0;
}


# ==============================================================================
#   START SETUP
#   Creates new SSH key, copies it to Github, and clones private config repo.
# ==============================================================================

# Might as well ask for password up-front, right?
sudo -v

# Keep-alive: update existing sudo time stamp if set, otherwise do nothing.
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Include configuration file
test -f ~/.setup && . $_

# NOTE: Homebrew automatically installs XCode, without any prompts. Git requires this.
if [[ ! $(which brew) ]]; then
	alert "Installing Homebrew..."
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
		brew cleanup
		brew doctor
fi

if [[ ! -d ~/.ssh ]]; then
	ssh_title="$(scutil --get ComputerName) ($(date +'%Y-%m-%d'))"

	alert "Creating New SSH Key"
		ssh-keygen -f ~/.ssh/$ssh_file -t rsa -b 4096 -C $git_email -P ""
	    echo -e "Host *\n AddKeysToAgent yes\n UseKeychain yes\n IdentityFile ~/.ssh/$ssh_file" >> ~/.ssh/config
		ssh-add -K ~/.ssh/$ssh_file

	ssh_key="$(cat ~/.ssh/$ssh_file.pub)"

	alert "Adding SSH Key to GitHub"
		curl -u "$github_user:$github_pwd" --data '{"title": "'"$ssh_title"'", "key":"'"$(cat ~/.ssh/$ssh_file.pub)"'"}' https://api.github.com/user/keys

		curl -i -u "$github_user:$github_token" -X POST -H "Accept: application/vnd.github.v3+json" https://api.github.com/user/keys -d '{"title": "'"$ssh_title"'", "key":"'"$ssh_key"'"}'

		alert "Testing your connection to Github"
		ssh -T git@github.com

	alert "Uploading SSH Key to Your Webhost"
	    cat ~/.ssh/$ssh_file.pub | ssh $ssh_user@$ssh_host "test -d ~/.ssh || mkdir ~/.ssh; cat >> ~/.ssh/authorized_keys"
fi

if [[ ! -d $sites/config ]]; then
	alert "Cloning Config Repo"
		test ! -d $sites && sudo mkdir $_ && sudo chown -R $USER $_
		git clone "$setup_repo" $sites/config
		echo "Add to Github Desktop: github $sites/config"
fi

echo
alert "Please run the following scripts to finish the initial setup:"
echo "$install/bash-config.sh"
