#!/bin/bash
. ~/.bash_profile

if [[ $# -eq 0 ]]; then
    echo "Usage: ./settings.sh general_ux finder dock firewall safari terminal"
else
    header -c alert "APPLY SETTINGS" "This script applies dozens of useful system settings for web developers"
    echo "Closing open System Preferences panes, to prevent them from overriding our settings"
    osascript -e 'tell application "System Preferences" to quit'
fi


################################################################################
# General UI/UX                                                                #
################################################################################

setup_general_ux () {
    echo "Changing highlight color to Crema blue"
    defaults write NSGlobalDomain AppleHighlightColor -string "0.611765 0.776471 0.796078"
    # Reset with defaults delete -g AppleHighlightColor

    echo "Reversing Mouse Scroll..."
    defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

    echo "Reenable old-school key repeating"
    defaults write -g ApplePressAndHoldEnabled -bool false

    echo "Disable smart quotes and dashes"
    defaults write -g NSAutomaticQuoteSubstitutionEnabled 0
    defaults write -g NSAutomaticDashSubstitutionEnabled 0

    echo "Turning off Automatic Updates..."
    sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate ConfigDataInstall -bool false
    sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate CriticalUpdateInstall -bool false

    echo "Turning on Automatic Wake..."
    sudo pmset repeat wakeorpoweron MTWRF 9:00:00
    # sudo defaults read /Library/Preferences/SystemConfiguration/com.apple.AutoWake.plist

    #echo "Use Dark Menu Bar and Dock..."
    #defaults write NSGlobalDomain AppleInterfaceStyle Dark
    #$install/bin/toggle-mode.scpt
}


################################################################################
# Finder                                                                       #
################################################################################

setup_finder () {
    echo "Showing Hidden User Library Folder..."
    chflags nohidden ~/Library

    echo "Show hard drives on the desktop"
    defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true

    echo "Show mounted servers on the desktop"
    defaults write com.apple.finder ShowMountedServersOnDesktop -bool true

    echo "Showing Hidden Files..."
    defaults write com.apple.finder AppleShowAllFiles -bool true

    echo "Showing Finder Status Bar..."
    defaults write com.apple.finder ShowStatusBar -bool true

    echo "Showing Finder Path Bar..."
    defaults write com.apple.finder ShowPathbar -bool true

    echo "Display full POSIX path as Finder window title"
    defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

    echo "Keep folders on top when sorting by name"
    defaults write com.apple.finder _FXSortFoldersFirst -bool true

    echo "Enable snap-to-grid for various icon views"
    /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
    /usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
    /usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist

    echo "Disable file extension change warning"
    defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

    echo "Use current folder as default search scope"
    defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
}


################################################################################
# Dock, Dashboard, and hot corners                                             #
################################################################################

setup_dock () {
    echo "Enable highlight hover effect for the grid view of a stack (Dock)"
    defaults write com.apple.dock mouse-over-hilite-stack -bool true

    echo "Minimize windows into their application’s icon"
    defaults write com.apple.dock minimize-to-application -bool true

    echo "Remove all items from the dock"
    defaults write com.apple.dock persistent-apps -array

    echo "Added three thin spacers to dock for organizing"
    dock -spacers 3

    echo "Customizing Hot Corners..."
    hotcorner tl 3
    hotcorner tr 12
    hotcorner bl 2
    hotcorner br 4
}


################################################################################
# Security                                                                     #
################################################################################

setup_firewall () {
    echo "Turning on Firewall..."
    sudo defaults write /Library/Preferences/com.apple.alf globalstate -int 1
}


################################################################################
# Safari Preferences                                                           #
################################################################################

setup_safari () {
    echo "Enable the Develop menu and the Web Inspector in Safari"
    defaults write com.apple.Safari IncludeDevelopMenu -bool true
    defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
    defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true

    echo "Add a context menu item for showing the Web Inspector in web views"
    defaults write NSGlobalDomain WebKitDeveloperExtras -bool true
}


################################################################################
# Bash                                                                         #
################################################################################

install_fonts () {
    alert -t spinner "Installing Fonts for Terminal and iTerm2..."
	brew tap homebrew/cask-fonts
	brew cask install font-hack-nerd-font

	# Installing bash font variables...
    src="https://raw.githubusercontent.com/ryanoasis/nerd-fonts/master/bin/scripts/lib/"
    for f in ${src}i_{all,dev,fae,fa,iec,linux,oct,ple,pom,seti,material,weather}.sh; do
        echo "Downloading $f"
        curl -L $f -o ~/bin/nerd-fonts/"${f//$src/}" --create-dirs
    done

    refresh
    alert -t success "Installed with ${red}$i_fa_heart${c}"
}

install_colorls () {
    # https://github.com/athityakumar/colorls
    echo "Installing ColorLS for nicer directory listings"
    sudo gem install colorls

    #echo -e "\n# ColorLS Configuration" >> ~/.bash_profile
    #echo -e "source $(dirname $(gem which colorls))/tab_complete.sh" >> ~/.bash_profile
    #echo -e "alias lc='colorls -A --sd'" >> ~/.bash_profile
    # NOTE: I may need to check to see if fonts are installed here...
}

setup_terminal () {
    echo "Disable the annoying terminal line marks"
    defaults write com.apple.Terminal ShowLineMarks -int 0

    install_colorls
    install_fonts

    echo "Installing custom Terminal theme"
    $data/terminal-theme.scpt

    echo "Disable smart dashes as they’re annoying when typing code"
    defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
}


################################################################################
# Photos                                                                       #
################################################################################

setup_photos () {
    echo "Prevent Photos from opening automatically when devices are plugged in"
    defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true

    # echo "Unloading the iPhoto Photo Analysis Launch Agent, which crashes some systems"
    # launchctl unload /System/Library/LaunchAgents/com.apple.photoanaysisd.plist
    # rm -rf /System/Library/LaunchAgents/com.apple.photoanaysisd.plist
}


################################################################################
# INSTALL SETTINGS                                                             #
################################################################################

for cmd in "$@"; do
    case "$cmd" in
        "general_ux")
            setup_general_ux
        ;;
        "finder")
            setup_finder
        ;;
        "dock")
            setup_dock
        ;;
        "firewall")
            setup_firewall
        ;;
        "safari")
            setup_safari
        ;;
        "terminal")
            setup_terminal
        ;;
        "photos")
            setup_photos
        ;;
    esac
done

if [[ ! $# -eq 0 ]]; then
    echo "Restarting Finder to Apply Changes..."
    sudo killall Finder
    killall Dock
    pkill Safari

    echo
    alert -t success "All default macOS and application settings have been applied."
fi
