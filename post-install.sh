#!/bin/bash

# Este script realiza configuraciones post-instalación:
# 1. Crear usuarios administrativos para bases de datos (MariaDB/MySQL, PostgreSQL).
# 2. Crear un VirtualHost de Apache (/var/www/vhost) que apunta a una carpeta
#    de desarrollo en el directorio home del usuario (DEV_HOST) y crea un index.php.

# Asegurar ejecución como root
if [[ "$EUID" -ne 0 ]]; then
    echo "Por favor, ejecuta este script como root."
    exit 1
fi

echo # Salto de línea
echo "=== SCRIPT DE CONFIGURACIÓN POST-INSTALACIÓN ==="
echo # Salto de línea

# --- Funciones Auxiliares ---
confirm_action() {
    local message=$1
    read -p "¿Desea $message? (s/n): " confirm
    if [[ "$confirm" == "s" ]]; then
        return 0 # Sí
    else
        return 1 # No
    fi
}

# Obtener el usuario no root que ejecutó sudo (o el usuario actual)
get_sudo_user() {
    if [ -n "$SUDO_USER" ] && [ "$SUDO_USER" != "root" ]; then
        echo "$SUDO_USER"
    else
        DEFAULT_USER=$(logname 2>/dev/null)
        read -p "Ingrese el nombre de usuario para el directorio de desarrollo (por defecto: ${DEFAULT_USER:-$(whoami)}): " user_input
        echo "${user_input:-${DEFAULT_USER:-$(whoami)}}"
    fi
}

# --- Configuración de Usuarios de Bases de Datos ---
configure_db_users() {
    echo "--- Configuración de Usuarios de Bases de Datos ---"
    if ! confirm_action "configurar un usuario administrativo para alguna base de datos"; then
        echo "Omitiendo configuración de usuarios de base de datos."
        return
    fi

    echo "Seleccione la base de datos:"
    echo "1) MariaDB / MySQL"
    echo "2) PostgreSQL"
    read -p "Opción [1]: " db_type
    db_type=${db_type:-1}

    read -p "Ingrese el nombre del nuevo usuario administrativo para la base de datos: " db_user_new
    if [ -z "$db_user_new" ]; then
        echo "Nombre de usuario no válido. Abortando creación de usuario de BD."
        return
    fi
    read -sp "Ingrese la contraseña para '$db_user_new': " db_pass_new
    echo
    if [ -z "$db_pass_new" ]; then
        echo "Contraseña no puede estar vacía. Abortando creación de usuario de BD."
        return
    fi

    if [[ $db_type -eq 1 ]]; then # MariaDB / MySQL
        if ! command -v mysql &>/dev/null; then
            echo "Error: El comando 'mysql' no se encontró. ¿MariaDB o MySQL están instalados?"
            return
        fi
        read -p "Permitir acceso para '$db_user_new' desde localhost (l) o cualquier host (%)? [l para localhost / % para cualquier host]: " db_host_choice
        db_host_new=""
        if [[ "$db_host_choice" == "%" ]]; then
            db_host_new="%"
        else
            db_host_new="localhost" # Default o si es 'l'
        fi

        echo "Intentando configurar usuario '$db_user_new'@'$db_host_new' en MariaDB/MySQL usando 'sudo mysql'..."

        # Crear los comandos SQL
        # Primero, intentar eliminar el usuario si ya existe para evitar el error 1396
        SQL_DROP_USER_IF_EXISTS="DROP USER IF EXISTS '$db_user_new'@'$db_host_new';"
        SQL_CREATE_USER="CREATE USER '$db_user_new'@'$db_host_new' IDENTIFIED BY '$db_pass_new';"
        SQL_GRANT_PRIVS="GRANT ALL PRIVILEGES ON *.* TO '$db_user_new'@'$db_host_new' WITH GRANT OPTION;"
        SQL_FLUSH_PRIVS="FLUSH PRIVILEGES;"

        # Ejecutar los comandos usando sudo mysql -e
        echo "Paso 1: Intentando eliminar el usuario si ya existe (DROP USER IF EXISTS)..."
        if sudo mysql -e "$SQL_DROP_USER_IF_EXISTS"; then
            echo "Comando DROP USER IF EXISTS ejecutado (esto es normal incluso si el usuario no existía)."
        else
            echo "Advertencia: El comando DROP USER IF EXISTS falló o tuvo problemas. Se continuará con CREATE USER."
        fi

        echo "Paso 2: Intentando crear el usuario (CREATE USER)..."
        if sudo mysql -e "$SQL_CREATE_USER"; then
            echo "Usuario '$db_user_new'@'$db_host_new' creado."
            echo "Paso 3: Otorgando privilegios (GRANT PRIVILEGES)..."
            if sudo mysql -e "$SQL_GRANT_PRIVS"; then
                echo "Privilegios otorgados."
                echo "Paso 4: Refrescando privilegios (FLUSH PRIVILEGES)..."
                if sudo mysql -e "$SQL_FLUSH_PRIVS"; then
                    echo "Usuario '$db_user_new'@'$db_host_new' configurado exitosamente con todos los privilegios."
                else
                    echo "Error en FLUSH PRIVILEGES. Los privilegios podrían no estar activos inmediatamente."
                    echo "Intente ejecutar manualmente: FLUSH PRIVILEGES;"
                fi
            else
                echo "Error al otorgar privilegios al usuario '$db_user_new'@'$db_host_new'."
                echo "Compruebe si el usuario se creó correctamente y luego intente otorgar privilegios manualmente:"
                echo "  GRANT ALL PRIVILEGES ON *.* TO '$db_user_new'@'$db_host_new' WITH GRANT OPTION;"
                echo "  FLUSH PRIVILEGES;"
            fi
        else
            echo "Error al crear el usuario '$db_user_new'@'$db_host_new' (CREATE USER)."
            echo "Esto podría suceder si el comando DROP USER IF EXISTS falló y el usuario ya existía con una configuración incompatible,"
            echo "o si hay algún otro problema con la sintaxis o permisos."
            echo "Comandos que puedes intentar ejecutar manualmente en la consola de MariaDB/MySQL (accediendo con 'sudo mysql' o 'sudo mariadb'):"
            echo "  $SQL_DROP_USER_IF_EXISTS"
            echo "  $SQL_CREATE_USER"
            echo "  $SQL_GRANT_PRIVS"
            echo "  $SQL_FLUSH_PRIVS"
        fi

    elif [[ $db_type -eq 2 ]]; then # PostgreSQL
        if ! command -v psql &>/dev/null; then
            echo "Error: El comando 'psql' no se encontró. ¿PostgreSQL está instalado?"
            return
        fi
        echo "Intentando crear usuario '$db_user_new' en PostgreSQL..."
        # Para PostgreSQL, CREATE USER fallará si el usuario existe.
        # Podríamos hacer DROP USER IF EXISTS también.
        SQL_DROP_PG_USER_IF_EXISTS="DROP USER IF EXISTS \"$db_user_new\";"
        SQL_CREATE_PG_USER="CREATE USER \"$db_user_new\" WITH PASSWORD '$db_pass_new';"
        SQL_ALTER_PG_USER_SUPERUSER="ALTER USER \"$db_user_new\" WITH SUPERUSER;" # O roles más específicos

        echo "Paso 1: Intentando eliminar el usuario de PostgreSQL si ya existe..."
        sudo -u postgres psql -c "$SQL_DROP_PG_USER_IF_EXISTS" # No verificar el error aquí, es "IF EXISTS"

        echo "Paso 2: Intentando crear el usuario de PostgreSQL..."
        if sudo -u postgres psql -c "$SQL_CREATE_PG_USER"; then
            echo "Usuario '$db_user_new' de PostgreSQL creado."
            echo "Paso 3: Otorgando privilegios de SUPERUSER..."
            if sudo -u postgres psql -c "$SQL_ALTER_PG_USER_SUPERUSER"; then
                echo "Usuario '$db_user_new' configurado como SUPERUSER en PostgreSQL."
                echo "Recuerde que podría necesitar ajustar 'pg_hba.conf' para permitir"
                echo "la conexión de este usuario (ej. usando md5 o scram-sha-256 si no es local con peer auth)."
            else
                echo "Error al convertir a '$db_user_new' en SUPERUSER."
                echo "Intente manualmente: ALTER USER \"$db_user_new\" WITH SUPERUSER;"
            fi
        else
            echo "Error al crear el usuario '$db_user_new' en PostgreSQL."
            echo "Asegúrese de que el usuario 'postgres' existe y que tiene permisos para crear usuarios."
            echo "Intente ejecutar manualmente como usuario 'postgres':"
            echo "  sudo -u postgres psql"
            echo "  $SQL_DROP_PG_USER_IF_EXISTS"
            echo "  $SQL_CREATE_PG_USER"
            echo "  $SQL_ALTER_PG_USER_SUPERUSER"
            echo "  \q"
        fi
    else
        echo "Opción no válida."
    fi
    echo # Salto de línea
}

# --- Configuración de Apache VirtualHost ---
configure_apache_vhost() {
    echo "--- Configuración de Apache VirtualHost ---"
    if ! confirm_action "configurar un VirtualHost de Apache para desarrollo"; then
        echo "Omitiendo configuración de VirtualHost."
        return
    fi

    if ! command -v apache2 &>/dev/null; then
        echo "Error: El comando 'apache2' no se encontró. ¿Apache está instalado?"
        return
    fi

    TARGET_USER=$(get_sudo_user)
    HOME_DIR=$(getent passwd $TARGET_USER | cut -d: -f6)

    if [ -z "$TARGET_USER" ] || [ -z "$HOME_DIR" ]; then
        echo "Error: No se pudo determinar el usuario o su directorio home. Abortando VHost."
        return
    fi

    echo "El VHost apuntará a una carpeta del usuario: $TARGET_USER ($HOME_DIR)"

    read -p "Ingrese el nombre de la carpeta de desarrollo en '$HOME_DIR' [DEV_HOST]: " dev_folder
    dev_folder=${dev_folder:-DEV_HOST}
    DEV_HOST_PATH="$HOME_DIR/$dev_folder"

    read -p "Ingrese el nombre del servidor para el VirtualHost (ej. miweb.local): " vhost_name
    if [ -z "$vhost_name" ]; then
        echo "Nombre de VHost no válido. Abortando."
        return
    fi

    VHOST_DOC_ROOT="/var/www/vhost" # El DocumentRoot será este
    VHOST_CONF_FILE="/etc/apache2/sites-available/$vhost_name.conf"

    # 1. Crear carpeta DEV_HOST si no existe y ajustar permisos
    echo "Creando y configurando $DEV_HOST_PATH..."
    sudo -u "$TARGET_USER" mkdir -p "$DEV_HOST_PATH"
    # Añadir usuario al grupo www-data (si no está ya)
    if ! groups "$TARGET_USER" | grep &>/dev/null '\bwww-data\b'; then
        usermod -aG www-data "$TARGET_USER"
        echo "Usuario $TARGET_USER añadido al grupo www-data. ¡IMPORTANTE! Debe cerrar sesión y volver a iniciarla para que esto surta efecto."
    fi
    # Dar permisos a /home/user para que www-data pueda entrar (x)
    chmod o+x "$HOME_DIR" # Permite a 'otros' (incluyendo www-data) entrar al directorio
    # Dar permisos a DEV_HOST (rwx rwx r-x) y set GID
    chown -R "$TARGET_USER":www-data "$DEV_HOST_PATH"
    sudo -u "$TARGET_USER" chmod -R u=rwx,g=rwx,o=rx "$DEV_HOST_PATH"
    find "$DEV_HOST_PATH" -type d -exec chmod g+s {} \;

    # 2. Crear o recrear /var/www/vhost como enlace simbólico
    echo "Configurando $VHOST_DOC_ROOT como enlace a $DEV_HOST_PATH..."
    if [ -L "$VHOST_DOC_ROOT" ]; then
        echo "$VHOST_DOC_ROOT ya es un enlace simbólico. Se recreará."
        rm "$VHOST_DOC_ROOT"
    elif [ -d "$VHOST_DOC_ROOT" ]; then
        echo "Advertencia: $VHOST_DOC_ROOT ya existe y es un directorio."
        if confirm_action "borrar el directorio $VHOST_DOC_ROOT y reemplazarlo con un enlace simbólico"; then
            rm -rf "$VHOST_DOC_ROOT"
        else
            echo "No se puede continuar con la configuración del VHost. Abortando."
            return
        fi
    elif [ -f "$VHOST_DOC_ROOT" ]; then
        echo "Error: $VHOST_DOC_ROOT existe y es un archivo. Abortando."
        return
    fi

    ln -s "$DEV_HOST_PATH" "$VHOST_DOC_ROOT"
    echo "Enlace simbólico $VHOST_DOC_ROOT creado."

    # 3. Crear archivo de configuración del VHost
    echo "Creando archivo de configuración $VHOST_CONF_FILE..."
    cat <<EOF >"$VHOST_CONF_FILE"
<VirtualHost *:80>
    ServerName $vhost_name
    ServerAlias www.$vhost_name
    ServerAdmin webmaster@$vhost_name
    DocumentRoot $VHOST_DOC_ROOT

    <Directory $VHOST_DOC_ROOT>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/$vhost_name-error.log
    CustomLog \${APACHE_LOG_DIR}/$vhost_name-access.log combined
</VirtualHost>

# Si deseas HTTPS (requiere SSL configurado y certificados):
#<VirtualHost *:443>
#    ServerName $vhost_name
#    ServerAlias www.$vhost_name
#    DocumentRoot $VHOST_DOC_ROOT
#
#    SSLEngine on
#    SSLCertificateFile    /etc/ssl/certs/ssl-cert-snakeoil.pem # o tu certificado real
#    SSLCertificateKeyFile /etc/ssl/private/ssl-cert-snakeoil.key # o tu clave real
#
#    <Directory $VHOST_DOC_ROOT>
#        Options Indexes FollowSymLinks
#        AllowOverride All
#        Require all granted
#    </Directory>
#
#    ErrorLog \${APACHE_LOG_DIR}/$vhost_name-ssl-error.log
#    CustomLog \${APACHE_LOG_DIR}/$vhost_name-ssl-access.log combined
#</VirtualHost>
EOF
    echo "Archivo de configuración creado."

    # 4. Crear archivo index.php en DEV_HOST_PATH
    INDEX_PHP_PATH="$DEV_HOST_PATH/index.php"
    echo "Creando archivo $INDEX_PHP_PATH..."
    cat <<'EOF_PHP' >"$INDEX_PHP_PATH"
<?php

// Función para obtener el contenido de un directorio
function obtenerContenido($directorio)
{
  $archivos = array();
  $carpetas = array();

  // Abrir el directorio
  if (!is_readable($directorio) || !($dir = opendir($directorio))) {
    echo "<p style='color:red;'>Error: No se puede leer el directorio '$directorio'. Verifique los permisos.</p>";
    return array(array(), array());
  }

  // Leer cada elemento del directorio
  while (false !== ($elemento = readdir($dir))) {
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
$directorio_actual = "."; // O podrías usar getcwd();
$contenido = obtenerContenido($directorio_actual);

?>

<!DOCTYPE html>
<html lang="es">

<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Servidor local - <?php echo htmlspecialchars(basename(getcwd())); ?></title>
  <style>
    body {
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif, "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol";
      margin: 20px;
      background-color: #f4f4f4;
      color: #333;
      line-height: 1.6;
    }
    .container {
      max-width: 900px;
      margin: auto;
      background: #fff;
      padding: 20px;
      border-radius: 8px;
      box-shadow: 0 0 10px rgba(0,0,0,0.1);
    }
    .titulo {
      font-size: 2em;
      font-weight: 300;
      text-align: center;
      margin-bottom: 0.5em;
      color: #555;
    }
    .subtitulo {
      font-size: 1.5em;
      font-weight: 300;
      text-align: center;
      margin-top: 1.5em;
      margin-bottom: 0.8em;
      border-bottom: 1px solid #eee;
      padding-bottom: 0.5em;
    }
    .columnas {
      display: flex;
      flex-wrap: wrap;
      justify-content: space-around;
    }
    .columna {
        flex: 1;
        min-width: 250px; /* Para que en pantallas pequeñas se apilen */
        padding: 10px;
    }
    ul {
      list-style: none;
      padding: 0;
      margin: 0;
    }
    li {
      background-color: #f9f9f9;
      border: 1px solid #ddd;
      padding: 10px 15px;
      margin-bottom: 8px;
      border-radius: 4px;
      transition: background-color 0.2s ease-in-out, transform 0.2s ease-in-out;
      word-break: break-all;
    }
    li:hover {
      background-color: #e9e9e9;
      transform: translateY(-2px);
    }
    a {
      color: #007bff;
      cursor: pointer;
      text-decoration: none;
      font-weight: 500;
    }
    a:hover {
      text-decoration: underline;
    }
    .folder-icon::before {
        content: "📁 "; /* Icono de carpeta */
        margin-right: 5px;
    }
    .file-icon::before {
        content: "📄 "; /* Icono de archivo */
        margin-right: 5px;
    }
  </style>
</head>

<body>
  <div class="container">
    <p class="titulo">Servidor Local: <span><?php echo htmlspecialchars(basename(getcwd())); ?></span></p>
    <div class="columnas">
      <div class="columna">
        <p class="subtitulo">Carpetas</p>
        <ul>
          <?php
          // Mostrar las carpetas
          if (empty($contenido[0])) {
            echo "<li>No hay carpetas.</li>";
          } else {
            foreach ($contenido[0] as $carpeta) {
              echo "<li><a href=\"" . htmlspecialchars(rawurlencode($carpeta)) . "/\"><span class='folder-icon'></span>" . htmlspecialchars($carpeta) . "</a></li>";
            }
          }
          ?>
        </ul>
      </div>
      <div class="columna">
        <p class="subtitulo">Archivos</p>
        <ul>
          <?php
          // Mostrar los archivos
          if (empty($contenido[1])) {
            echo "<li>No hay archivos.</li>";
          } else {
            foreach ($contenido[1] as $archivo) {
              if (strtolower($archivo) !== 'index.php') { // No mostrar el propio index.php
                echo "<li><a href=\"" . htmlspecialchars(rawurlencode($archivo)) . "\"><span class='file-icon'></span>" . htmlspecialchars($archivo) . "</a></li>";
              }
            }
          }
          ?>
        </ul>
      </div>
    </div>
  </div>
</body>
</html>
EOF_PHP
    # Asegurar que el propietario del index.php sea el TARGET_USER y el grupo www-data
    chown "$TARGET_USER":www-data "$INDEX_PHP_PATH"
    chmod 664 "$INDEX_PHP_PATH" # rw-rw-r--
    echo "Archivo $INDEX_PHP_PATH creado."

    # 5. Habilitar sitio y recargar Apache
    echo "Habilitando sitio $vhost_name..."
    a2ensite "$vhost_name.conf"

    if confirm_action "deshabilitar el sitio predeterminado de Apache (000-default.conf)"; then
        a2dissite 000-default.conf
    fi

    a2enmod rewrite # Asegurar que mod_rewrite esté activo

    echo "Verificando configuración de Apache..."
    apache2ctl configtest
    if [ $? -eq 0 ]; then
        echo "Configuración de Apache OK. Recargando Apache..."
        systemctl reload apache2
        echo "¡VirtualHost configurado!"
        echo "Ahora puedes acceder a http://$vhost_name/"
        echo "Recuerda añadir '$vhost_name' a tu archivo /etc/hosts si es un dominio local:"
        echo "  127.0.0.1   $vhost_name www.$vhost_name"
        echo "Y si añadiste tu usuario a www-data, necesitas CERRAR SESIÓN Y VOLVER A INICIARLA."
    else
        echo "Error en la configuración de Apache. Por favor, revisa los errores."
        echo "El sitio $vhost_name NO ha sido completamente activado."
        echo "Puedes intentar deshabilitarlo con 'sudo a2dissite $vhost_name.conf' y revisar $VHOST_CONF_FILE."
    fi
    echo # Salto de línea
}

# --- Ejecución Principal ---
configure_db_users
configure_apache_vhost

echo # Salto de línea
echo "=== SCRIPT DE CONFIGURACIÓN POST-INSTALACIÓN FINALIZADO ==="
echo # Salto de línea
