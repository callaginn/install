#!/bin/bash

test -f $HOME/.setup && . $_

echo "This script symlinks your bash settings and sets up your git config."

# WARNING: These commands will overwrite your .bash_profile and .gitconfig.
# They assume this is a new user that doesn't need to backup settings.

echo "Symlinking dotfiles..."
cd $sites/config/dotfiles && for f in $(ls -d .??*); do ln -sf $PWD/$f ~/$f; done

# alert "Installing Stephen's Symlinker..."
cp -r $sites/config/install/data/symlinker.workflow ~/Library/Services/symlinker.workflow

# Configure Git...
# Customize Name and Email here...since config files are using my info by default
# However, this will prevent the git repo from staying in sync.

rm -rf ~/.gitconfig
cp -r $sites/config/install/data/.gitconfig ~/.gitconfig

if [[ ! $(git config --global user.name) ]]; then
    input "First and Last Name" git_name
    test $setup_git == "true" && git config --global user.name "$git_name"
fi

if [[ ! $(git config --global user.email) ]]; then
    input "Git Email" git_email
    test $setup_git == "true" && git config --global user.email "$git_email"
fi

# This install requires you to update to the latest version of bash
echo "Updating Bash..."
    brew install bash
    brew link bash
    echo '/usr/local/bin/bash' | sudo tee -a /etc/shells
    chsh -s /usr/local/bin/bash "$USER"

# Latest copy of ruby is needed for ColorLS
echo "Updating Ruby..."
    brew install ruby

# Update bash profile
. ~/.bash_profile

alert "Please restart your terminal, since we made changes to your default shell"
