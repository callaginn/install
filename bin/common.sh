#!/bin/bash

# ******************************************************************************
#   COLOR VARIABLES (for Dark Terminal Backgrounds)
# ******************************************************************************

# Foreground Colors                 # Background Colors
yellow=$(tput setaf 11)             yellowBG=$(tput setab 11)
red=$(tput setaf 196)               redBG=$(tput setab 196)
green=$(tput setaf 10)              greenBG=$(tput setab 10)
blue=$(tput setaf 75)               blueBG=$(tput setab 75)
aqua=$(tput setaf 14)               aquaBG=$(tput setab 14)
purple=$(tput setaf 129)            purpleBG=$(tput setab 129)
white=$(tput setaf 15)              whiteBG=$(tput setab 15)
gray=$(tput setaf 243)              grayBG=$(tput setab 243)
black=$(tput setaf 0)               blackBG=$(tput setab 0)

# Font weight and text decoration
bold=$(tput bold)
b=${bold}
ul=$(tput sgr 0 1)
em=$(tput sitm)
br=$'\n'
tab="    "
brtab=$'\n    '
c=$(tput sgr0) # Clear variables
rv=$(tput rev)


# ******************************************************************************
#   HELPER FUNCTIONS
# ******************************************************************************

# Print solid horizontal divider
line () { printf -v _hr "%*s" $(tput cols) && echo ${_hr// /${1-─}}; }

# Yellow Section Header and Alert
header () { echo -e "\n${yellow}$(line =)\n$1\n$(line -)${c}\n"; }
alert () { echo -e "\n${b}${yellow}$1${c}\n"; }

# Ini Property Editor
# this function causes include bugs
replace () {
	echo "$1" | perl -pe "s/(?<=$2 = )[0-9]+/$3/g";
}

# Check if array includes an item
# includes "7.2" "${versions[@]}"
includes () {
	local hasitem=0;
	local q="$1";
	shift;
	for i in "$@"; do
		if [[ "$i" == *"$q"* ]]; then
			hasitem=1;
		fi
	done
	echo $hasitem
}

# Uncomment a line
uncomment () {
	echo "$1" | sed -e 's/#//g'
}

app () {
    case "${1}" in
        -active)
            # List processes, remove self command name and on the end count wanted process
            [ $(ps aux | grep "$2" | grep -v grep | wc -l) -gt 0 ] && echo true || echo false;
        ;;
        -installed)
			[ -d "/Applications/${2}.app" ] && echo true || echo false;
        ;;
        -install)
            local app=$2
            alert "Installing $app and adding to the dock..."
            brew cask install $app
            dock -newitem "$(getAppPath $app)"
        ;;
    esac
}

dock() {
    case "${1}" in
        -newitem)
            local dockStr="<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>$2</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"
            defaults write com.apple.dock persistent-apps -array-add "$dockStr";
        ;;
        -spacers)
            # https://stackoverflow.com/questions/4764383/arguments-passed-into-for-loop-in-bash-script
            for ((i = 1; i <= $2; i++)); do
                defaults write com.apple.dock persistent-apps -array-add '{ "tile-type" = "small-spacer-tile"; }'
            done
        ;;
    esac
}

hotcorner () {
    # Usage: hotcorner [tl,tr,bl,br] [0,2,3,4,5,6,7,10,11,12]
    # To apply, you must run killall Dock

    case "${1}" in
        tl) position="Top Left" ;;
        tr) position="Top Right" ;;
        bl) position="Bottom Left" ;;
        br) position="Bottom Right" ;;
    esac

    case "${2}" in
        0) action="No Action" ;;
        2) action="Mission Control" ;;
        3) action="Application Windows" ;;
        4) action="Desktop" ;;
        5) action="Start screen saver" ;;
        6) action="Disable screen saver" ;;
        7) action="Dashboard" ;;
        10) action="Put display to sleep" ;;
        11) action="Launchpad" ;;
        12) action="Notification Center" ;;
    esac

    echo "$position → $action"
    defaults write com.apple.dock wvous-$1-corner -int ${2}
    defaults write com.apple.dock wvous-$1-modifier -int 0
}


# ******************************************************************************
#   PATHNAMES
# ******************************************************************************

date=$(date +"%Y-%m-%d@%H-%M")
backupDir="$HOME/config-backups/${date}"
apache="$sites/config/apache"
