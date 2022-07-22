# Mi Ubuntu Development Setup

- [Configuración inicial](#configuración-inicial)
    - [Gestores de paquetes y utilidades](#gestores-de-paquetes-y-utilidades)
    - [Personalización](#personalización)
    - [Terminal](#terminal)
    - [Zsh](#zsh)
    - [Git](#git)
- [Ubuntu Make](#ubuntu-make)
- [Node.js](#node)
    - [Node modules](#Node-modules)
- [OpenJDK](#openjdk)
- [Gradle](#gradle)
- [Netbeans IDE](#netbeans-ide)
- [Android Studio](#android-studio)
- [LAMPP](#lampp)
    - [Apache](#apache)
    - [MariaDB](#mariadb)
    - [PHP](#php)
    - [Crear un host virtual](#crear-un-host-virtual)

## Configuración inicial

### Gestores de paquetes y utilidades

Actualizamos el sistema y agregamos algunas herramientas necesarias (las configuraremos mas adelante)

    sudo apt update && sudo apt upgrade -y &&
    sudo apt install curl git zsh ssh mc nmap -y
    
Agregamos gestores de paquetes (esto es opcional pero puede ser útil)

    sudo apt install synaptic --install-suggests -y

Agregamos el soporte para flatpak

    sudo apt install flatpak gnome-software-plugin-flatpak -y &&
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

### Personalización
    
    sudo apt install gnome-tweaks -y

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


## Ubuntu Make
Ubuntu Make proporciona un conjunto de funcionalidades para configurar, mantener y personalizar fácilmente su entorno de desarrollador. Manejará todas las dependencias, incluso aquellas que no están en Ubuntu, e instalará las últimas versiones de las herramientas deseadas y recomendadas. Este es el último master de ubuntu-make, recién construido desde https://github.com/ubuntu/ubuntu-make.

    snap install ubuntu-make --classic

Hay una lista completa de todas las funcionalidades en `umake --list` 


## Node

La manera recomendada para instalar [Node.js](http://nodejs.org/) es con [nvm](https://github.com/creationix/nvm) (Node Version Manager) que nos permite administrar multiples versiones de Node.js instaladas en el sistema.

Para instalar `nvm` copiamos y pegamos el [install script command](https://github.com/creationix/nvm#install--update-script) en la terminal.

    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | sh

Ahora verificamos las versiones dispinibles de Node 
    
    nvm ls-remote --lts

Instalamos la última LTS 

    nvm install --lts

o alguna versión específica con `nvm install 14.19.1`

Para setear por defecto una version de node necesitamos hacer `nvm alias default node`

El resto de los comandos estan disponibles desde el repositorio de NVM


## Node modules

Con node instalado agregamos los frameworks y modulos mas utilizados

    npm i -g cordova framework7-cli @ionic/cli express-generator yarn

Podemos actualizar o reinstalar y traernos los node modules de la instalación anterior
    
    nvm install 'lts/*' --reinstall-packages-from=current

## OpenJDK

La mejor forma de instalar el jdk de java es desde los repos de ubuntu y nos garantizamos que siempre estarán actualizados (para Ubuntu 20.04_LTS la version por defecto de java es la 11)

    sudo apt install default-jdk -y 

Agregamos las siguientes lineas al archivo ~/.zshrc:

    export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
    export PATH=$PATH:$JAVA_HOME/bin

## Netbeans IDE

IDE multiplataforma para desarrollo en Java, PHP y otros lenguajes de programación.
Para descargarlo > https://netbeans.apache.org/download/index.html


## Android Stack

### Gradle

Descargamos el binario desde https://gradle.org/next-steps/?version=7.4.2&format=bin > creamos el directorio con y descomprimimos el archivo

    sudo mkdir /opt/gradle && sudo unzip -d /opt/gradle ~/Descargas/gradle-7.4.2-bin.zip

Necesitamos agregar las siguientes lineas al archivo ~/.zshrc:

    export GRADLE_HOME=/opt/gradle/gradle-7.4.2
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

    sudo apt update &&
    sudo apt install apache2 -y
 
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

Abrimos los puertos necesarios para permitir el tráfico en el servidor:

    sudo ufw allow in "Apache Full" &&
    sudo ufw allow in "OpenSSH"
 
Puede verificar el cambio con lo siguiente:

    sudo ufw status
 
Para realizar una verificación rápida y comprobar que todo se haya realizado correctamente pruebe escribiendo la dirección IP pública de su servidor en su navegador web:

http://your_server_ip

Si puede ver la página predeterminada de Apache para Ubuntu 20.04, su servidor web estará correctamente instalado y el acceso a él será viable a través de su firewall.

Si no conoce la dirección IP pública de su servidor, hay varias formas de encontrarla. Podría usar las herramientas de iproute2 para obtener su dirección IP escribiendo esto:

    ip addr show eth0 | grep inet | awk '{ print $2; }' | sed 's/\/.*$//'
 
Esto nos brindará dos o tres líneas. Todas estas direcciones son correctas, pero su computadora puede usar una de ellas. No dude en probarlas todas.

Un método alternativo consiste en usar la utilidad curl para contactar a una webe externa con el fin de que le indique su evaluación del servidor. Esto se hace solicitando a un servidor específico su dirección IP:

    curl http://icanhazip.com
 
Independientemente del método que utilice para obtener su dirección IP, escríbala en la barra de direcciones de su navegador web para ver la página predeterminada de Apache.

### MariaDB

Actualizamos el índice de paquetes, instalamos el paquete de mariadb-server, ejecutamos `mysql_secure_installation` para restringir el acceso al servidor

    sudo apt update &&
    sudo apt install mariadb-server -y &&
    sudo mysql_secure_installation
 
Luego verá una serie de solicitudes mediante las cuales podrá realizar cambios en las opciones de seguridad de su instalación de MariaDB. En la primera solicitud se pedirá que introduzca la contraseña root de la base de datos actual. Debido a que no configuramos una aún, pulse ENTER para indicar “none” (ninguna). Para las siguientes puede seguir la guía a continuación:

    Enter current password for root (enter for none): Solo presione Enter
    Set root password? [Y/n]: n
    Remove anonymous users? [Y/n]: Y
    Disallow root login remotely? [Y/n]: Y
    Remove test database and access to it? [Y/n]:  Y
    Reload privilege tables now? [Y/n]:  Y

Con eso, ha terminado de realizar la configuración de seguridad inicial de MariaDB. El siguiente paso es autenticar su servidor de MariaDB con una contraseña.

En los sistemas Ubuntu con MariaDB, el root user de MariaDB se configura para autenticar usando el complemento unix_socket por defecto en vez de con una contraseña. Esto proporciona una mayor seguridad y utilidad en muchos casos, pero también puede generar complicaciones cuando necesita otorgar derechos administrativos a un programa externo (por ejemplo, phpMyAdmin).

Debido a que el servidor utiliza la cuenta root para tareas como la rotación de registros y el inicio y la detención del servidor, es preferible no cambiar la autenticación root de la cuenta. La modificación de las credenciales del archivo de configuración en /etc/mysql/debian.cnf pueden funcionar al principio, pero las actualizaciones posteriores de paquetes pueden sobrescribir esos cambios. En vez de modificar la cuenta root, los mantenedores de paquetes recomiendan crear una cuenta administrativa independiente para el acceso basado en contraseña.

Para hacerlo, crearemos una nueva cuenta con las mismas capacidades que la cuenta root, pero configurada para la autenticación por contraseña. Abra la línea de comandos de MariaDB desde su terminal:

    sudo mariadb
 
A continuación, cree un nuevo usuario con privilegios root y acceso basado en contraseña. Asegúrese de cambiar el nombre de usuario y la contraseña para que se adapten a sus necesidades (puede cambiar 'localhost' por el comodin '%' para acceso remoto):

    GRANT ALL ON *.* TO 'su_usuario'@'localhost' IDENTIFIED BY 'su_password' WITH GRANT OPTION;
 
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

Abrimos el puerto necesario para permitir el tráfico desde el servidor:

    sudo ufw allow 3306/tcp

Si MariaDB no funciona, puede iniciarla con el comando `sudo systemctl start mariadb`

### PHP 

Instalamos PHP con los adds mas comunes
    
    sudo apt install libapache2-mod-php php php-common php-mbstring php-imap php-xmlrpc php-soap php-gd php-xml php-intl php-mysql php-fpdf php-cli php-zip php-curl php-opcache -y

Para confirmar que todo esta instalado ok ejecutamos `php -v`

Abrimos el archivo de configuración de PHP para configurar OPCahe con el siguiente comando:

    sudo nano /etc/php/7.4/apache2/php.ini

Descomentamos las siguientes líneas:

    opcache.enable=1
    opcache.memory_consumption=128
    opcache.max_accelerated_files=10000
    opcache.revalidate_freq=2

Guardar y reiniciaar Apache:

    sudo systemctl restart apache2

Se puede verificar el estado de OPcache con:

    php -i | grep opcache

#### Crear un host virtual

Ubuntu 20.04 tiene habilitado un bloque de servidor por defecto, que está configurado para proporcionar documentos del directorio /var/www/html. Si bien esto funciona bien para un solo sitio, puede ser difícil de manejar si alojamos varios. En lugar de modificar /var/www/html, crearemos una estructura de directorio dentro de /var/www para el sitio su_dominio y dejaremos /var/www/html establecido como directorio predeterminado que se presentará si una solicitud de cliente no coincide con ningún otro sitio.

Cree el directorio para su_dominio de la siguiente manera:

    sudo mkdir /var/www/su_dominio
 
A continuación, asigne la propiedad del directorio con la variable de entorno $USER, que hará referencia a su usuario de sistema actual:

    sudo chown -R $USER:$USER /var/www/su_dominio
 
Luego, abra un nuevo archivo de configuración en el directorio sites-available de Apache usando el editor de línea de comandos que prefiera. En este caso, utilizaremos nano:

    sudo nano /etc/apache2/sites-available/su_dominio.conf
 
De esta manera, se creará un nuevo archivo en blanco. Pegue la siguiente configuración básica:
    
    <VirtualHost *:80>

        ServerName su_dominio
        ServerAlias www.su_dominio
        ServerAdmin webmaster@localhost
        DocumentRoot "/var/www/su_dominio"

        <Directory "/var/www/su_dominio">
            Options Indexes FollowSymLinks
            AllowOverride All
            Require all granted
        </Directory>

        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined

    </VirtualHost>
 
Con esta configuración de VirtualHost, le indicamos a Apache que proporcione su_dominio usando /var/www/su_dominio como directorio root web. Si desea probar Apache sin un nombre de dominio, puede eliminar o convertir en comentario las opciones ServerName y ServerAlias añadiendo un carácter # al principio de las líneas de cada opción.

Ahora, puede usar a2ensite para habilitar el nuevo host virtual:

    sudo a2ensite su_dominio

Luego deberá reiniciar apache con:

    sudo systemctl reload apache2
    
Puede ser conveniente deshabilitar el sitio web predeterminado que viene instalado con Apache. Es necesario hacerlo si no se utiliza un nombre de dominio personalizado, dado que, en este caso, la configuración predeterminada de Apache sobrescribirá su host virtual. Para deshabilitar el sitio web predeterminado de Apache, escriba lo siguiente:

    sudo a2dissite 000-default
 
Para asegurarse de que su archivo de configuración no contenga errores de sintaxis, ejecute lo siguiente:

    sudo apache2ctl configtest
 
Por último, vuelva a cargar Apache para que estos cambios surtan efecto:

    sudo systemctl reload apache2
 
Ahora, su nuevo sitio web está activo, pero el directorio root web /var/www/su_dominio todavía está vacío. Cree un archivo index.html en esa ubicación para poder probar que el host virtual funcione según lo previsto:

    nano /var/www/su_dominio/index.html
 
Incluya el siguiente contenido en este archivo:

    <h1>Bienvenido</h1>
    <p>el servidor para <strong>su_dominio</strong> esta online!</p>
 
Ahora, diríjase a su navegador y acceda al nombre de dominio o la dirección IP de su servidor una vez más:

http://server_domain_or_IP

*Nota sobre DirectoryIndex en Apache
Con la configuración predeterminada de DirectoryIndex en Apache, un archivo denominado index.html siempre tendrá prioridad sobre un archivo index.php. Esto es útil para establecer páginas de mantenimiento en aplicaciones PHP, dado que se puede crear un archivo index.html temporal que contenga un mensaje informativo para los visitantes. Como esta página tendrá precedencia sobre la página index.php, se convertirá en la página de destino de la aplicación. Una vez que el mantenimiento se completa, el archivo index.html se puede eliminar del root (o cambierle el nombre) para volver mostrar la página habitual de la aplicación.*

Si desea cambiar este comportamiento, deberá editar el archivo /etc/apache2/mods-enabled/dir.conf y modificar el orden en el que el archivo index.php se enumera en la directiva DirectoryIndex:

sudo nano /etc/apache2/mods-enabled/dir.conf
 
/etc/apache2/mods-enabled/dir.conf
<IfModule mod_dir.c>
        DirectoryIndex index.php index.html index.cgi index.pl index.xhtml index.htm
</IfModule>
 
Después de guardar y cerrar el archivo, deberá volver a cargar Apache para que los cambios surtan efecto:

    sudo systemctl reload apache2

Nos aseguramos que los módulos headers y rewrite esten disponibles

    cd /etc/apache2/mods-enabled/ &&
    sudo ln -s ../mods-available/headers.load headers.load &&
    sudo ln -s ../mods-available/rewrite.load rewrite.load &&
    sudo service apache2 restart

Paso 4: Probar el procesamiento de PHP en su servidor web
Ahora que dispone de una ubicación personalizada para alojar los archivos y las carpetas de su sitio web, crearemos una secuencia de comandos PHP de prueba para verificar que Apache pueda gestionar solicitudes y procesar solicitudes de archivos PHP.

Cree un archivo nuevo llamado info.php dentro de su carpeta root web personalizada:

    nano /var/www/su_dominio/info.php
 
Con esto se abrirá un archivo vacío. Añada el siguiente texto, que es el código PHP válido, dentro del archivo:

    <?php phpinfo();

Para probar esta secuencia de comandos, diríjase a su navegador web y acceda al nombre de dominio o la dirección IP de su servidor, seguido del nombre de la secuencia de comandos, que en este caso es info.php:

http://su_dominio_o_IP/info.php
