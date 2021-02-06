# Install Order

### A. Setup Gist
_The setup-init.sh script will do the following:_
1. Show Hidden Files (add to setup-init.sh?)
2. Create or copy all .dotfiles with correct user permissions with setup-init.sh
3. Create site root with setup-init.sh.
4. Clone Config Repo with setup-init.sh, pull-repos.sh, or manual commands.
5. Command above will trigger Xcode installer. You can install just the developer tools.

### B. Apply Basic macOS Settings
_The Change Settings script does the following:_
1. Copy .bash_profile with "Change Settings.sh" (conflicts with `#2`)
2. You’ll be asked to enter a password after refreshing the console. Note sure if that’s the best thing to do next. It’d be more secure to request the password ONLY when installing OR restarting the server.

*NOTE:* This script seems to have some commands we’ve already run though. Hmmmm.

### C. Install
Install.sh allows you to easily setup optional apps and/or a testing server for designers and web developers. It checks and installs dependencies when first loaded.

----

### Brainstorming
*TODO:* Create a specific folder for all install scripts

# Terminal Preferences

### Default Theme
- Change theme to "Pro"

### Background
- Add 100% blur and 90% opacity (Home)
- Add 80% blur and 50% opacity (Work)

### Text Settings
- 13pt Monaco (Home) or 12 pt SF Mono Regular (Work)
- Antialias Text
- Use bright colors for bold text
- Character spacing 1
- Cursor vertical white bar and blink

# Atom settings
I believe we can transfer all of these with the .atom folder
- Toggle soft wrap
- Tab Length = 4
