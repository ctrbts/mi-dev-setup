# Mi Ubuntu Development Setup

Configuración de desarrollo para mis entornos de trabajo en distintas plataformas. Esta guía fue escrita como referencia personal y la actualizo a medida de mis necesidades (comprenda si no incluyo algunos stack de desarrollo).

**Contribución**: Si encuentra algún error en los pasos descritos a continuación, o si alguno de los comandos no está actualizado, ¡hágamelo saber!

- [Primeros pasos](#primeros-pasos)
- [Terminal](#terminal)
- [Gestores de paquetes](#gestores-de-paquetes)
- [Git](#git)
- [Zsh](#zsh)
- [Node.js](#node.js)
- [Mobile Frameworks](#mobile-frameworks)
- [OpenJDK](#openjdk)
- [Gradle](#gradle)
- [Netbeans IDE](#netbeans-ide)
- [Android Studio](#android-studio)

## Primeros pasos

Actualizamos el sistema, instalams un gestor de paquetes y las herramientas necesarias

```
sudo apt update && sudo apt upgrade -y
sudo apt install synaptic --install-suggests -y
sudo apt install curl git -y
```

## Terminal

Como vamos a pasar bastante tiempo en la terminal le vamos a dar un toque de color y productividad.

Descargamos e instalamos desde [Google Fonts](https://fonts.google.com/?query=fira) las fuentes Fira Code, Fira Mono y Fira Sans.

Instalamos un nuevo tema desde [Gogh Themes](http://mayccoll.github.io/Gogh/) y mejoramos la apariencia del perfil > *Columnas 115 > Filas 35 > Fira Mono 11*

### Git

Para configurar un archivo *gitignore* de forma global:

  ```
  cd ~
  curl -O https://raw.githubusercontent.com/ctrbts/my-dev-setup/master/dotfiles/.gitignore
  git config --global core.excludesfile ~/.gitignore
  ```

### Zsh

Instalamos  con `sudo apt install curl git zsh -y` y luego cambiamos el shell por defecto con `chsh -s $(which zsh)`, una vez instalado *zsh* eliminar los archivos *bash* y *profile*

Luego cerrar sesión y volver a entrar. Cuando iniciemps por primera vez la terminal nos va a preguntar por el archivo de configuración, elegimo la opción 0 y continuamos.

[Oh My ZSH](https://ohmyz.sh/) es un framework con una gran comunidad detrás con muchos temas y plugins para añadir funcionalidad a ZSH, para instalarlo: `sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"`

OhMyZsh tiene muchos plugins, los que mas uso son:

**git** que viene instalado por defecto y añade un montón de alias de git **common-aliases** Añade ciertos alias interesantes, entre ellos: G para añadir | grep al final de un comando

**colored-man** colorea las páginas del manual.

**extract** permite descomprimir cualquier tipo de archivo comprimido de una forma común: `x nombre-fichero-comprimido`

**zsh-autosuggestions** este plugin busca en el historial tus últimos comandos y te va autocompletando los mismos.

Para instalarlo: `git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions`

**zsh-syntax-highlighting** este plugin colorea los comandos en verde o en rojo dependiendo de si son correctos o no.

Para instalarlo: `git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting`

Para activarlos hay que modificar el fichero de configuración *~/.zshrc*:

```
plugins=(
  git
  common-aliases
  extract
  colored-man-pages
  zsh-autosuggestions
  zsh-syntax-highlighting
)
```

## Node.js

La manera recomendada para instalar [Node.js](http://nodejs.org/) es con [nvm](https://github.com/creationix/nvm) (Node Version Manager) que nos permite administrar multiples versiones de Node.js en la misma máquina.

Para instalar `nvm` copiamos y pegamos el [install script command](https://github.com/creationix/nvm#install--update-script) en la terminal.

Ahora verificamos las versiones dispinibles de Node `nvm ls-remote --lts`

Instalamos la última LTS `nvm install --lts` o alguna versión específica `nvm install 11.15.0`

El resto de los comandos estan disponibles desde el repositorio de NVM


## Mobile Frameworks

`npm i -g cordova framework7-cli @ionic/cli`


## OpenJDK

Import the official AdoptOpenJDK GPG key by running the following command: `wget -qO - https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public | sudo apt-key add -` > then > Import the AdoptOpenJDK DEB repository by running the following command:
```
sudo apt-get install -y software-properties-common
sudo add-apt-repository --yes https://adoptopenjdk.jfrog.io/adoptopenjdk/deb/
```
Refresh your package list with sudo apt-get update and then install your chosen AdoptOpenJDK package. For example, to install OpenJDK 8 with the HotSpot VM, run: `sudo apt-get install adoptopenjdk-8-hotspot`

## Gradle

Descargamos el binario desde https://gradle.org/next-steps/?version=6.6.1&format=bin > creamos el directorio con `sudo mkdir /opt/gradle` y descomprimimos con `sudo unzip -d /opt/gradle ~/Descargas/gradle-6.6.1-bin.zip`

Add the following lines to your ~/.zshrc) config file:
```
export GRADLE_HOME=/opt/gradle/gradle-6.6.1
export PATH=$PATH:$GRADLE_HOME/bin
```
## Netbeans IDE

Development Environment, Tooling Platform and Application Framework.
To download > https://netbeans.apache.org/download/index.html


## Android Studio

Select the "SDK Platforms" tab from within the SDK Manager, then check the box next to "Show Package Details" in the bottom right corner. Look for and expand the Android 10 (Q) entry, then make sure the following items are checked:

- Android SDK Platform 29
- Intel x86 Atom_64 System Image or Google APIs Intel x86 Atom System Image

Next, select the "SDK Tools" tab and check the box next to "Show Package Details" here as well. Look for and expand the **Android SDK Build-Tools** entry, then make sure that **29.0.2** is selected.

Finally, click "Apply" to download and install the Android SDK and related build tools.

Add the following lines to your ~/.zshrc) config file:
```
export ANDROID_HOME=$HOME/android-sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools
```
