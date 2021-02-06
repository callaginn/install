#!/bin/bash
# Based on https://getgrav.org/blog/macos-catalina-apache-multiple-php-versions

source=/usr/local/etc/httpd/original/httpd.conf
dest=/usr/local/etc/httpd/httpd.conf

if [[ -f $dest ]]; then
	# Read destination file into variable, if it exists
	lines=(); while IFS=$'\n' read -r; do
		lines+=("$REPLY")
	done < $dest
fi

tab="    ";
inDocRoot="false"
inDirectoryIndex="false"

enable_modules () {
	for i in "${!lines[@]}"; do
		line="${lines[i]}"

		if [[ "$line" =~ ^#?(LoadModule|Include) ]]; then
	        match=false
	        for m in "$@"; do
	            if [[ "$line" == *"$m"* ]]; then match=true; fi
	        done

			# Enable Modules in Includes List
	        if [[ "$match" == true ]]; then
				lines[i]=$(uncomment "$line")
				echo "${red}- $line${c}${br}${green}+ ${lines[i]}${c}"
			else
		        echo -e "${gray}$line${c}"
		    fi
		fi
	done
}

config_apache () {
	for i in "${!lines[@]}"; do
		line="${lines[i]}"

		if [[ "$line" =~ ^#?(LoadModule|Include) ]]; then
	        line="${lines[i]}"

	    elif [[ "$line" == *"Listen 8080"* ]]; then
			lines[i]="Listen 80"
			echo "${red}- $line${c}${br}${green}+ ${lines[i]}${c}"

	    elif [[ "$line" == *'DocumentRoot "/usr/local/var/www"'* ]]; then
			lines[i]="DocumentRoot \"$sites\""
			echo "${red}- $line${c}${br}${green}+ ${lines[i]}${c}"

	    elif [[ "$line" == *'<Directory "/usr/local/var/www">'* ]]; then
	        inDocRoot="true"
			lines[i]="<Directory \"$sites\">"
	        echo "${red}- $line${c}${br}${green}+ ${lines[i]}${c}"

	    elif [[ "$line" == *"</Directory>"* ]]; then
	        inDocRoot="false"

	    elif [[ "$line" == *"User _www"* ]]; then
	        lines[i]="User $USER"
			echo "${red}- $line${c}${br}${green}+ ${lines[i]}${c}"

	    elif [[ "$line" == *"Group _www"* ]]; then
			lines[i]="Group $(id -gn)"
	        echo "${red}- $line${c}${br}${green}+ ${lines[i]}${c}"

	    elif [[ "$line" == *"#ServerName"* ]]; then
	        lines[i]="ServerName localhost"
			echo "${red}- $line${c}${br}${green}+ ${lines[i]}${c}"

	    # Attack the hard-to-find sections using true/false variables
	    elif [[ "$inDocRoot" == "true" && "$line" == *"AllowOverride None"* ]]; then
	        lines[i]="${tab}AllowOverride All"
			echo "${red}- $line${c}${br}${green}+ ${lines[i]}${c}"
	    else
	        echo -e "${gray}$line${c}"
	    fi
	done
}

config_php () {
	for i in "${!lines[@]}"; do
		line="${lines[i]}"

		if [[ "$line" == *mod_rewrite.so* ]]; then
	        # Add PHP modules below mod_rewrite:
	        modules=(
	            "$line"
				"#LoadModule php7_module /usr/local/opt/php@7.2/lib/httpd/modules/libphp7.so"
				"#LoadModule php7_module /usr/local/opt/php@7.3/lib/httpd/modules/libphp7.so"
				"#LoadModule php7_module /usr/local/opt/php@7.4/lib/httpd/modules/libphp7.so"
	        )

			lines[i]=$(printf '%s\n' "${modules[@]}")

	        echo "${red}- $line${c}"

	        for module in "${modules[@]}"; do
	            echo "${green}+ $module${c}"
	        done

		elif [[ "$line" == *"DirectoryIndex index.html"* ]]; then
	        inDirectoryIndex="true"

	        lines[i]="${tab}DirectoryIndex index.php index.html"
			echo "${red}- $line${c}${br}${green}+ ${lines[i]}${c}"

		elif [[ "$inDirectoryIndex" == "true" && "$line" == *"</IfModule>"* ]]; then
	        inDirectoryIndex="false"

			# Insert Additional FilesMatch Section After Module
			lines[i]="$line${br}${br}<FilesMatch \.php$>${br}${tab}SetHandler application/x-httpd-php${br}</FilesMatch>"

	        echo "${red}- $line${c}${br}${green}+ ${lines[i]}${c}"

		else
	        echo -e "${gray}$line${c}"
		fi
	done
}

case "$1" in
	"apache")
		includes=(
			mod_rewrite.so
		)

		alert "Part 1A: Apache Setup"
		enable_modules "${includes[@]}"
		config_apache "${includes[@]}"

		alert "Print to Destination"
		printf '%s\n' "${lines[@]}" >| $dest
	;;
	"php")
		alert "Part 1B: Apache PHP Setup"
		config_php

		alert "Print to Destination"
		printf '%s\n' "${lines[@]}" >| $dest
	;;
	"vhosts")
		includes=(
			mod_vhost_alias.so
			httpd-vhosts.conf
			mod_macro.so # custom
			mod_include.so # custom
		)

		alert "Part 2: Configure VHosts"
		enable_modules "${includes[@]}"

		alert "Print to Destination"
		printf '%s\n' "${lines[@]}" >| $dest
	;;
	"ssl")
		includes=(
			mod_socache_shmcb.so
			mod_ssl.so
			httpd-ssl.conf
		)

		alert "Part 3: SSL Setup"
		enable_modules "${includes[@]}"

		alert "Print to Destination"
		printf '%s\n' "${lines[@]}" >| $dest
	;;
	"extra")
		includes=(
			mod_authn_dbm.so
			mod_authn_anon.so
			mod_authn_dbd.so
			mod_authn_socache.so
			mod_authz_dbm.so
			mod_authz_owner.so
			mod_deflate.so
			mod_expires.so
			mod_userdir.so
			httpd-autoindex.conf
			httpd-info.conf
		)

		alert "Part 3: Extra Modules"
		enable_modules "${includes[@]}"

		alert "Print to Destination"
		printf '%s\n' "${lines[@]}" >| $dest
	;;
	"reset")
		alert "Resetting httpd.conf to default"
		cp $source $dest
	;;
	"test")
		alert "Here is a test"
	;;
	*)
		# Not sure if this will work or not...
		make_httpd apache
		make_httpd php
		make_httpd vhosts
		make_httpd extra
	;;
esac
