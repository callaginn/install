#!/bin/bash

test -f $HOME/.setup && . $_
test -f bin/common.sh && . $_

for arg in "$@"; do
	case "$arg" in
		"apache")
			alert "Part 1A: Apache Setup"
		;;
		"php")
			alert "Part 1B: Apache PHP Setup"
		;;
		"vhosts")
			alert "Part 2: Configure VHosts"
		;;
		"ssl")
			alert "Part 3: SSL Setup"
		;;
		"extra")
			alert "Part 3: Extra Modules"
		;;
		"reset")
			alert "Resetting httpd.conf to default"
		;;
		*)
			echo "Enter a command..."
		;;
	esac
done
