# Mi Ubuntu Development Setup

- [Configuración inicial](#configuración-inicial)
    - [Gestores de paquetes y utilidades](#gestores-de-paquetes-y-utilidades)
    - [Personalización](#personalización)
    - [Terminal](#terminal)
    - [Zsh](#zsh)
    - [Git](#git)
- [Node.js](#node)
- [Mobile Frameworks](#mobile-frameworks)
- [OpenJDK](#openjdk)
- [Gradle](#gradle)
- [Netbeans IDE](#netbeans-ide)
- [Android Studio](#android-studio)
- [LAMPP](#lampp)
    - [Apache](#apache)
    - [MariaDB](#mariadb)
- [Yii Framework](#yii-framework)

## Configuración inicial

### Gestores de paquetes y utilidades

Actualizamos el sistema, agregamos un gestor de paquetes y las herramientas necesarias (algunas las configuraremos mas adelante)

    sudo apt update && sudo apt upgrade -y &&
    sudo apt install curl git zsh -y &&
    sudo apt install synaptic --install-suggests -y &&
    sudo apt install gnome-tweaks gnome-software gnome-software-plugin-flatpak -y &&
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

### Personalización

Algunas otras configuraciones necesarias

En **nautilus** vamos a las Preferencias > Comportamiento > Archivo de texto ejecutables y seleccionamos *Preguntar que hacer*. Esto evita que el sistema por defecto abra algunos archivos ejecutables como si fueran archivos de texto.

El tamaño de iconos yo lo dejo en 67% por comodidad visual y la tipografía en no mas de 10, dependiento el tamaño de pantalla.


### Terminal

Como vamos a pasar bastante tiempo en la terminal le vamos a dar un toque de color y productividad.

La tipografía de la terminal muy importante para mejorar la legilibilidad y evitar el cansancio visual. Las mejores fuentes para codificar son [Fira Code, Fira Mono](https://fonts.google.com/?query=fira) y [Cascadia Code](https://github.com/microsoft/cascadia-code/releases).

El esquema de color **Tango Oscuro** es uno de mis preferidos pero podemos instalar unos temas excelentes desde [Gogh Themes](http://mayccoll.github.io/Gogh/) y mejoramos la apariencia del perfil > *Columnas 120 > Filas 40 > Fira Mono 9*


### Zsh

Bash esta bien, pero ZSH esta mejor. Ya lo instalamos en los [Primeros pasos](#primeros-pasos) ahora necesitamos hacerlo nuestro shell por defecto, ejecutamos desde consola: 

    chsh -s $(which zsh)

Una vez configurado *zsh* podemos eliminar los archivos *.bash* y *.profile*. Luego cerramos sesión y volvemos a entrar para que los cambios se apliquen, cuando iniciemos por primera vez la terminal nos va a preguntar por el archivo de configuración de zsh, elegimo la opción 0 y continuamos.

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


### Git

Ya tenemos git instalado, ahora vamos a configurar un archivo *gitignore* de forma global que nos va ha permitir exluir archivos de sistema comunes:

    cd ~
    curl -O https://raw.githubusercontent.com/ctrbts/my-dev-setup/master/dotfiles/.gitignore
    git config --global core.excludesfile ~/.gitignore


## Node

La manera recomendada para instalar [Node.js](http://nodejs.org/) es con [nvm](https://github.com/creationix/nvm) (Node Version Manager) que nos permite administrar multiples versiones de Node.js instaladas en el sistema.

Para instalar `nvm` copiamos y pegamos el [install script command](https://github.com/creationix/nvm#install--update-script) en la terminal.

    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | sh


Ahora verificamos las versiones dispinibles de Node 
    
    nvm ls-remote --lts

Instalamos la última LTS 

    nvm install --lts

o alguna versión específica con `nvm install 12.15.0`

Para setear por defecto una version de node necesitamos hacer `nvm alias default node`

El resto de los comandos estan disponibles desde el repositorio de NVM


## Node modules

Con node instalado agregamos los frameworks y modulos mas utilizados

    npm i -g cordova framework7-cli @ionic/cli express-generator yarn


## OpenJDK

La mejor forma de instalar el jdk de java es desde los repos de ubuntu y nos garantizamos que siempre estarán actualizados

    sudo apt update && sudo apt install openjdk-11-jdk -y 

Agregamos las siguientes lineas al archivo ~/.zshrc:

    export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
    export PATH=$PATH:$JAVA_HOME/bin

## Netbeans IDE

IDE multiplataforma para desarrollo en Java, PHP y otros lenguajes de programación.
Para descargarlo > https://netbeans.apache.org/download/index.html


## Android Stack

### Gradle

Descargamos el binario desde https://gradle.org/next-steps/?version=7.1.1&format=bin > creamos el directorio con y descomprimimos el archivo

    sudo mkdir /opt/gradle && sudo unzip -d /opt/gradle ~/Descargas/gradle-7.1.1-bin.zip

Necesitamos agregar las siguientes lineas al archivo ~/.zshrc:

    export GRADLE_HOME=/opt/gradle/gradle-7.1.1
    export PATH=$PATH:$GRADLE_HOME/bin


### Android Studio

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

## LAMPP

### Apache

Instalamos Apache usando el administrador de paquetes de Ubuntu:

    sudo apt update
    sudo apt install apache2
 
Una vez que la instalación se complete, deberá ajustar la configuración de su firewall para permitir tráfico HTTP y HTTPS. 
Si UFW no esta habilitado pude hacerlo con 

    sudo ufw enable
    
Para enumerar todos los perfiles de aplicaciones de UFW disponibles, puede ejecutar lo siguiente:

    sudo ufw app list
 
Verá un resultado como este:

    Output
    Available applications:
      Apache
      Apache Full
      Apache Secure
      OpenSSH

Para permitir tráfico únicamente en el puerto 80 utilice el perfil Apache:

    sudo ufw allow in "Apache"
 
Puede verificar el cambio con lo siguiente:

    sudo ufw status
 
Ahora, se permite tráfico en el puerto 80 a través del firewall.

Puede realizar una verificación rápida para comprobar que todo se haya realizado según lo previsto dirigiéndose a la dirección IP pública de su servidor en su navegador web (consulte la nota de la siguiente sección para saber cuál es su dirección IP pública si no dispone de esta información):

http://your_server_ip

Si puede ver la página web predeterminada de Apache para Ubuntu 20.04, su servidor web estará correctamente instalado y el acceso a él será posible a través de su firewall.

Si no conoce la dirección IP pública de su servidor, hay varias formas de encontrarla. Por lo general, es la dirección que utiliza para establecer conexión con su servidor a través de SSH.

Existen varias formas de hacerlo desde la línea de comandos. Primero, podría usar las herramientas de iproute2 para obtener su dirección IP escribiendo esto:

    ip addr show eth0 | grep inet | awk '{ print $2; }' | sed 's/\/.*$//'
 
Esto nos brindará dos o tres líneas. Todas estas direcciones son correctas, pero su computadora puede usar una de ellas. No dude en probarlas todas.

Un método alternativo consiste en usar la utilidad curl para contactar a una parte externa a fin de que le indique su evaluación del servidor. Esto se hace solicitando a un servidor específico su dirección IP:

    curl http://icanhazip.com
 
Independientemente del método que utilice para obtener su dirección IP, escríbala en la barra de direcciones de su navegador web para ver la página predeterminada de Apache.

### MariaDB

Actualizamos el índice de paquetes, instalamos el paquete de mariadb-server, ejecutamos `mysql_secure_installation` para restringir el acceso al servidor

    sudo apt update &&
    sudo apt install mariadb-server -y &&
    sudo mysql_secure_installation
 
Luego verá una serie de solicitudes mediante las cuales podrá realizar cambios en las opciones de seguridad de su instalación de MariaDB. En la primera solicitud se pedirá que introduzca la contraseña root de la base de datos actual. Debido a que no configuramos una aún, pulse ENTER para indicar “none” (ninguna).

    Output
    NOTE: RUNNING ALL PARTS OF THIS SCRIPT IS RECOMMENDED FOR ALL MariaDB
          SERVERS IN PRODUCTION USE!  PLEASE READ EACH STEP CAREFULLY!

    In order to log into MariaDB to secure it, we'll need the current
    password for the root user.  If you've just installed MariaDB, and
    you haven't set the root password yet, the password will be blank,
    so you should just press enter here.

    Enter current password for root (enter for none):

En la siguiente solicitud se pregunta si desea configurar una contraseña root de base de datos. En Ubuntu, la cuenta root para MariaDB está estrechamente vinculada al mantenimiento del sistema automatizado. Por lo tanto, no deberíamos cambiar los métodos de autenticación configurados para esa cuenta. Hacer esto permitiría que una actualización de paquetes dañara el sistema de bases de datos eliminando el acceso a la cuenta administrativa. Escriba N y pulse ENTER.

    Output
    . . .
    OK, successfully used password, moving on...

    Setting the root password ensures that nobody can log into the MariaDB
    root user without the proper authorisation.

    Set root password? [Y/n] N

A partir de allí, puede pulsar Y y luego ENTER para aceptar los valores predeterminados para todas las preguntas siguientes. Con esto, se eliminarán algunos usuarios anónimos y la base de datos de prueba, se deshabilitarán las credenciales de inicio de sesión remoto de root y se cargarán estas nuevas reglas para que MariaDB aplique de inmediato los cambios que realizó.

Con eso, ha terminado de realizar la configuración de seguridad inicial de MariaDB. El siguiente paso es autenticar su servidor de MariaDB con una contraseña.

En los sistemas Ubuntu con MariaDB 10.03, el root user de MariaDB se configura para autenticar usando el complemento unix_socket por defecto en vez de con una contraseña. Esto proporciona una mayor seguridad y utilidad en muchos casos, pero también puede generar complicaciones cuando necesita otorgar derechos administrativos a un programa externo (por ejemplo, phpMyAdmin).

Debido a que el servidor utiliza la cuenta root para tareas como la rotación de registros y el inicio y la deteneción del servidor, es mejor no cambiar los detalles de autenticación root de la cuenta. La modificación de las credenciales del archivo de configuración en /etc/mysql/debian.cnf puede funcionar al principio, pero las actualizaciones de paquetes pueden sobrescribir esos cambios. En vez de modificar la cuenta root, los mantenedores de paquetes recomiendan crear una cuenta administrativa independiente para el acceso basado en contraseña.

Para hacerlo, crearemos una nueva cuenta llamada admin con las mismas capacidades que la cuenta root, pero configurada para la autenticación por contraseña. Abra la línea de comandos de MariaDB desde su terminal:

    sudo mariadb
 
A continuación, cree un nuevo usuario con privilegios root y acceso basado en contraseña. Asegúrese de cambiar el nombre de usuario y la contraseña para que se adapten a sus preferencias:

    GRANT ALL ON *.* TO 'admin'@'localhost' IDENTIFIED BY 'password' WITH GRANT OPTION;
 
Vacíe los privilegios para garantizar que se guarden y estén disponibles en la sesión actual:

    FLUSH PRIVILEGES;
 
Después de esto, cierre el shell de MariaDB:

    exit
 

Cuando se instale desde los repositorios predeterminados, MariaDB se ejecutará automáticamente. Para probar esto, compruebe su estado.

    sudo systemctl status mariadb
 
Recibirá un resultado que es similar al siguiente:

    Output
    ● mariadb.service - MariaDB 10.3.22 database server
         Loaded: loaded (/lib/systemd/system/mariadb.service; enabled; vendor preset: enabled)
         Active: active (running) since Tue 2020-05-12 13:38:18 UTC; 3min 55s ago
           Docs: man:mysqld(8)
                 https://mariadb.com/kb/en/library/systemd/
       Main PID: 25914 (mysqld)
         Status: "Taking your SQL requests now..."
          Tasks: 31 (limit: 2345)
         Memory: 65.6M
         CGroup: /system.slice/mariadb.service
                 └─25914 /usr/sbin/mysqld
    . . .

Si MariaDB no funciona, puede iniciarla con el comando `sudo systemctl start mariadb`


## [Yii Framework](https://www.yiiframework.com/doc/guide/2.0/es/start-installation)

Yii es un framework PHP rápido, seguro y eficiente. Flexible pero pragmático. Funciona de inmediato. Y un conjunto de valores predeterminados razonables.

Instalando via Composer:

    curl -sS https://getcomposer.org/installer | php
    sudo mv composer.phar /usr/local/bin/composer

Si ya tienes composer instalado, asegúrate de tener una versión actualizada. Puedes actualizar Composer ejecutando el comando 

    composer self-update

Instalamos las dependencias necesarias

    sudo apt install php-mbstring php-xml

Instalar Yii ejecutando los siguientes comandos en un directorio accesible vía Web:

    composer create-project --prefer-dist yiisoft/yii2-app-basic mi_aplicacion
    
Verificamos la instalación ejecutando el siguiente comando
    
    cd mi_aplicacion && php yii serve

Y accedemos a la aplicación instalada de Yii en la siguiente URL:

http://localhost:8080/.
