# Mi Ubuntu Development Setup

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

Actualizamos el sistema, instalamos un gestor de paquetes y las herramientas necesarias

```
sudo apt update && sudo apt upgrade -y
sudo apt install gnome-software gnome-software-plugin-flatpak -y
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
sudo apt install synaptic --install-suggests -y
sudo apt install curl git -y
```

Algunas otras configuraciones necesarias

En **nautilus** vamos a las Preferencias > Comportamiento > Archivo de texto ejecutables y seleccionamos *Preguntar que hacer*.

El tamaño de iconos yo lo dejo en 67% por comodidad visual y la tipografía en no mas de 10, dependiento el tamaño de pantalla.

## Terminal

Como vamos a pasar bastante tiempo en la terminal le vamos a dar un toque de color y productividad.

Descargamos e instalamos desde [Google Fonts](https://fonts.google.com/?query=fira) las fuentes Fira Code, Fira Mono y Fira Sans.

Instalamos un nuevo tema desde [Gogh Themes](http://mayccoll.github.io/Gogh/) y mejoramos la apariencia del perfil > *Columnas 115 > Filas 35 > Fira Mono 11*

### Git

Ya tenemos git instalado, ahora vamos a configurar un archivo *gitignore* de forma global:

  ```
  cd ~
  curl -O https://raw.githubusercontent.com/ctrbts/my-dev-setup/master/dotfiles/.gitignore
  git config --global core.excludesfile ~/.gitignore
  ```

### Zsh

Bash esta bien, pero ZSH es mejor. Para instalarlo desde la terminal escribimos `sudo apt install curl git zsh -y` y luego cambiamos el shell por defecto con `chsh -s $(which zsh)`, una vez instalado *zsh* podemos eliminar los archivos *.bash* y *.profile*

Luego cerrar sesión y volver a entrar. Cuando iniciemos por primera vez la terminal nos va a preguntar por el archivo de configuración de zsh, elegimo la opción 0 y continuamos.

[Oh My ZSH](https://ohmyz.sh/) es un framework con una gran comunidad detrás con muchos temas y plugins para añadir funcionalidad a ZSH, para instalarlo: `sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"`

OhMyZsh tiene muchos plugins, los que mas uso son:

**git** que viene instalado por defecto y añade un montón de alias de git **common-aliases** Añade ciertos alias interesantes, entre ellos: G para añadir | grep al final de un comando

**colored-man** colorea las páginas del manual.

**extract** permite descomprimir cualquier tipo de archivo comprimido de una forma común: `x nombre-fichero-comprimido`

**zsh-autosuggestions** este plugin busca en el historial tus últimos comandos y te va autocompletando los mismos.

Para instalarlo: `git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions`

**zsh-syntax-highlighting** este plugin colorea los comandos en verde o en rojo dependiendo de si son correctos o no.

Para instalarlo: `git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting`

Para activar los plugins anteriores hay que modificar el fichero de configuración *~/.zshrc*:

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

La manera recomendada para instalar [Node.js](http://nodejs.org/) es con [nvm](https://github.com/creationix/nvm) (Node Version Manager) que nos permite administrar multiples versiones de Node.js instaladas en el sistema.

Para instalar `nvm` copiamos y pegamos el [install script command](https://github.com/creationix/nvm#install--update-script) en la terminal.

Ahora verificamos las versiones dispinibles de Node `nvm ls-remote --lts`

Instalamos la última LTS `nvm install --lts` o alguna versión específica con `nvm install 11.15.0`

El resto de los comandos estan disponibles desde el repositorio de NVM


### Mobile Frameworks

Con node instalado agregamos los frameworks de desarrollo hibrido mas utilizados

`npm i -g cordova framework7-cli @ionic/cli`


## OpenJDK

Importamos la clave GPG oficial del repositorio de AdoptOpenJDK con el siguiente comando: `wget -qO - https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public | sudo apt-key add -` > luego > Importamos el repositrio DEB:
```
sudo apt-get install -y software-properties-common
sudo add-apt-repository --yes https://adoptopenjdk.jfrog.io/adoptopenjdk/deb/
```
Actualizamos la lista de paquetes com `sudo apt-get update` e instalamos el paquete AdoptOpenJDK elejido. Por ejemplo, para instalar OpenJDK 8 con HotSpot VM, ponemos lo siguiente: `sudo apt-get install adoptopenjdk-8-hotspot`


## Gradle

Descargamos el binario desde https://gradle.org/next-steps/?version=6.6.1&format=bin > creamos el directorio con `sudo mkdir /opt/gradle` y descomprimimos con `sudo unzip -d /opt/gradle ~/Descargas/gradle-6.6.1-bin.zip`

Agregamos las siguientes lineas al archivo ~/.zshrc:
```
export GRADLE_HOME=/opt/gradle/gradle-6.6.1
export PATH=$PATH:$GRADLE_HOME/bin
```
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
```
export ANDROID_HOME=$HOME/android-sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools
```

## Configurar un servidor FTP

Instalamos el servicio y configuramos algunos parámetros
```
sudo apt install vsftpd
sudo cp /etc/vsftpd.conf /etc/vsftpd.conf.original
sudo nano /etc/vsftpd.conf
```

Los parámetros que modificaremos:

    listen = YES : Para que se inicie con el sistema.
    anonymous_enable = NO : No permitimos que usuarios anónimos puedan conectarse a nuestro servidor. Es por seguridad.
    local_enable = YES : Para poder conectarse con los usuarios locales del servidor donde está instalado.
    write_enable = YES : Si quieres que los usuarios puedan escribir y no sólo descargar cosas.
    local_umask = 022 : Esta máscara hace que cada vez que subas un archivo, sus permisos sean 755. Es lo más típico en servidores FTP.
    chroot_local_user = YES
    chroot_list_enable = YES : Sirven para que los usuarios locales puedan navegar por todo el árbol de directorios del servidor. Evidentemente esto sólo queremos permitírselo a ciertos usuarios, para ello tenemos el siguiente parámetro.
    chroot_list_file = /etc/vsftpd.chroot_list : Indicamos el fichero donde están listados los usuarios que pueden navegar hacía arriba por los directorios del servidor, lo normal es que sea el administrador del servidor.

Crear grupo de usuario para FTP

    sudo groupadd ftp

Creamos una shell fantasma para que no puedan entrar a la consola del servidor:

    sudo mkdir /bin/ftp

Editamos el listado de shells del sistema:

nano /etc/shells

Agregamos nuestra shell fantasma:

/bin/ftp

Usuario que pertenecerá al grupo FTP

Debemos crear la carpeta del usuario en el servidor, será donde tendrá acceso vía FTP y asignamos los permisos correctos.

mkdir /home/ftp/usuarioftp
chmod -R 777 /home/ftp/usuarioftp

Creamos el usuario que pertenece al grupo FTP

sudo useradd -g ftp -d /home/ftp/usuarioftp -c "Nombre del Usuario" usuarioftp

Entendamos los parámetros que usamos en la línea anterior:

    -g ftp = el usuario pertenece al grupo ftp.
    -d /home/ftp/usuarioftp = El directorio principal del usuario es /home/ftp/usuarioftp.
    -c “Nombre del Usuario” = el nombre completo del usuario.
    usuarioftp = la última palabra será el nombre de usuario

Creamos la contraseña para el usuario:

sudo passwd usuarioftp

Enjaular al usuario

Esto significa que el usuario no podrá escalar en la jerarquía del directorio y solamente se mantendrá en si directorio.

Buscamos nuestro usuario recién creado en:

nano /etc/passwd

Copiamos la línea que podrá verse algo así:

usuarioftp:x:1004:118:Nombre del Usuario:/home/ftp/usuarioftp:/bin/ftp

Luego la pegamos en la última línea de etse archivo:

nano /etc//vsftpd.chroot_list

Una vez realizados todos los cambios reiniciamos el servidor de FTP:

/etc/init.d/vsftpd restart

Ahora ya tenemos un servidor de FTP funcional y con los privilegios adecuados para que nuestros usuario puedan almacenar archivos debidamente separados.



----------------------------------------------


Instalación del servicio FTP con vsftpd

Hemos de decir primero, que el servidor vsftpd, se distribuye bajo licencia libre GNU GPL y puede descargarse de la página oficial de vsftpd.

Vsftpd (Very Secure FTP Daemon), es un servicio FTP que permite implementar servicios de archivos mediante protocolo FTP, caracterizándose principalmente porque se trata de un sistema muy seguro, a la vez que muy sencillo de configurar.

Puedes instalar el paquete correspondiente, al servidor vsftpd, en un ordenador con Ubuntu, desde el terminal, con el siguiente comando:

apt-get install vsftpd

Después de haber instalado el servicio FTP, éste se queda iniciado y se iniciará automáticamente cada vez que arranque el sistema.

El fichero de configuración es muy extenso, por que está autodocumentado con muchos comentarios, para ver el documento, desde el terminal, ponemos el siguiente comando:

cat /etc/vsftpd.conf

En este caso, para quitarse paja de encima, podemos ver las opciones activas usando grep, pidiendo las lineas que no comiencen por #:

cat /etc/vsftpd.conf | grep -v “^#”

El resultado, es este:

listen=YES
anonymous_enable=NO
local_enable=YES
dirmessage_enable=YES
use_localtime=YES
xferlog_enable=YES
connect_from_port_20=YES
secure_chroot_dir=/var/run/vsftpd/empty
pam_service_name=vsftpd
rsa_cert_file=/etc/ssl/private/vsftpd.pem

En la configuración inicial, no se permite el acceso anónimo y si el acceso mediante las cuentas de usuarios locales del sistema. Los demás parámetros, los describiremos más adelante.
Como añadir usuarios

Para poder probar las conexiones, a parte de nuestro usuario personal, vamos a crear otro:

useradd -d /home/prueba -m -s /bin/bash prueba

Y le proporcionamos una clave

passwd prueba

El cliente gráfico Filezilla

Por otro lado, además del servicio FTP, es necesario para los otros usuarios, instalar un cliente, que permita acceder al servicio. El software Filezilla Client, es un cliente gráfico FTP. Es un software multiplataforma desarrollado por Filezilla-Project, de código abierto y licencia GPL.

Sitio oficial de descarga de Filezilla Client

Para instalar Filezilla Client en GNU/Linux Ubuntu es más recomendable hacerlo a través de la instalación de un paquete debian, ya que la distribución que se puede descargar del sitio oficial es el código fuente del software y necesita compilarse una vez descargado.

El paquete de instalación Filezilla Client para Ubuntu, se llama filezilla. Puedes instalarlo mediante comando o desde el centro de software de ubuntu. Para instalarlo desde el terminal solo tienes que ejecutar el comando,

sudo apt install filezilla

Inicio y parada del servicio FTP

El servicio se gestiona mediante el script /etc/init.d/vsftpd. Se debe de ejecutar como superusuario o utilizando el comando sudo para ejecutarlos. En la administración del servicio podemos iniciarlo, detenerlo, reiniciarlo o comprobar su estado.

Administración del servicio vsftpd con script:
Acción 	Comando
/etc/init.d/vsftpd
status 	Comprobar
el estado del servicio
/etc/init.d/vsftpd
stop 	Detener
el servicio
/etc/init.d/vsftpd
start 	Iniciar
el servicio
/etc/init.d/vsftpd
restart 	Reiniciar
el servicio

También podemos usar el comando service, para administrar el servicio sabiendo que el nombre con el que se reconoce al servicio de Ubuntu es vsftpd.

Administración del servicio vsftpd con el comando service:
Acción 	Comando
Service vsftp status 	Comprobar el estado del servicio
Service vstfpd stop 	Detener
el servicio
Service vsftpd start 	Iniciar
el servicio
Service vsftpd restart 	Reiniciar
el servicio

Cuando está iniciado vsftpd, el servicio debe de estar escuchando en el puerto 21. Puedes comprobarlo con el comando netstat -ltn que hay un servicio en ese puerto 21.
Otros archivos

El archivo /etc/ftpusers contiene una lista de los usuarios del sistema a los que se deniega el acceso mediante ftp. Entre esos usuarios, se deniega el acceso al usuario root como medida de seguridad.

El archivo /var/log/vsftpd.log registra la información sobre las conexiones ftp establecidas. Es importante consultar este archivo para resolver cualquier incidencia producida durante las conexiones o para hacer una evaluación del comportamiento del servicio.
Enjaular Usuarios

Si los usuarios locales del servidor se conectan remotamente mediante un cliente ftp al servicio ftp podrán acceder a sus carpetas personales y además al resto del sistema de archivos. Esto es peligroso y un fallo de seguridad.

Vamos a explicar, como limitarlos a su carpeta /home/usuario. Este proceso se le llama chroot (enjaular).

Antes de nada vamos a sacar una copia de seguridad del fichero de configuración:

mv /etc/vsftpd.conf /etc/vsftpd.conf.backup

Vamos a dejar limpio el archivo:

cat /etc/vsftpd.conf.backup | grep -v “^#” > /etc/vsftpd.conf

Añadimos al siguiente configuración al final del fichero /etc/vsftpd.conf:

chroot_local_user=YES
chroot_list_enable=YES
chroot_list_file=/etc/vsftpd.chroot_list

A continuación creamos el fichero /etc/vsftpd.chroot_list

nano /etc/vsftpd.chroot_list

Y ponemos nuestro usuario para evitar ser enjaulados.

Por último, reiniciamos el servicio:

restart vsftpd

Al final de este punto, el fichero de configuración debería de estar así:

listen=YES
anonymous_enable=YES
local_enable=YES
dirmessage_enable=YES
use_localtime=YES
xferlog_enable=YES
connect_from_port_20=YES
secure_chroot_dir=/var/run/vsftpd/empty
pam_service_name=vsftpd
rsa_cert_file=/etc/ssl/private/vsftpd.pem
chroot_local_user=YES
chroot_list_enable=YES
chroot_list_file=/etc/vsftpd.chroot_list

Usuarios anónimos

Si se realiza una conexión anónima, se tiene acceso a la carpeta /srv/ftp que será compartida para todos los accesos anónimos.

Se tiene que crear un fichero en esta carpeta:

touch /srv/ftp/hola.txt

Las conexiones anónimas se podrán hacer con los nombres del usuario anonymous y ftp (sin ninguna contraseña).

Editar el fichero de configuración para permitir el acceso a usuarios anónimos:

anonymous_enable=YES

Reiniciar el servicio:

restart vsftpd
