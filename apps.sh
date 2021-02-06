#!/bin/bash

if [[ $# -eq 0 ]]; then
    echo "Usage: ./apps.sh brews npm apps atom"
else
	test -f $HOME/.setup && . $_
	test -f bin/common.sh && . $_
fi

caskinfo () {
    #brew info $1 --json=v2 | python -c "import json,sys;obj=json.load(sys.stdin);print obj['casks'][0][\"$2\"][0];"
    brew info $1 --json=v2 | perl -nle "print \$1 if /(?<=\"$2\":\[\")([^\"]*)/"
}

for cmd in "$@"; do
	case "$cmd" in
		"brews")
	        alert "Tapping Brews..."
	        cat data/taps.txt | while read tap; do
	            brew tap $tap
	        done

	        alert "Installing Brews..."
	        cat data/brews.txt | while read brew; do
	            brew install $brew
	        done
		;;
	    "npm")
			alert "Installing NVM..."
				curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash
                . ~/.bash_profile # loads NVM
				command -v nvm >/dev/null 2>&1 && alert -t success "NVM Installed" || alert -t error "NVM Install Failed"

			alert "Installing Node..."
				nvm install --lts

			# Note: Slate and Yarn will both install Node
	        alert "Installing NPM Plugins (requires brews)..."
	        cat data/npm.txt | while read package; do
	            npm install -g $package
	        done
		;;
		"apps")
	        alert "Installing Apps (Not Yet Supported)..."
	        cat data/casks.txt | while read cask; do
                printf "Installing $(caskinfo $cask name)\n"
	            printf "brew cask install $cask\n\n"
	        done
		;;
		"atom")
	        alert "Installing Atom Packages..."
	        cat data/atom.txt | while read package; do
	            apm install $package
	        done
		;;
	esac
done
