# Developer Setup
>The following install scripts, quickstart, settings, and functions can be used to setup and configure developer machines.
>
>These automated install scripts were inspired by the following article from the Grav CMS Blog: [macOS 10.13 High Sierra Apache Setup: Multiple PHP Versions](https://getgrav.org/blog/macos-sierra-apache-multiple-php-versions)

## Install Quickstart
Provided you've added the user as a collaborator to this repo and customized their `~/.setup` file, you can simply run the following commands in order:
```bash
curl -L "https://git.io/Jtt11" -o ~/desktop/setup && chmod +x $_
~/desktop/setup
cd /Sites/config/install
./bash-config.sh
./settings.sh general_ux finder firewall safari terminal
./apps.sh brews npm atom
./server.sh
```

## Pre-Install
1. Create a new Github Account and add user as a collaborator to the [config](https://github.com/cremadesign/config) repo.

2. Download the setup gist to your desktop and make it executable:
    ````bash
    curl -L "https://git.io/Jtt11" -o ~/desktop/setup && chmod +x $_
    ````

3. Either configure your install via https://setup.ginn.io or customize a new config:

    ```bash
    curl -L "https://git.io/JtUdx" -o ~/.setup
    atom ~/.setup
    ```

4. Start the install:

   ```bash
   ~/desktop/setup
   ```

## Install
1. Shut down anything that might interfere, such as Codekit, Github Desktop, bash scripts, etc.
2. Double-click the `setup` script on your desktop.
3. CD into the newly cloned repo: `cd /Sites/config/install`
3. Open `bash-config.sh` to set up bash and git. We're still using Terminal here.
4. Open `settings.sh {args}` to apply default system settings. Requires bash-config install.
5. Open `apps.sh {args}` to install default apps for developers.
6. Open `server.sh` to install a local test server.

> **Debugging:**<br>
> If you have issues, please run through these [manual setup steps](DEBUGGING.md)

# Server Cheatsheet

### Refresh it All!
```bash
server restart
```

> **Note:** I've also created an experimental Automator App called `Restart Server` in this repo that runs through all the commands below. If you have issues, please try running the manual commands below.

### Restart Apache
```bash
sudo apachectl -k restart
```

You can watch the Apache error log in a new Terminal tab/window during a restart to see if anything is invalid or causing a problem:

```bash
tail -f /usr/local/var/log/httpd/error_log
```

### Restart HTTPD
```bash
sudo brew services restart httpd
```

### Restart MySQL
```bash
brew services restart mariadb
```

### Restart Dnsmasq
```bash
sudo brew services restart dnsmasq
```

### Our Clean DNS Function
```bash
flushdns -V
```

# Uninstall
```bash
./uninstall.sh server brews homebrew npm apm bash
```
