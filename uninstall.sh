#!/bin/bash

if [[ $# -eq 0 ]]; then
    echo "Usage: ./uninstall.sh server brews homebrew npm apm bash"
else
	test -f $HOME/.setup && . $_
	test -f bin/common.sh && . $_

	# Might as well ask for password up-front, right?
	sudo -v

	# Keep-alive: update existing sudo time stamp if set, otherwise do nothing.
	while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
fi

reset_bash () {
	# Deleting Symlinks
	echo "Archiving Bash Symlinks..."

	names=(
		.atom
		.aliases
		.bash_profile
		.gitconfig
		.gitignore_global
		.iterm2_shell_integration.bash
		.variables
		.zshrc
	)

	mkdir -p "$backupDir"

	for name in ${names[@]}; do
		[ -f "$HOME/$name" ] && mv "$HOME/$name" "$backupDir/"
	done

	# Archive Atom Config
	apm list --installed --bare > "$backupDir/atom-packages.txt"
}

remove_npm () {
	mkdir -p "$backupDir"
	npm ls -g > "$backupDir/npm.txt" && echo "Backed up NPM modules to $backupDir/npm.txt" || echo "NPM Backup Failed!"
	npm ls -gp --depth=0 | awk -F/ '/node_modules/ && !/\/npm$/ {print $NF}' | xargs npm -g rm
	sudo rm -rf /usr/local/{lib/node{,/.npm,_modules},bin,share/man}/{npm*,node*,man1/node*}

    # Revert back to default shell
    chsh -s /bin/bash

    # Uninstall NVM
    rm -rf ~/.nvm
    rm -rf ~/.npm
    rm -rf ~/.bower
    rm -rf ~/.v8flags.*.json
    rm -rf ~/.node-gyp
    rm -rf ~/.node_repl_history
}

server_backup () {
	# Archive the /usr/local folder, since it doesn't exist on a clean install.
	# Note: Huge databases are stored in /usr/local/var/mysql
	alert "Saving Hombrew Config..."
	mkdir -p "$backupDir"
	brew list --formula > "$backupDir/brew.txt"

	# We can safely archive the user's previous "httpd" folder,
	# since Homebrew recreates it when "httpd" is reinstalled:
	mv "/usr/local/etc/httpd" "$backupDir/httpd"
}

uninstall_server () {
	server stop
	sudo killall httpd # make sure it really stops!
	server_backup

	#sudo apachectl stop;
	#sudo launchctl unload -w /System/Library/LaunchDaemons/org.apache.httpd.plist 2>/dev/null;
	#sudo pkill -f /usr/local/Cellar/httpd24;
	#sudo pkill -f /usr/sbin/httpd;
	#brew unlink httpd;

	alert "Uninstalling Dependencies..."
		brew uninstall openldap libiconv

	alert "Uninstalling Apache..."
	    brew uninstall httpd;
	    brew uninstall --ignore-dependencies --force httpd;
	    brew rm httpd;
	    sudo rm -rf /usr/local/Cellar/httpd
	    brew doctor;
	    brew update;

		# I "think" we can technically do this:
		mv /usr/local/etc/httpd /usr/local/etc/_httpd
		# /usr/local/etc/httpd/httpd.conf # need to make sure this file gets removed...

	alert "Uninstalling PHP..."
	    brew list --formula | grep "php@" | while read ver; do
	        brew uninstall $ver
	    done

		brew uninstall php
		# brew uninstall curl-openssl?

	    sudo rm -rf /usr/local/etc/php

	    echo "Removing PHP Switcher..."
	    sudo rm /usr/local/bin/sphp

	alert "Uninstalling MariaDB and Dnsmasq..."
	    brew uninstall mariadb dnsmasq
		sudo rm -rf /usr/local/Cellar/dnsmasq
		sudo rm -rf /usr/local/opt/dnsmasq
		sudo rm -rf /usr/local/var/homebrew/linked/dnsmasq

	alert "Uninstalling Required Dependencies..." # this isn't uninstalling...
		brew uninstall openldap
		brew uninstall libiconv

	brew cleanup

	# Issue with unbound...
	# required by ffmpeg, gnutls and opencv
}

uninstall_brews () {
	alert "Uninstalling all Homebrew Packages..."
		brew list --formula | xargs brew rm

		brew doctor && brew cleanup

		# If you see issues with brews not being installed, it might be because
		# multiple versions are present. You can force uninstalls by doing this:
		# brew uninstall --force freetds
		# brew uninstall --force nghttp2
		# brew uninstall webp

		# WebP causes the following brews to not uninstall...
		# brew uninstall libtiff libpng jpeg
		# brew list --formula | xargs brew rm
}

uninstall_homebrew () {
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall.sh)"

	alert "Removing Homebrew Leftovers..."
	echo "We're targetting Homebrew specific folders, since other programs use the usr/local folder as well."

	folders=(
		/usr/local/etc
		/usr/local/var/cache
		/usr/local/var/homebrew
		/usr/local/Cellar
		/usr/local/Caskroom
		/usr/local/Homebrew
		/etc/resolver
	)

	for folder in "${folders[@]}"; do
		echo "Removing $folder..."
		sudo rm -rf $folder
	done

	alert "Deleting Command Line Tools..."
		sudo rm -rf /Library/Developer/CommandLineTools
		sudo xcode-select --reset
}

uninstall_apm () {
	apm list --installed --bare | awk -F'@' '{print $1}' | xargs apm uninstall
}

# WARNING: Not sure this will work if you uninstall bash first.
# Put the following in uninstall order...
for cmd in "$@"; do
	case "$cmd" in
		"server")
			alert "Uninstalling Server..."
			uninstall_server
		;;
		"brews")
			alert "Removing all Brews..."
			uninstall_brews
		;;
		"homebrew")
			alert "Uninstalling Homebrew..."
			uninstall_homebrew
		;;
		"npm")
			alert "Deleting NPM Modules..."
			remove_npm
		;;
		"bash")
			alert "Resetting Bash Config..."
			reset_bash
			remove_npm
		;;
		"apm")
			alert "Uninstalling Atom Packages..."
			uninstall_apm
		;;
	esac
done
