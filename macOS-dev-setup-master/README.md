# macOS Development Setup

Este documento describe cómo configuré mi entorno de desarrollador en un nuevo MacBook o iMac. Configuraremos lenguajes de programación populares (por ejemplo, [Nodo] (http://nodejs.org/) (JavaScript), [Python] (http://www.python.org/), y [Ruby] (http: //www.ruby-lang.org/)). Es posible que no los necesite todos para sus proyectos, aunque le recomiendo que los configure, ya que siempre son útiles.

El documento asume que usted es nuevo en Mac, pero también puede ser útil si está reinstalando un sistema y necesita algún recordatorio. Los pasos a continuación se probaron en ** macOS High Sierra ** (10.13), pero también deberían funcionar para versiones más recientes.

**Contribución**: Si encuentra algún error en los pasos descritos a continuación, o si alguno de los comandos no está actualizado, ¡hágamelo saber! Para cualquier otra sugerencia, comprenda si no incluyo todo. Esta guía fue escrita originalmente para algunos amigos, comenzando con la programación en una Mac y como una referencia personal para mí. Estoy tratando de mantenerlo simple!


This document describes how I set up my developer environment on a new MacBook or iMac. We will set up popular programming languages (for example [Node](http://nodejs.org/) (JavaScript), [Python](http://www.python.org/), and [Ruby](http://www.ruby-lang.org/)). You may not need all of them for your projects, although I recommend having them set up as they always come in handy.

The document assumes you are new to Mac, but can also be useful if you are reinstalling a system and need some reminder. The steps below were tested on **macOS High Sierra** (10.13), but should work for more recent versions as well.

**Contributing**: If you find any mistakes in the steps described below, or if any of the commands are outdated, do let me know! For any other suggestions, please understand if I don't include everything. This guide was originally written for some friends getting started with programming on a Mac, and as a personal reference for myself. I'm trying to keep it simple!

- [System update](#system-update)
- [System preferences](#system-preferences)
- [Security](#security)
- [Terminal](#terminal)
- [Homebrew](#homebrew)
- [Git](#git)
- [Visual Studio Code](#visual-studio-code)
- [Vim](#vim)
- [Python](#python)
- [Node.js](#nodejs)
- [Ruby](#ruby)
- [Heroku](#heroku)
- [PostgreSQL](#postgresql)
- [Redis](#redis)
- [Elasticsearch](#elasticsearch)
- [Projects folder](#projects-folder)
- [Apps](#apps)

## System update

First thing you need to do, on any OS actually, is update the system! For that: **Apple Icon > About This Mac** then **Software Update...**.

Lo primero que debe hacer, en cualquier sistema operativo, ¡es actualizar el sistema! Para eso: **Icono de Apple> Acerca de esta Mac** y luego **Actualización de software...**.

## System preferences

If this is a new computer, there are a couple of tweaks I like to make to the System Preferences. Feel free to follow these, or to ignore them, depending on your personal preferences.

In **Apple Icon > System Preferences**:

- Trackpad > Tap to click
- Keyboard > Key Repeat > Fast (all the way to the right)
- Keyboard > Delay Until Repeat > Short (all the way to the right)
- Dock > Automatically hide and show the Dock

## Security

I recommend checking that basic security settings are enabled. You will be happy to have done so if ever your Mac is lost or stolen.

In **Apple Icon > System Preferences**:

- Users & Groups: If you haven't already set a password for your user during the initial set up, you should do so now
- Security & Privacy > General: Require password immediately after sleep or screen saver begins (you can keep a grace period of a couple minutes if you prefer, but I like to know that my computer locks as soon as I close it)
- Security & Privacy > FileVault: Make sure FileVault disk encryption is enabled
- iCloud: If you haven't already done so during set up, enable Find My Mac

## Terminal

In the tab **Profiles**, create a new one with the "+" icon, and rename it to your first name for example. Then, select **Other Actions... > Set as Default**. Under the section **General** set **Working Directory** to be **Reuse previous session's directory**. Finally, under the section **Window**, change the size to something better, like **Columns: 120** and **Rows: 35** and font **Fira Mono 11**.

### Beautiful terminal

Since we spend so much time in the terminal, we should try to make it a more pleasant and colorful place. What follows might seem like a lot of work, but trust me, it'll make the development experience so much better.

First let's add some color. There are many great color schemes out there, but if you don't know where to start you can try [Atom One Dark](https://github.com/nathanbuchar/atom-one-dark-terminal). Download the iTerm presets for the theme by running:

## Homebrew

Package managers make it so much easier to install and update applications (for Operating Systems) or libraries (for programming languages). The most popular one for macOS is [Homebrew](http://brew.sh/).

### Install

An important dependency before Homebrew can work is the **Command Line Developer Tools** for **Xcode**. These include compilers that will allow you to build things from source. You can install them directly from the terminal with:

```
xcode-select --install
```

Once that is done, we can install Homebrew by copy-pasting the installation command from the [Homebrew homepage](http://brew.sh/) inside the terminal:

```
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

Follow the steps on the screen. You will be prompted for your user password so Homebrew can set up the appropriate permissions.

Once installation is complete, you can run the following command to make sure everything works:

```
brew doctor
```

### Usage

To install a package (or **Formula** in Homebrew vocabulary) simply type:

```
brew install <formula>
```

To see if any of your packages need to be updated:

```
brew outdated
```

To update a package:

```
brew upgrade <formula>
```

Homebrew keeps older versions of packages installed, in case you want to rollback. That rarely is necessary, so you can do some cleanup to get rid of those old versions:

```
brew cleanup
```

To see what you have installed (with their version numbers):

```
brew list --versions
```

### Homebrew Services

A nice extension to Homebrew is [Homebrew Services](https://github.com/Homebrew/homebrew-services). It will automatically launch things like databases when your computer starts, so you don't have to do it manually every time.

Homebrew Services will automatically install itself the first time you run it, so there is nothing special to do.

After installing a service (for example a database), it should automatically add itself to Homebrew Services. If not, you can add it manually with:

```
brew services <formula>
```

Start a service with:

```
brew services start <formula>
```

At anytime you can view which services are running with:

```
brew services list
```

## Git

macOS comes with a pre-installed version of [Git](http://git-scm.com/), but we'll install our own through Homebrew to allow easy upgrades and not interfere with the system version. To do so, simply run: `brew install git`

When done, to test that it installed fine you can run: `which git`

The output should be `/usr/local/bin/git`.

On a Mac, it is important to remember to add `.DS_Store` (a hidden macOS system file that's put in folders) to your project `.gitignore` files. You also set up a global `.gitignore` file, located for instance in your home directory (but you'll want to make sure any collaborators also do it):

```
cd ~
curl -O https://raw.githubusercontent.com/nicolashery/mac-dev-setup/master/.gitignore
git config --global core.excludesfile ~/.gitignore
```

## Zsh

`brew install zsh`

`chsh -s /usr/local/bin/zsh`

### Oh My Zsh

`sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"`

plugins=(
  git
  common-aliases
  extract
  colored-man-pages
  zsh-autosuggestions
  zsh-syntax-highlighting
)

## Node.js

The recommended way to install [Node.js](http://nodejs.org/) is to use [nvm](https://github.com/creationix/nvm) (Node Version Manager) which allows you to manage multiple versions of Node.js on the same machine.

Install `nvm` by copy-pasting the [install script command](https://github.com/creationix/nvm#install--update-script) into your terminal.

Once that is done, open a new terminal and verify that it was installed correctly by running:

```
command -v nvm
```

View the all available stable versions of Node with:

```
nvm ls-remote --lts
```

Install the latest stable version with:

```
nvm install node
```

It will also set the first version installed as your default version. You can install another specific version, for example Node 10, with:

```
nvm install 10
```

And switch between versions by using:

```
nvm use 10
nvm use default
```

See which versions you have install with:

```
nvm ls
```

Change the default version with:

```
nvm alias default 10
```

In a project's directory you can create a `.nvmrc` file containing the Node.js version the project uses, for example:

```
echo "10" > .nvmrc
```

Next time you enter the project's directory from a terminal, you can load the correct version of Node.js by running:

```
nvm use
```

### npm

Installing Node also installs the [npm](https://npmjs.org/) package manager.

To install a package:

```
npm install <package> # Install locally
npm install -g <package> # Install globally
```

To install a package and save it in your project's `package.json` file:

```
npm install --save <package>
```

To see what's installed:

```
npm list --depth 1 # Local packages
npm list -g --depth 1 # Global packages
```

To find outdated packages (locally or globally):

```
npm outdated [-g]
```

To upgrade all or a particular package:

```
npm update [<package>]
```

To uninstall a package:

```
npm uninstall --save <package>
```

brew install watchman
brew cask install adoptopenjdk/openjdk/adoptopenjdk8
brew install gradle

## Android Studio

Select the "SDK Platforms" tab from within the SDK Manager, then check the box next to "Show Package Details" in the bottom right corner. Look for and expand the Android 10 (Q) entry, then make sure the following items are checked:

- Android SDK Platform 29
- Intel x86 Atom_64 System Image or Google APIs Intel x86 Atom System Image

Next, select the "SDK Tools" tab and check the box next to "Show Package Details" here as well. Look for and expand the **Android SDK Build-Tools** entry, then make sure that **29.0.2** is selected.

Finally, click "Apply" to download and install the Android SDK and related build tools.

#### Add the following lines to your ~/.zshrc) config file:
```
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools

export GRADLE_HOME=/usr/local/Cellar/gradle/6.6.1
export PATH=$PATH:$GRADLE_HOME/bin
```

## Projects folder

This really depends on how you want to organize your files, but I like to put all my version-controlled projects in `~/Projects`. Other documents I may have, or things not yet under version control, I like to put in `~/Dropbox` (if you have [Dropbox](https://www.dropbox.com/) installed), or `~/Documents` if you prefer to use [iCloud Drive](https://support.apple.com/en-ca/HT206985).

## Apps

Here is a quick list of some apps I use, and that you might find useful as well:

- [1Password](https://1password.com/): Securely store your login and passwords, and access them from all your devices. **($3/month)**
- [Dropbox](https://www.dropbox.com/): File syncing to the cloud. It is cross-platform, but if all your devices are Apple you may prefer [iCloud Drive](https://support.apple.com/en-ca/HT206985). **(Free for 2GB)**
- [Postman](https://www.getpostman.com/): Easily make HTTP requests. Useful to test your REST APIs. **(Free for basic features)**
- [GitHub Desktop](https://desktop.github.com/): I do everything through the `git` command-line tool, but I like to use GitHub Desktop just to review the diff of my changes. **(Free)**
- [Spectacle](https://www.spectacleapp.com/): Move and resize windows with keyboard shortcuts. **(Free)**
