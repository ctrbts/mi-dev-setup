# Mi Ubuntu Development Setup

- [Primeros pasos](#primeros-pasos)
- [Terminal](#terminal)
- [Gestores de paquetes](#gestores-de-paquetes)
- [Zsh](#zsh)
- [Git](#git)
- [Node.js](#node)
- [Mobile Frameworks](#mobile-frameworks)
- [OpenJDK](#openjdk)
- [Gradle](#gradle)
- [Netbeans IDE](#netbeans-ide)
- [Android Studio](#android-studio)
- [Configurar un servidor FTP](#configurar-un-servidor-ftp)

## Primeros pasos

Actualizamos el sistema, instalamos un gestor de paquetes y las herramientas necesarias

    sudo apt update && sudo apt upgrade -y &&
    sudo apt install curl git zsh -y &&
    snap install ubuntu-make --classic

<!--     
    sudo apt install gnome-software gnome-software-plugin-flatpak -y &&
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo &&
    sudo apt install synaptic --install-suggests -y
 -->
 
Algunas otras configuraciones necesarias

En **nautilus** vamos a las Preferencias > Comportamiento > Archivo de texto ejecutables y seleccionamos *Preguntar que hacer*.

El tamaño de iconos yo lo dejo en 67% por comodidad visual y la tipografía en no mas de 10, dependiento el tamaño de pantalla.

## Terminal

Como vamos a pasar bastante tiempo en la terminal le vamos a dar un toque de color y productividad.

Descargamos e instalamos desde [Google Fonts](https://fonts.google.com/?query=fira) las fuentes Fira Code, Fira Mono y Fira Sans.

Instalamos un nuevo tema desde [Gogh Themes](http://mayccoll.github.io/Gogh/) y mejoramos la apariencia del perfil > *Columnas 120 > Filas 35 > Fira Mono 9*

## Zsh

Bash esta bien, pero ZSH es mejor. Si ya lo instalamos en los [Primeros pasos](#primeros-pasos) necesitamos cambiar el shell por defecto con 

    chsh -s $(which zsh)

una vez instalado *zsh* podemos eliminar los archivos *.bash* y *.profile*

Luego de cerrar sesión y volver a entrar, cuando iniciemos por primera vez la terminal nos va a preguntar por el archivo de configuración de zsh, elegimo la opción 0 y continuamos.

[Oh My ZSH](https://ohmyz.sh/) es un framework con una gran comunidad detrás con muchos temas y plugins para añadir funcionalidad a ZSH, para instalarlo: 

    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

OhMyZsh tiene muchos plugins, los que mas uso son:

**git** que viene instalado por defecto y añade un montón de alias de git **common-aliases** Añade ciertos alias interesantes, entre ellos: G para añadir | grep al final de un comando

**colored-man** colorea las páginas del manual.

**extract** permite descomprimir cualquier tipo de archivo comprimido de una forma simple con: `x nombre-fichero-comprimido`

**zsh-autosuggestions** este plugin busca en el historial tus últimos comandos y te va autocompletando los mismos.

**zsh-syntax-highlighting** este plugin colorea los comandos en verde o en rojo dependiendo de si son correctos o no.

Para instalar estos ultimos debemos descargarlo al directorio de plugins con: 

    git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions && 
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting

Para activar los plugins anteriores hay que modificar el fichero de configuración *~/.zshrc*:

    plugins=(
      git
      common-aliases
      extract
      colored-man-pages
      zsh-autosuggestions
      zsh-syntax-highlighting
    )

## Git

Ya tenemos git instalado, ahora vamos a configurar un archivo *gitignore* de forma global que nos va ha permitir exluir archivos de sistema comunes:

    cd ~
    curl -O https://raw.githubusercontent.com/ctrbts/my-dev-setup/master/dotfiles/.gitignore
    git config --global core.excludesfile ~/.gitignore

## Node

La manera recomendada para instalar [Node.js](http://nodejs.org/) es con [nvm](https://github.com/creationix/nvm) (Node Version Manager) que nos permite administrar multiples versiones de Node.js instaladas en el sistema.

Para instalar `nvm` copiamos y pegamos el [install script command](https://github.com/creationix/nvm#install--update-script) en la terminal.

Ahora verificamos las versiones dispinibles de Node 
    
    nvm ls-remote --lts

Instalamos la última LTS 

    nvm install --lts

o alguna versión específica con `nvm install 12.15.0`

El resto de los comandos estan disponibles desde el repositorio de NVM


### Mobile Frameworks

Con node instalado agregamos los frameworks de desarrollo hibrido mas utilizados

    npm i -g cordova framework7-cli @ionic/cli


## OpenJDK

Importamos la clave GPG oficial del repositorio de AdoptOpenJDK con el siguiente comando: 

    wget -qO - https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public | sudo apt-key add -

Luego, importamos el repositrio DEB:

    sudo apt-get install -y software-properties-common &&
    sudo add-apt-repository --yes https://adoptopenjdk.jfrog.io/adoptopenjdk/deb/

Actualizamos la lista de paquetes com `sudo apt-get update` e instalamos el paquete AdoptOpenJDK elejido. Por ejemplo, para instalar OpenJDK 8 con HotSpot VM, ponemos lo siguiente: `sudo apt-get install adoptopenjdk-11-hotspot -y`


## Gradle

Descargamos el binario desde https://gradle.org/next-steps/?version=7.1.1&format=bin > creamos el directorio con `sudo mkdir /opt/gradle` y descomprimimos con `sudo unzip -d /opt/gradle ~/Descargas/gradle-7.1.1-bin.zip`

Agregamos las siguientes lineas al archivo ~/.zshrc:

    export GRADLE_HOME=/opt/gradle/gradle-7.1.1
    export PATH=$PATH:$GRADLE_HOME/bin

## Netbeans IDE

IDE multiplataforma para desarrollo en Java, PHP y otros lenguajes de programación.
Para descargarlo > https://netbeans.apache.org/download/index.html


## Android Studio

Android Studio proporciona las herramientas más rápidas para crear aplicaciones en todo tipo de dispositivo Android.
Descarga desde > https://developer.android.com/studio

Configurando el SDK: Seleccionamos la pestaña "Plataformas SDK" desde el Administrador de SDK, luego marcamos la casilla junto a "Mostrar detalles del paquete" en la esquina inferior derecha. Buscamos y expandimos la entrada de Android 10 (Q), luego nos aseguramos de que los siguientes elementos estén marcados:

- Android SDK Platform 29
- Intel x86 Atom_64 System Image or Google APIs Intel x86 Atom System Image

A continuación, seleccionamos la pestaña "Herramientas SDK" y marcamos la casilla junto a "Mostrar detalles del paquete". Buscamos y expandimos la entrada **Android SDK Build-Tools**, luego nos aseguramos que **29.0.2** esté seleccionado.

Finalmente, clic en "Aplicar" para descargar e instalar el SDK de Android y las herramientas de compilación relacionadas.

Agregue las siguientes líneas a su archivo de configuración ~/.zshrc:

    export ANDROID_HOME=$HOME/android-sdk
    export PATH=$PATH:$ANDROID_HOME/emulator
    export PATH=$PATH:$ANDROID_HOME/tools
    export PATH=$PATH:$ANDROID_HOME/tools/bin
    export PATH=$PATH:$ANDROID_HOME/platform-tools

---
Continuara ...
