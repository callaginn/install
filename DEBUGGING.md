# Manual Server Setup

## PART 1

### XCode Command Line Tools
````bash
xcode-select --install
````

### Homebrew Install
Follow the terminal prompts and enter your password where required.
````bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall.sh)"
````

You should probably also run the following command to ensure everything is configured correctly:
````bash
brew doctor
````

### Apache Install
Apache is controlled via the apachectl command so some useful commands to use are:

````bash
sudo apachectl stop
sudo launchctl unload -w /System/Library/LaunchDaemons/org.apache.httpd.plist 2>/dev/null
brew install httpd
sudo brew services start httpd
````

#### Apache Configuration
Since the PHP auto-switcher script overwrites symlinks, we'll need to replace `/usr/local/etc/httpd/httpd.conf` with the one in the repo.

I've already made the required changes and uncommented a few extra modules. I may need to retest everything again to see what's essential.
````
LoadModule macro_module lib/httpd/modules/mod_macro.so
LoadModule include_module lib/httpd/modules/mod_include.so
LoadModule vhost_alias_module lib/httpd/modules/mod_vhost_alias.so
LoadModule expires_module lib/httpd/modules/mod_expires.so
LoadModule userdir_module modules/mod_userdir.so
Include /usr/local/etc/httpd/extra/httpd-vhosts.conf
LoadModule deflate_module lib/httpd/modules/mod_deflate.so
````

## PHP Install
Install four PHP versions and switch back to first. I've chained together original commands, so this time-intensive portion doesn't require user interaction. It will take about 45 minutes, since it's building all PHP from source code.
````bash
brew install php@5.6 php@7.0 php@7.1 php@7.2; brew unlink php@7.2 && brew link --force --overwrite php@5.6
````

#### Upgrading PHP
https://mark.shropshires.net/blog/how-reinstall-homebrew-php-after-move-homebrewphp-homebrewcore

### PHP Switcher Script
````bash
curl -L https://gist.githubusercontent.com/rhukster/f4c04f1bf59e0b74e335ee5d186a98e2/raw > /usr/local/bin/sphp
chmod +x /usr/local/bin/sphp
````

-----

## PART 2

### MySQL

````bash
brew update
brew install mariadb
brew services start mariadb
````

### SequelPro
[Download SequelPro](http://www.sequelpro.com), install, and open it. You should be able to automatically create a new connection via the Socket option without changing any settings.

Sequel Pro stores its databases in the `/usr/local/var/mysql` folder.

### Dnsmasq

Install with brew, setup `*.test` hosts, and start it as a service, and add it to the resolvers.
````bash
brew install dnsmasq
echo 'address=/.test/127.0.0.1' > /usr/local/etc/dnsmasq.conf
sudo brew services start dnsmasq
sudo mkdir -p /etc/resolver
sudo bash -c 'echo "nameserver 127.0.0.1" > /etc/resolver/test'
````

Voila! we have successfully setup wildcard forwarding of all `*.test` DNS names to localhost. Test by pinging some bogus `.test` name:
````bash
ping bogus.test
````

### Caching
All PHP packages now come pre-built with Zend OPcache by default, but you can still install APCu Cache as a data store. I chained these selectors together to make it quicker, but unfortunately it's gonna ask for user input a few times.

### Install APCu
For PHP 7.0 and above you can use the latest 5.x release of APCu, so the process is the same for all. First let's switch to PHP 7.0 and install the APCu library:
````bash
sphp 7.1
pecl uninstall -r apcu && pecl install apcu

sphp 7.2
pecl uninstall -r apcu && pecl install apcu

sphp 7.3
pecl uninstall -r apcu && pecl install apcu

sphp 7.4
pecl uninstall -r apcu && pecl install apcu

sudo apachectl -k restart
````

### Mcrypt Info
This previously optional extension is required to run the Craft CMS Control Panel. It is now included in the homebrew/core version of PHP. However, you'll need to remove old references if upgrading an old install.

Point your browser to http://localhost/info.php and ensure you see a reference to Zend OPcache and Mcrypt.

### Install Node.JS
> **Note:** I might need to rewrite this section to work with Yarn.

The Crema email system requires Node.JS, so why not install it the same way? This has been tested and works.
````bash
brew install node@v6
npm install --global foundation-cli
npm install --save-dev gulp-xml2json
````

-----

## Part 3

### Generate SSL Certificate
```bash
cd /usr/local/etc/httpd; openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout server.key -out server.crt -subj "/CN=US/ST=Mississippi/L=Ridgeland/O=Crema Design Studio/OU=/CN=*.test"
```

### Read SSL Certificate
```bash
openssl x509 -text -noout -in server.crt
```
