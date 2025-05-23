# Mi Ubuntu Development Setup

_Actualizado para Ubuntu 24.04_

- [Configuración inicial](#configuración-inicial)
  - [Actualizar el sistema](maintenance-ubuntu.md)
  - [Gestores de paquetes y utilidades](#gestores-de-paquetes-y-utilidades)
  - [Terminal](#terminal)
  - [Zsh](#zsh)
- [Node.js](#node)
  - [Node modules](#Node-modules)
- [Java Stack](#java-stack)
  - [OpenJDK](#openjdk)
  - [Netbeans IDE](#netbeans-ide)
- [Android Stack](#android-stack)
  - [Gradle](#gradle)
  - [Android Studio](#android-studio)
- [LEMP Stack](#lemp)
- [LAMPP Stack](#lampp)
  - [Apache](#apache)
    - [Base de datos](#base-de-datos)
        - [MariaDB](#mariadb)
        - [MySQL](#mysql)
        - [PostgreSQL](#postgresql)
  - [PHP](#php)
  - [Crear un host virtual](#crear-un-host-virtual)
- [Docker](#docker)

## Configuración inicial

Primero tenemos que [actualizar el sistema](maintenance-ubuntu.md)

### Gestores de paquetes y utilidades

Agregamos herramientas de personalización, un gestor de paquetes y soporte para Flatpak y (solo escritorio)

    sudo apt install gnome-tweaks dconf-editor -y
    sudo apt install synaptic menu deborphan apt-xapian-index tasksel -y
    sudo apt install flatpak gnome-software-plugin-flatpak -y && sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

Algunas otras configuraciones necesarias

### Terminal

Como vamos a pasar bastante tiempo en la terminal le vamos a dar un toque de color y productividad.

La tipografía de la terminal es muy importante para mejorar la legilibilidad y evitar el cansancio visual. Las mejores fuentes para codificar son [Fira Code, Fira Mono](https://fonts.google.com/?query=fira) y [JetBrains Mono](https://fonts.google.com/specimen/JetBrains+Mono?query=jetb).

El esquema de color **Gnome Oscuro** es uno de mis preferidos pero podemos instalar unos temas excelentes desde [Gogh Themes](https://gogh-co.github.io/Gogh/) y mejoramos la apariencia del perfil > _Columnas 120 > Filas 40_

### Zsh

Bash esta bien, pero ZSH esta mejor. Ya lo instalamos en los [Primeros pasos](#primeros-pasos) ahora necesitamos hacerlo nuestro shell por defecto, ejecutamos desde consola:

    chsh -s $(which zsh)

Una vez configurado _zsh_ podemos eliminar los archivos _.bash_ y _.profile_. Luego cerramos sesión y volvemos a entrar para que los cambios se apliquen, cuando iniciemos por primera vez la terminal nos va a preguntar por el archivo de configuración de zsh, elegimo la opción 0 y continuamos.

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

Para activar los plugins anteriores hay que modificar el fichero de configuración _~/.zshrc_:

    plugins=(
      git
      common-aliases
      extract
      colored-man-pages
      zsh-autosuggestions
      zsh-syntax-highlighting
    )

## Node

La manera recomendada para instalar [Node.js](http://nodejs.org/) es con [nvm](https://github.com/creationix/nvm) (Node Version Manager) que nos permite administrar multiples versiones de Node.js instaladas en el sistema.

Para instalar `nvm` copiamos y pegamos el [install script command](https://github.com/creationix/nvm#install--update-script) en la terminal.

    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

Ahora verificamos las versiones dispinibles de Node

    nvm ls-remote --lts

Instalamos la última LTS

    nvm install --lts

o alguna versión específica con `nvm install 18.20.2`

Para setear por defecto una version de node necesitamos hacer `nvm alias default node`

El resto de los comandos estan disponibles desde el repositorio de NVM

## Node modules

Con node instalado agregamos los frameworks y modulos mas utilizados

    npm i -g cordova framework7-cli @ionic/cli express express-generator yarn nodemon pm2

Podemos actualizar o reinstalar y traernos los node modules de la instalación anterior

    nvm install 'lts/*' --reinstall-packages-from=current

## Java Stack

### OpenJDK

La mejor forma de instalar el jdk de java es desde los repos de ubuntu y nos garantizamos que siempre estarán actualizados (para Ubuntu 24.04_LTS la version por defecto de java es la 21)

    sudo apt install default-jdk -y

Agregamos las siguientes lineas al archivo ~/.zshrc:

    export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
    export PATH=$PATH:$JAVA_HOME/bin

### Netbeans IDE

IDE multiplataforma para desarrollo en Java, PHP y otros lenguajes de programación.
Para descargarlo > https://netbeans.apache.org/download/index.html

## Android Stack

### Gradle

Descargamos el binario desde https://gradle.org/next-steps/?version=8.4&format=bin > creamos el directorio con y descomprimimos el archivo

    sudo mkdir /opt/gradle && sudo unzip -d /opt/gradle ~/Descargas/gradle-8.4-bin.zip

Necesitamos agregar las siguientes lineas al archivo ~/.zshrc:

    export GRADLE_HOME=/opt/gradle/gradle-8.4
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

## LEMP

Descargamos el script automatizado de instalacion
[LEMP Install](https://raw.githubusercontent.com/ctrbts/mi-dev-setup/refs/heads/main/conf/lemp-install.sh)

## LAMPP

### Apache

Instalamos Apache usando el administrador de paquetes de Ubuntu:

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

Podemos restringir el acceso solo a nuestras ips de confianza

    sudo ufw allow from 127.0.0.1/24 to any port 22

Puede verificar el cambio con lo siguiente:

    sudo ufw status

Para realizar una verificación rápida y comprobar que todo se haya realizado correctamente pruebe escribiendo la dirección IP pública de su servidor en su navegador web:

http://public_server_ip

Si puede ver la página predeterminada de Apache para Ubuntu 20.04, su servidor web estará correctamente instalado y el acceso a él será viable a través de su firewall.

Si no conoce la dirección IP pública de su servidor, hay varias formas de encontrarla. Podría usar las herramientas de iproute2 para obtener su dirección IP escribiendo esto:

    ip addr show eth0 | grep inet | awk '{ print $2; }' | sed 's/\/.*$//'

Esto le brindará dos o tres líneas. Todas estas direcciones son correctas, pero su computadora solo puede usar una de ellas. No dude en probarlas todas.

Un método alternativo consiste en usar la utilidad curl para contactar a una webe externa con el fin de que le indique su evaluación del servidor. Esto se hace solicitando a un servidor específico su dirección IP:

    curl http://icanhazip.com

Independientemente del método que utilice para obtener su dirección IP, escríbala en la barra de direcciones de su navegador web para ver la página predeterminada de Apache.

### MariaDB

Actualizamos el índice de paquetes, instalamos el paquete de mariadb-server, ejecutamos `mysql_secure_installation` para restringir el acceso al servidor

    sudo apt install mariadb-server -y && sudo mysql_secure_installation

Luego verá una serie de solicitudes mediante las cuales podrá realizar cambios en las opciones de seguridad de su instalación de MariaDB. En la primera solicitud se pedirá que introduzca la contraseña root de la base de datos actual. Debido a que no configuramos una aún, pulse ENTER para indicar “none” (ninguna). Para las siguientes puede seguir la guía a continuación:

    Enter current password for root (enter for none): Solo presione Enter
    Switch to unix_socket authentication [Y/n]: n
    Change root password? [Y/n]: n
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

Abrimos el puerto necesario para permitir el tráfico desde el servidor:

    sudo ufw allow 3306/tcp

Si MariaDB no funciona, puede iniciarla con el comando `sudo systemctl start mariadb`

### PHP

Instalamos PHP con los adds mas comunes

    sudo apt install libapache2-mod-php php php-common php-mbstring php-imap php-xmlrpc php-soap php-gd php-xml php-intl php-mysql php-pgsql php-fpdf php-cli php-bcmath php-zip php-curl php-xdebug composer -y

Para confirmar que todo esta instalado ok ejecutamos `php -v`

Abrimos el archivo de configuración de PHP para configurar OPCahe con el siguiente comando:

    sudo nano /etc/php/8.3/apache2/php.ini

Descomentamos las siguientes líneas:

    opcache.enable=1
    opcache.memory_consumption=128
    opcache.max_accelerated_files=10000
    opcache.revalidate_freq=2

Ya que tenemos el php.ini abierto agregamos las opciones de depuración (muy útil para VSCode) las siguientes líneas al final:

    [XDebug]
    xdebug.mode = debug
    xdebug.start_with_request = yes
    zend_extension = xdebug

Guardar y reiniciaar Apache:

    sudo systemctl restart apache2

Se puede verificar el estado de OPcache con:

    php -i | grep opcache

#### Crear un host virtual

Ubuntu tiene habilitado un bloque de servidor por defecto, que está configurado para proporcionar documentos del directorio /var/www/html. Si bien esto funciona bien para un solo sitio, puede ser difícil de manejar si alojamos varios. En lugar de modificar /var/www/html, crearemos una estructura de directorio dentro de /var/www para el host virtual y dejaremos /var/www/html establecido como directorio predeterminado que se presentará si una solicitud de cliente no coincide con ningún otro sitio.

Cree el directorio de la siguiente manera:

_reemplace **vhost** con el nombre de su dominio_

    sudo mkdir /var/www/vhost

A continuación, asigne la propiedad del directorio con la variable de entorno $USER, que hará referencia a su usuario de sistema actual:

    sudo chown -R $USER:$USER /var/www/vhost

Para facilitar la administración del sitio web, añadimos nuestro usuario al grupo www-data.

    sudo usermod -a -G www-data $USER

Luego, abra un nuevo archivo de configuración en el directorio sites-available de Apache usando el editor de línea de comandos que prefiera. En este caso, utilizaremos nano:

    sudo nano /etc/apache2/sites-available/vhost.conf

De esta manera, se creará un nuevo archivo en blanco. Pegue la siguiente configuración básica:

    <VirtualHost *:80>

        ServerName vhost
        ServerAlias www.vhost
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/vhost

        <Directory /var/www/vhost>
            Options Indexes FollowSymLinks
            AllowOverride All
            Require all granted
        </Directory>

        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined

    </VirtualHost>

Con esta configuración de VirtualHost, le indicamos a Apache que proporcione vhost usando /var/www/vhost como directorio root web. Si desea probar Apache sin un nombre de dominio, puede eliminar o convertir en comentario las opciones ServerName y ServerAlias añadiendo un carácter # al principio de las líneas de cada opción.

Ahora, puede usar a2ensite para habilitar el nuevo host virtual:

    sudo a2ensite vhost

Luego deberá reiniciar apache con:

    sudo systemctl reload apache2

Puede ser conveniente deshabilitar el sitio web predeterminado que viene instalado con Apache. Es necesario hacerlo si no se utiliza un nombre de dominio personalizado, dado que, en este caso, la configuración predeterminada de Apache sobrescribirá su host virtual. Para deshabilitar el sitio web predeterminado de Apache, escriba lo siguiente:

    sudo a2dissite 000-default

Para asegurarse de que su archivo de configuración no contenga errores de sintaxis, ejecute lo siguiente:

    sudo apache2ctl configtest

Por último, vuelva a cargar Apache para que estos cambios surtan efecto:

    sudo systemctl reload apache2

Ahora, su nuevo sitio web está activo, pero el directorio root web /var/www/vhost todavía está vacío. Cree un archivo index.php en esa ubicación para poder probar que el host virtual funcione según lo previsto:

    nano /var/www/vhost/index.php

Incluya el siguiente contenido en este archivo:

    <?php

    // Función para obtener el contenido de un directorio
    function obtenerContenido($directorio)
    {
      $archivos = array();
      $carpetas = array();

      // Abrir el directorio
      $dir = opendir($directorio);

      // Leer cada elemento del directorio
      while ($elemento = readdir($dir)) {
        // Si es un archivo
        if (is_file($directorio . "/" . $elemento)) {
          $archivos[] = $elemento;
        }
        // Si es una carpeta
        elseif (is_dir($directorio . "/" . $elemento) && $elemento != "." && $elemento != "..") {
          $carpetas[] = $elemento;
        }
      }

      // Cerrar el directorio
      closedir($dir);

      // Ordenar alfabeticamente
      sort($archivos);
      sort($carpetas);

      return array($carpetas, $archivos);
    }

    // Obtener el contenido del directorio actual
    $contenido = obtenerContenido(".");

    ?>

    <!DOCTYPE html>
    <html lang="es">

    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Servidor local</title>
      <style>
        body {
          font-family: Arial, sans-serif;
          margin: 20px;
          text-align: center;
        }

        .titulo {
          font-size: 36px;
          font-weight: 300;
        }

        .subtitulo {
          font-size: 24px;
          font-weight: 300;
        }

        .columnas {
          display: flex;
          justify-content: center;
        }

        ul {
          list-style: none;
          padding: 0;
          margin: 0.75rem;
          width: 15rem;
        }

        li {
          border: 1px solid #ddd;
          padding: 8px;
          margin-bottom: 8px;
        }

        li:hover {
          background-color: #f1f1f1;
          font-weight: bold;
        }

        a {
          color: #000;
          cursor: pointer;
          text-decoration: none;
        }
      </style>
    </head>

    <body>
      <p class="titulo">Servidor local</p>
      <div class="columnas">
        <ul>
          <p class="subtitulo">Carpetas</p>
          <?php
          // Mostrar las carpetas
          foreach ($contenido[0] as $carpeta) {
            echo "<a href=\"$carpeta\"><li>$carpeta</li></a>";
          }
          ?>
        </ul>
        <ul>
          <p class="subtitulo">Archivos</p>
          <?php
          // Mostrar los archivos
          foreach ($contenido[1] as $archivo) {
            if ($archivo !== 'index.php') {
              echo "<a href=\"$archivo\"><li>$archivo</li></a>";
            }
          }
          ?>
        </ul>
      </div>
    </body>

    </html>

Ahora, diríjase a su navegador y acceda al nombre de dominio o la dirección IP de su servidor una vez más:

http://public_server_ip

_Nota sobre DirectoryIndex en Apache
Con la configuración predeterminada de DirectoryIndex en Apache, un archivo denominado index.html siempre tendrá prioridad sobre un archivo index.php. Esto es útil para establecer páginas de mantenimiento en aplicaciones PHP, dado que se puede crear un archivo index.html temporal que contenga un mensaje informativo para los visitantes. Como esta página tendrá precedencia sobre la página index.php, se convertirá en la página de destino de la aplicación. Una vez que el mantenimiento se completa, el archivo index.html se puede eliminar del root (o cambierle el nombre) para volver mostrar la página habitual de la aplicación._

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

    nano /var/www/vhost/info.php

Con esto se abrirá un archivo vacío. Añada el siguiente texto, que es el código PHP válido, dentro del archivo:

    <?php phpinfo();

Si el directorio de trabajo esta en `home` asegurarse que los directorios en la ruta de tu DocumentRoot y cualquier otro directorio relevante tengan los permisos adecuados.

chmod +x /home
chmod +x /home/tu_usuario
chmod +x /home/tu_usuario/vhost

Para probar esta secuencia de comandos, diríjase a su navegador web y acceda al nombre de dominio o la dirección IP de su servidor, seguido del nombre de la secuencia de comandos, que en este caso es info.php:

http://vhost_o_IP/info.php

## Bases de datos

### MySQL

Instalamos MySql con el comando

    sudo apt install mysql-server -y

Confirmamos qu eeste corriendo

    sudo systemctl status mysql.service

Iniciamos sesión en la consola

    sudo mysql

Establecemos la contraseña de root

    ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'root';

Aseguramos la instalación de MySQL ya que por defecto presenta algunas fallas de seguridad, para esto ejecutamos

    sudo mysql_secure_installation

Ingresamos la contraseña de root, en la parte inicial ingresamos la letra "n" para no cambiar la contraseña de root. Luego ingresamos en todos los campos la letra "y"

Accedemos ahora a mysql

    mysql -u root -p

Y creamos un usuario con privilegios en todas las bases

    CREATE USER 'admin'@'localhost' IDENTIFIED BY 'password';
    GRANT ALL PRIVILEGES ON *.* TO 'admin'@'localhost';

### PostgreSQL

Instalamos los paquetes necesarios

    sudo apt install postgresql postgresql-contrib postgresql-client

Vamos a manejar la seguridad a nivel de base de datos y de sistema.
Restringimos el acceso a los archivos de configuración solo al propietario del archivo

    sudo chmod 600 -R /etc/postgresql/16/main/pg_hba.conf
    sudo chmod 600 -R /etc/postgresql/16/main/postgresql.conf

Abribos el archivo `postgresql.conf`para editarlo

Descomentamos la ínea: `listen_address = 'localhost'` para habilitar el acceso local al administrador. Y agregamo seguridad adicional habilitando el cifrado scram-256 desomentando `password_encryption=scram-sha-256`

Ahora abrimos `pg_hba.conf` y reemplazamos el metodo de cifrado en la linea:  
`local  all all peer`, reemplazamos _peer_ por _scram-sha-256_`.

En la línea siguiente podemos establecer una máscara de red específica para que acceda a la base de datos, solamente reemplazamos 127.0.0.1 por el mapa de red que queremos permitor (ej. 200.10.20.0/24)

Además agregamos una linea para rechazar cualquier dirección IP que no este gestionada por este archivo

    host   all all all reject

## Docker

Agregamos las claves y el repositorio:

```shell
# Agregar  la Docker's official GPG key:
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Agregamos el repositorio a apt:
echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
```

Instalamos la última versión

```shell
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

Después de instalar agregamos nuestro usuario a Docker para evitar problemas con permisos

```shell
sudo usermod -aG docker $USER
```

Verificamos que la instalacion haya teni éxito corriendo la imágen `hello-world`:

```shell
sudo docker run hello-world
```
