# Mi Windows Development Setup
(en construcción)

- [Gestores de paquetes](#gestores-de-paquetes)
- [Git](#git)
- [Zsh](#zsh)
- [Node.js](#node.js)
- [Mobile Frameworks](#mobile-frameworks)
- [OpenJDK](#openjdk)
- [Gradle](#gradle)
- [Netbeans IDE](#netbeans-ide)
- [Android Studio](#android-studio)

### Gestores de paquetes

[Chocolatey](https://chocolatey.org/)

### Git

[Git](https://git-scm.com/)

Para configurar un archivo *gitignore* de forma global:

  ```
  cd ~
  curl -O https://raw.githubusercontent.com/ctrbts/my-dev-setup/master/dotfiles/.gitignore
  git config --global core.excludesfile ~/.gitignore
  ```

### Zsh

Ahora vamos a agregar ZSH y OhMyZsh siguiendo [esta guía][instalar zsh]:

- macOS `brew install zsh`

  Editar el archivo /etc/shells y añadir la ruta /usr/local/bin/zsh al final de la lista: `sudo nano /etc/shells`

  Cambiamos la shell por defecto:`chsh -s /usr/local/bin/zsh`

Luego cerrar sesión y volver a entrar. Cuando iniciemps por primera vez la terminal nos va a preguntar por el archivo de configuración, elegimo la opción 0 y continuamos.

[Oh My ZSH][omz] es un framework con una gran comunidad detrás con muchos temas y plugins para añadir funcionalidad a ZSH.

Para instalarlo: `sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"`

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

Reiniciamos la terminal y comprobamos se ejecute correctamente con `command -v nvm`

Ahora verificamos las versiones dispinibles de Node `nvm ls-remote --lts`

Instalamos la última LTS `nvm install --lts` o alguna versión específica `nvm install 11.15.0`

El resto de los comandos estan disponibles desde el repositorio de NVM


## Mobile Frameworks

`npm i -g cordova framework7-cli @ionic/cli`


## OpenJDK

Instalamos el ***JDK*** desde https://adoptopenjdk.net/installation.html#installers

## Gradle

## Netbeans IDE

Development Environment, Tooling Platform and Application Framework.
To download > https://netbeans.apache.org/download/index.html

## Android Studio

Select the "SDK Platforms" tab from within the SDK Manager, then check the box next to "Show Package Details" in the bottom right corner. Look for and expand the Android 10 (Q) entry, then make sure the following items are checked:

- Android SDK Platform 29
- Intel x86 Atom_64 System Image or Google APIs Intel x86 Atom System Image

Next, select the "SDK Tools" tab and check the box next to "Show Package Details" here as well. Look for and expand the **Android SDK Build-Tools** entry, then make sure that **29.0.2** is selected.

Finally, click "Apply" to download and install the Android SDK and related build tools.

## Referencias

[instalar zsh]: https://www.asanzdiego.com/2018/04/instalar-y-configurar-zsh-y-ohmyzsh-en-ubuntu.html
[omz]: https://ohmyz.sh/
