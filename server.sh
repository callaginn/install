#!/bin/bash

. ~/.bash_profile
test -f $HOME/.setup && . $_
alias make_httpd=". $install/bin/make-httpd.sh"

# Keep-alive: Might as well ask for password up-front, right?
sudo -v; while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# ******************************************************************************
#   SERVER INSTALL SCRIPT
#   Based on https://getgrav.org/blog/macos-catalina-apache-multiple-php-versions
# ******************************************************************************

# NOTE: Homebrew automatically installs XCode, without any prompts. Git requires this.
if [[ ! $(which brew) ]]; then
	alert "Installing Homebrew..."
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
		brew cleanup
		brew doctor
fi

alert "Installing Local Server"
	sudo apachectl stop
	sudo launchctl unload -w /System/Library/LaunchDaemons/org.apache.httpd.plist 2>/dev/null
	sudo killall httpd
	brew install openldap
	brew install libiconv
	brew install httpd
	brew install mariadb
	brew install dnsmasq

alert "Installing PHP"
	ver="7.4"
	brew install php@$ver
	brew link php@$ver # required for pecl
	filename="/usr/local/etc/php/$ver/php.ini"
	contents=$(cat $filename)
	contents=$(replace "$contents" "memory_limit" "500")
	contents=$(replace "$contents" "max_execution_time" "120")
	echo "$contents" >| $filename

	pecl uninstall -r apcu && pecl install apcu <<<''
	pecl uninstall -r yaml && pecl install yaml <<<''
	pecl uninstall -r xdebug && pecl install xdebug
	brew install pkg-config imagemagick
	pecl install imagick <<<''

alert "Configure Server"
	make_httpd apache
	make_httpd php
	make_httpd vhosts
	make_httpd extra
	ln -sf $apache/httpd-vhosts.conf /usr/local/etc/httpd/extra/httpd-vhosts.conf

	alert "Installing PHP Switcher Script..."
		curl -L https://gist.githubusercontent.com/rhukster/f4c04f1bf59e0b74e335ee5d186a98e2/raw >| /usr/local/bin/sphp
		chmod +x /usr/local/bin/sphp
		sphp "$ver"

	echo 'address=/.test/127.0.0.1' >| /usr/local/etc/dnsmasq.conf
	sudo mkdir -v /etc/resolver
	sudo bash -c 'echo "nameserver 127.0.0.1" > /etc/resolver/test'

	alert "Configuring vHosts for Crema..."
		echo -e "Define ENV $ENV\nDefine CACHING false\nDefine CLIENTS \"$sites\"" >| "$apache/.env.conf"
		curl -L https://git.io/JtqkV -o $apache/.env.conf
		echo -e 'ENV="work"\nvhost="$apache/vhosts/$ENV.conf"\nalias vhost="open $apache/vhosts/${ENV}.conf"' >| ~/.profile

alert "Booting up Server"
	brew services start httpd
	brew services start mariadb
	sudo brew services start dnsmasq

alert "Creating an Awesome Test Project"
	makesite demo.test $sites/demo twig

alert "Important Notes and Issues:"
	echo "- You might need to adjust the .env file in the apache folder"
	echo "- If you have issues, double-check your work/home.conf apache config"
