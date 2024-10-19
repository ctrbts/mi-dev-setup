# Configuración inicial del servidor con Ubuntu LTS

*actualizado a Ubuntu 24.04*

Paso 1: Iniciar sesión como root
Para iniciar sesión en su servidor, deberá conocer la dirección IP pública de este. También necesitará la contraseña o, si instaló una clave SSH para la autenticación, la clave privada para la cuenta del root user. Si aún no inició sesión en su servidor, quizá desee seguir nuestra guía sobre cómo establecer conexión con Droplets mediante SSH, que cubre con detalle este proceso.

Si aún no está conectado con su servidor, inicie sesión como root user usando ahora el siguiente comando (sustituya la parte resaltada del comando por la dirección IP pública de su servidor):

    ssh root@ip_de_su_servidor

Acepte la advertencia sobre la autenticidad del host si aparece. Si utiliza la autenticación con contraseña, proporcione su contraseña root para iniciar sesión. Si utiliza una clave SSH protegida con una frase de contraseña, es posible que se le solicite ingresar esta última la primera vez que utilice la clave en cada sesión. Si es la primera vez que inicia sesión en el servidor con una contraseña, puede que también se le solicite cambiar la contraseña root.

Acerca de root
El root user es el usuario administrativo en un entorno Linux y tiene privilegios muy amplios. Debido a estos privilegios mayores de la cuenta root, no se recomienda usarla de manera regular. Esto se debe a que parte del poder inherente de la cuenta root es la capacidad de realizar cambios muy destructivos, incluso por accidente.

El siguiente paso es configurar una nueva cuenta de usuario con menos privilegios para el uso cotidiano. Más tarde, le enseñaremos cómo obtener más privilegios solo durante los momentos en que los necesite.

Paso 2: Crear un nuevo usuario
Una vez que haya iniciado sesión como root, estaremos preparados para añadir la nueva cuenta de usuario. En el futuro, iniciaremos sesión con esta nueva cuenta en vez de con root.

En este ejemplo se crea un nuevo usuario llamado su_usuario, pero debe sustituirlo por cualquier nombre de usuario que prefiera:

    adduser su_usuario

Se le harán algunas preguntas, comenzando con la contraseña de la cuenta.

Introduzca una contraseña segura y, opcionalmente, complete la información adicional si lo desea. Esto no es obligatorio y puede pulsar ENTER en cualquier campo que desee omitir.

Paso 3: Conceder privilegios administrativos
Ahora, tenemos una nueva cuenta de usuario con privilegios de una cuenta regular. Sin embargo, a veces necesitaremos realizar tareas administrativas.

Para evitar tener que cerrar la sesión de nuestro usuario normal y volver a iniciar sesión como cuenta root, podemos configurar lo que se conoce como “superusuario” o privilegios root para nuestra cuenta normal. Esto permitirá a nuestro usuario normal ejecutar comandos con privilegios administrativos anteponiendo la palabra sudo a cada comando.

Para añadir estos privilegios a nuestro nuevo usuario, debemos agregarlo al grupo sudo. Por defecto, en Ubuntu 24.04, los usuarios que son miembros del grupo sudo pueden usar el comando sudo.

Como root, ejecute este comando para añadir su nuevo usuario al grupo sudo (sustituya el nombre de usuario resaltado por su nuevo usuario):

    usermod -aG sudo su_usuario

Ahora, cuando inicie sesión como usuario normal, puede escribir sudo antes de los comandos para realizar acciones con privilegios de superusuario.

Paso 4: Configurar un firewall básico
Los servidores Ubuntu 24.04 pueden usar el firewall UFW para garantizar que solo se permiten las conexiones con ciertos servicios. Podemos configurar un firewall básico fácilmente usando esta aplicación.

Nota: Si sus servidores están funcionan con DigitalOcean, puede usar de manera opcional los firewalls en la nube de DigitalOcean en lugar del firewall UFW. Recomendamos usar solo un firewall a la vez para evitar reglas conflictivas que pueden ser difíciles de depurar.

Las aplicaciones pueden registrar sus perfiles con UFW tras la instalación. Estos perfiles permiten a UFW gestionar estas aplicaciones por su nombre. OpenSSH, el servicio que nos permite conectar con nuestro servidor ahora, tiene un perfil registrado con UFW.

Puede ver esto escribiendo lo siguiente:

    ufw app list

    Output
    Available applications:

    OpenSSH

Debemos asegurarnos que el firewall permite conexiones SSH de forma que podamos iniciar sesión de nuevo la próxima vez. Podemos permitir estas conexiones escribiendo lo siguiente:

    ufw allow OpenSSH

Posteriormente, podemos habilitar el firewall escribiendo:

    ufw enable

Escriba y y pulse INTRO para continuar. Puede ver que las conexiones SSH aún están permitidas escribiendo lo siguiente:

    ufw status

    Output
    Status: active

    To                         Action      From
    --                         ------      ----
    OpenSSH                    ALLOW       Anywhere
    OpenSSH (v6)               ALLOW       Anywhere (v6)

Ya que el firewall está bloqueando actualmente todas las conexiones excepto SSH, si instala y configura servicios adicionales, deberá ajustar la configuración del firewall para permitir el tráfico entrante. Puede obtener más información sobre algunas operaciones comunes de UFW en nuestra guía Puntos esenciales de UFW.

Paso 5: Habilitar el acceso externo para su usuario normal
Ahora que tenemos un usuario regular para el uso cotidiano, debemos asegurarnos que podemos realizar SSH en la cuenta directamente.

Nota: Mientras no verifique que pueda iniciar sesión y usar sudo con su nuevo usuario, le recomendamos permanecer conectado como root. De esta manera, si tiene problemas, puede resolverlos y realizar cualquier cambio necesario como root. Si utiliza un Droplet de DigitalOcean y experimenta problemas con su conexión SSH de root, puede iniciar sesión en el Droplet usando la consola de DigitalOcean.

El proceso para configurar el acceso SSH de su nuevo usuario depende de que en la cuenta root de su servidor se utilicen una contraseña o claves SSH para la autenticación.

Si en la cuenta root se utiliza la autenticación con contraseña
Si inició sesión en su cuenta root usando una contraseña, entonces la autenticación con contraseña estará habilitada para SSH. Puede aplicar SSH en su nueva cuenta de usuario abriendo una nueva sesión de terminal y usando SSH con su nuevo nombre de usuario:

    ssh su_usuario@ip_de_su_servidor

Después de ingresar la contraseña de su usuario normal, iniciará sesión. Recuerde que si necesita ejecutar un comando con privilegios administrativos debe escribir sudo antes de este, como se muestra a continuación:

    sudo command_to_run

Se le solicitará la contraseña de su usuario normal cuando utilice sudo por primera vez en cada sesión (y periódicamente después).

Para mejorar la seguridad de su servidor, le recomendamos enfáticamente establecer claves de SSH en lugar de usar la autenticación con contraseña. Siga nuestra guía de configuración de claves de SSH en Ubuntu 24.04 para aprender a configurar la autenticación basada en claves.

Si en la cuenta root se utiliza la autenticación con clave SSH
Si inició sesión en su cuenta root usando claves SSH, la autenticación con contraseña estará desactivada para SSH. Para iniciar sesión correctamente deberá añadir una copia de su clave pública local al archivo ~/.ssh/authorized_keys del nuevo usuario.

Debido a que su clave pública ya está en el archivo ~/.ssh/authorized_keys de la cuenta root, podemos copiar esa estructura de archivos y directorios a nuestra nueva cuenta de usuario en nuestra sesión existente.

El medio más sencillo para copiar los archivos con la propiedad y los permisos adecuados es el comando rsync. Con este, se copiará el directorio .ssh del usuario root, se conservarán los permisos y se modificarán los propietarios de archivos; todo a través de un solo comando. Asegúrese de cambiar las porciones resaltadas del comando que se muestra a continuación para que coincida con el nombre de su usuario normal:

Nota: El comando rsync trata de manera diferente las fuentes y destinos que tienen una barra diagonal al final respecto de aquellos que no la tienen. Al usar rsync a continuación, asegúrese de que en el directorio de origen (~/.ssh) no se incluya una barra diagonal al final (verifique que no esté usando ~/.ssh/).

Si accidentalmente añade una barra diagonal al final del comando, en rsync se copiará el contenido del directorio ~/.ssh de la cuenta root al directorio principal del usuario sudo en lugar de la estructura de directorios completa ~/.ssh. Los archivos se encontrarán en la ubicación equivocada y SSH no podrá encontrarlos ni utilizarlos.

    rsync --archive --chown=su_usuario:su_usuario ~/.ssh /home/su_usuario

Ahora, abra una nueva sesión terminal en su equipo local, y utilice SSH con su nuevo nombre de usuario:

    ssh su_usuario@ip_de_su_servidor

Su sesión de la nueva cuenta de usuario deberá iniciarse sin contraseña. Recuerde que si necesita ejecutar un comando con privilegios administrativos debe escribir sudo antes de este, como se muestra a continuación:

    sudo command_to_run

Se le solicitará la contraseña de su usuario normal cuando utilice sudo por primera vez en cada sesión (y periódicamente después).