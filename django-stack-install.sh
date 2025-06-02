#!/bin/bash

# Este script automatiza la instalación de un stack para Django (Python)
# en Ubuntu 24.04 LTS, diferenciando entre entorno de desarrollo y servidor.

# Asegurar ejecución como root
if [[ "$EUID" -ne 0 ]]; then
  echo "Por favor, ejecuta este script como root."
  exit 1
fi

echo # Salto de línea
echo "=== INSTALACIÓN DE STACK DJANGO (PYTHON) EN UBUNTU 24.04 LTS ==="
echo # Salto de línea

# --- Variables Globales ---
INSTALL_TYPE=""
PYTHON_VERSION="" # Se detectará o usará python3 por defecto
DB_CHOICE="" # postgresql, mariadb, mysql, none
DB_PYTHON_CONNECTOR="" # psycopg2-binary, mysqlclient

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

get_sudo_user() {
  if [ -n "$SUDO_USER" ] && [ "$SUDO_USER" != "root" ]; then
    echo "$SUDO_USER"
  else
    DEFAULT_USER=$(logname 2>/dev/null)
    # Si logname falla (ej. en algunos contextos de script), usar whoami
    echo "${DEFAULT_USER:-$(whoami)}"
  fi
}

# --- Selección del Tipo de Instalación ---
while [[ "$INSTALL_TYPE" != "desarrollo" && "$INSTALL_TYPE" != "servidor" ]]; do
  read -p "¿Esta configuración es para un entorno de desarrollo o servidor? (desarrollo/servidor): " install_type_choice
  INSTALL_TYPE=$(echo "$install_type_choice" | tr '[:upper:]' '[:lower:]')
  if [[ "$INSTALL_TYPE" != "desarrollo" && "$INSTALL_TYPE" != "servidor" ]]; then
    echo "Opción no válida. Por favor, introduce 'desarrollo' o 'servidor'."
  fi
done
echo "Configurando para un entorno de: $INSTALL_TYPE"
echo # Salto de línea

# --- Actualización del Sistema (Opcional) ---
if confirm_action "actualizar los paquetes del sistema"; then
  echo "Actualizando paquetes del sistema..."
  apt update && apt full-upgrade -y && apt autoremove -y && apt clean -y
  echo "Actualización de paquetes completada."
  echo # Salto de línea
fi

# --- Instalación de Python y Herramientas Base ---
echo "Instalando Python 3, pip, venv y herramientas de desarrollo de Python..."
# python3-dev es para compilar algunas dependencias de Python
# python3-venv para entornos virtuales
# python3-pip para instalar paquetes Python
# build-essential puede ser necesario para algunas compilaciones
apt install python3 python3-pip python3-venv python3-dev build-essential libpq-dev libmysqlclient-dev -y
if [ $? -ne 0 ]; then
    echo "Error instalando Python base. Abortando."
    exit 1
fi
PYTHON_VERSION=$(python3 --version 2>&1 | awk '{print $2}')
echo "Python $PYTHON_VERSION y herramientas base instaladas."
echo # Salto de línea

# --- Base de Datos (Común para desarrollo y servidor, pero la instalación del servidor de BD es opcional) ---
echo "--- Configuración de Base de Datos ---"
echo "Django requiere una base de datos. Puede usar SQLite (para desarrollo ligero, no requiere servidor),"
echo "PostgreSQL (recomendado para producción), o MySQL/MariaDB."

if confirm_action "instalar y configurar un servidor de base de datos (PostgreSQL o MariaDB/MySQL)"; then
  echo "Seleccione el servidor de base de datos:"
  echo "1) PostgreSQL (Recomendado para Django en producción)"
  echo "2) MariaDB (Compatible con MySQL)"
  echo "3) MySQL"
  read -p "Opción [1]: " db_server_choice
  db_server_choice=${db_server_choice:-1}

  case $db_server_choice in
    1)
      DB_CHOICE="postgresql"
      DB_PYTHON_CONNECTOR="psycopg2-binary" # O psycopg2 si se compila
      echo "Instalando PostgreSQL server..."
      apt install postgresql postgresql-contrib -y
      echo "PostgreSQL instalado. Recuerde crear un usuario y base de datos para Django."
      echo "Ej: sudo -u postgres psql -c \"CREATE DATABASE mi_proyecto_db;\""
      echo "    sudo -u postgres psql -c \"CREATE USER mi_proyecto_user WITH PASSWORD 'password';\""
      echo "    sudo -u postgres psql -c \"GRANT ALL PRIVILEGES ON DATABASE mi_proyecto_db TO mi_proyecto_user;\""
      ;;
    2)
      DB_CHOICE="mariadb"
      DB_PYTHON_CONNECTOR="mysqlclient"
      echo "Instalando MariaDB server..."
      apt install mariadb-server -y
      echo "MariaDB instalado."
      if confirm_action "ejecutar mysql_secure_installation para MariaDB"; then
        mysql_secure_installation
      fi
      echo "Recuerde crear un usuario y base de datos para Django."
      echo "Ej: sudo mysql -e \"CREATE DATABASE mi_proyecto_db CHARACTER SET UTF8MB4 COLLATE UTF8MB4_UNICODE_CI;\""
      echo "    sudo mysql -e \"CREATE USER 'mi_proyecto_user'@'localhost' IDENTIFIED BY 'password';\""
      echo "    sudo mysql -e \"GRANT ALL PRIVILEGES ON mi_proyecto_db.* TO 'mi_proyecto_user'@'localhost';\""
      echo "    sudo mysql -e \"FLUSH PRIVILEGES;\""
      ;;
    3)
      DB_CHOICE="mysql"
      DB_PYTHON_CONNECTOR="mysqlclient"
      echo "Instalando MySQL server..."
      apt install mysql-server -y
      echo "MySQL instalado."
      if confirm_action "ejecutar mysql_secure_installation para MySQL"; then
        mysql_secure_installation
      fi
      echo "Recuerde crear un usuario y base de datos para Django (similar a MariaDB)."
      ;;
    *)
      echo "Opción no válida. No se instalará servidor de BD. Django usará SQLite por defecto si no se configura otra."
      DB_CHOICE="none"
      ;;
  esac
else
  echo "No se instalará un servidor de base de datos. Puede usar SQLite o configurar una BD existente."
  DB_CHOICE="none"
fi

if [ -n "$DB_PYTHON_CONNECTOR" ]; then
    echo "Instalando conector Python para $DB_CHOICE: $DB_PYTHON_CONNECTOR..."
    # Se instala globalmente por simplicidad del script, pero es mejor en venv
    pip3 install "$DB_PYTHON_CONNECTOR"
    echo "Conector $DB_PYTHON_CONNECTOR instalado."
fi
echo # Salto de línea


# --- Configuración Específica para Desarrollo ---
if [ "$INSTALL_TYPE" == "desarrollo" ]; then
  echo "--- Configuración de Entorno de Desarrollo Django ---"
  echo "Se recomienda encarecidamente usar entornos virtuales para cada proyecto Django."
  
  # Instalar Django (globalmente para este script, pero se debe usar en venv)
  if confirm_action "instalar Django globalmente (para pruebas, recuerde usarlo dentro de un venv para proyectos)"; then
    pip3 install Django
    echo "Django instalado globalmente. Versión: $(python3 -m django --version)"
  fi

  if confirm_action "instalar virtualenvwrapper (para gestión avanzada de entornos virtuales)"; then
    pip3 install virtualenvwrapper
    echo "virtualenvwrapper instalado."
    echo "Para configurarlo, añada las siguientes líneas a su ~/.bashrc o ~/.zshrc:"
    echo "  export WORKON_HOME=\$HOME/.virtualenvs"
    echo "  export PROJECT_HOME=\$HOME/Devel"
    echo "  source /usr/local/bin/virtualenvwrapper.sh # o la ruta donde se instaló"
    echo "Luego ejecute 'source ~/.bashrc' o 'source ~/.zshrc'."
    echo "Comandos útiles: mkvirtualenv mi_entorno, workon mi_entorno, deactivate, rmvirtualenv mi_entorno"
  fi

  echo "Para crear un proyecto Django:"
  echo "1. Cree un directorio para sus proyectos: mkdir ~/django_projects && cd ~/django_projects"
  echo "2. Cree un entorno virtual: python3 -m venv mi_entorno_venv"
  echo "3. Active el entorno: source mi_entorno_venv/bin/activate"
  echo "4. Instale Django en el entorno: pip install Django"
  echo "5. Cree su proyecto: django-admin startproject mi_proyecto ."
  echo "6. Ejecute las migraciones: python manage.py migrate"
  echo "7. Cree un superusuario: python manage.py createsuperuser"
  echo "8. Ejecute el servidor de desarrollo: python manage.py runserver"
  echo # Salto de línea
fi


# --- Configuración Específica para Servidor ---
if [ "$INSTALL_TYPE" == "servidor" ]; then
  echo "--- Configuración de Entorno de Servidor Django ---"
  
  # Gunicorn
  if confirm_action "instalar Gunicorn (servidor WSGI)"; then
    pip3 install gunicorn
    echo "Gunicorn instalado."
  else
    echo "Gunicorn no instalado. Necesitará un servidor WSGI para producción."
    # Salir de la configuración de servidor si no hay Gunicorn, ya que Nginx y Systemd dependen de él.
    # Opcionalmente, podríamos continuar y dejar que el usuario lo instale manualmente.
    # Por ahora, continuamos pero advertimos.
  fi
  echo # Salto de línea

  # Nginx como Proxy Inverso
  NGINX_CONFIGURED_FOR_DJANGO=false
  if command -v gunicorn &> /dev/null && confirm_action "instalar y configurar Nginx como proxy inverso para Gunicorn"; then
    apt install nginx -y
    
    # Configuración básica de Nginx para un proyecto Django
    # Esto es un ejemplo y necesitará ser adaptado.
    # Suponemos que el proyecto Django está en /srv/mi_proyecto_django
    # y el entorno virtual en /srv/mi_proyecto_django/venv
    # Gunicorn escuchará en un socket unix: /run/gunicorn.sock (o un puerto localhost)

    # Pedir datos para la configuración de Nginx
    read -p "Ingrese el nombre de dominio para su sitio Django (ej. misitio.com): " django_domain
    if [ -z "$django_domain" ]; then
      echo "Nombre de dominio no proporcionado. Omitiendo configuración de Nginx."
    else
      # Crear un archivo de configuración de Nginx para el sitio Django
      NGINX_SITE_CONF="/etc/nginx/sites-available/$django_domain"
      echo "Creando archivo de configuración de Nginx en $NGINX_SITE_CONF..."
      
      # Crear un socket o puerto para Gunicorn
      # Usaremos un socket unix por defecto
      GUNICORN_SOCKET_PATH="/run/${django_domain}_gunicorn.sock" # Nombre de socket basado en dominio
      # O un puerto: GUNICORN_HOST_PORT="127.0.0.1:8001"

      cat << EOF > "$NGINX_SITE_CONF"
server {
    listen 80;
    server_name $django_domain www.$django_domain;

    location = /favicon.ico { access_log off; log_not_found off; }
    location /static/ {
        # Cambie '/srv/mi_proyecto_django/static/' a la ruta real de sus archivos estáticos
        root /srv/$django_domain/static_root; # O la ruta donde 'collectstatic' los coloca
    }
    location /media/ {
        # Cambie '/srv/mi_proyecto_django/media/' a la ruta real de sus archivos media
        root /srv/$django_domain/media_root;
    }

    location / {
        include proxy_params;
        # proxy_pass http://unix:/run/gunicorn.sock; # Para socket unix
        proxy_pass http://unix:$GUNICORN_SOCKET_PATH;
        # proxy_pass http://127.0.0.1:8001; # Si Gunicorn usa un puerto
    }
}
EOF
      ln -s "$NGINX_SITE_CONF" "/etc/nginx/sites-enabled/"
      # Eliminar el default si existe y el usuario lo desea
      if [ -f "/etc/nginx/sites-enabled/default" ]; then
        if confirm_action "deshabilitar el sitio por defecto de Nginx"; then
            rm "/etc/nginx/sites-enabled/default"
        fi
      fi
      
      # Crear directorios de ejemplo para static y media si no existen
      # El usuario deberá ajustarlos y ejecutar collectstatic
      mkdir -p "/srv/$django_domain/static_root"
      mkdir -p "/srv/$django_domain/media_root"
      # Ajustar permisos para que Nginx (www-data) pueda leerlos.
      # El propietario debería ser el usuario que ejecuta Gunicorn o www-data.
      # chown -R www-data:www-data "/srv/$django_domain/" # Ejemplo simplificado

      echo "Configuración de Nginx creada. Verificando..."
      nginx -t
      if [ $? -eq 0 ]; then
        systemctl restart nginx
        echo "Nginx reiniciado."
        NGINX_CONFIGURED_FOR_DJANGO=true
      else
        echo "Error en la configuración de Nginx. Por favor, revise $NGINX_SITE_CONF."
        echo "Puede eliminar el enlace simbólico en /etc/nginx/sites-enabled/ si es necesario."
      fi
    fi
  else
    echo "Nginx no se configurará como proxy inverso. Si usa Gunicorn, necesitará un proxy."
  fi
  echo # Salto de línea

  # Systemd para Gunicorn
  if command -v gunicorn &> /dev/null && confirm_action "configurar un servicio Systemd para Gunicorn"; then
    # Pedir datos para el servicio Systemd
    # Necesitamos el usuario que ejecutará Gunicorn, la ruta al proyecto, al venv, etc.
    
    APP_USER=$(get_sudo_user) # Usuario que ejecutará la aplicación
    read -p "Ingrese la ruta absoluta al directorio de su proyecto Django (ej: /srv/$django_domain/app): " project_path
    read -p "Ingrese la ruta absoluta al directorio del entorno virtual de Python (ej: $project_path/venv): " venv_path
    read -p "Ingrese el nombre del módulo WSGI de su proyecto Django (ej: mi_proyecto.wsgi): " wsgi_module
    
    # Nombre del servicio Systemd, podría basarse en el dominio o nombre del proyecto
    SERVICE_NAME="${django_domain:-mi_app_django}_gunicorn" # Usar dominio si está disponible

    GUNICORN_EXEC="$venv_path/bin/gunicorn"
    # El socket path debe coincidir con el de Nginx si se usa socket
    # GUNICORN_BIND="unix:$GUNICORN_SOCKET_PATH" # Si Nginx usa este socket
    GUNICORN_BIND="0.0.0.0:8001" # O un puerto si Nginx usa proxy_pass a un puerto
    
    if $NGINX_CONFIGURED_FOR_DJANGO && [ -n "$GUNICORN_SOCKET_PATH" ]; then
        GUNICORN_BIND="unix:$GUNICORN_SOCKET_PATH"
        echo "Gunicorn se configurará para usar el socket: $GUNICORN_SOCKET_PATH"
    else
        read -p "Ingrese el bind para Gunicorn (ej: 0.0.0.0:8001 o unix:/tmp/gunicorn.sock): " GUNICORN_BIND_INPUT
        GUNICORN_BIND=${GUNICORN_BIND_INPUT:-"0.0.0.0:8001"}
    fi


    SYSTEMD_SERVICE_FILE="/etc/systemd/system/$SERVICE_NAME.service"
    echo "Creando archivo de servicio Systemd en $SYSTEMD_SERVICE_FILE..."

    cat << EOF > "$SYSTEMD_SERVICE_FILE"
[Unit]
Description=$SERVICE_NAME - Django Gunicorn daemon for $django_domain
# Si Nginx está configurado, Gunicorn debería iniciarse después de la red y Nginx
After=network.target $( [[ "$NGINX_CONFIGURED_FOR_DJANGO" == "true" ]] && echo "nginx.service" )
# Si hay una base de datos local, añadirla aquí:
# After=network.target postgresql.service mariadb.service mysql.service

[Service]
User=$APP_USER
Group=www-data # O el grupo del usuario de la app
WorkingDirectory=$project_path
# Asegurarse de que el directorio del socket (si se usa) exista y tenga permisos
# RuntimeDirectory=${SERVICE_NAME} # Systemd crea /run/nombre_servicio
# ExecStartPre=/bin/mkdir -p /run/${SERVICE_NAME} # Si el socket está en /run/nombre_servicio
# ExecStartPre=/bin/chown ${APP_USER}:${APP_USER} /run/${SERVICE_NAME}
ExecStart=$GUNICORN_EXEC --workers 3 --bind $GUNICORN_BIND $wsgi_module

# Si Gunicorn usa un socket unix en /run, y el directorio del socket es creado por RuntimeDirectory:
# Asegurarse de que el socket sea accesible por Nginx (www-data)
# UMask=007 # El grupo www-data podrá acceder al socket
# ExecStart=$GUNICORN_EXEC --workers 3 --bind unix:/run/$SERVICE_NAME/gunicorn.sock $wsgi_module

Restart=always
StandardOutput=append:/var/log/$SERVICE_NAME.log
StandardError=append:/var/log/$SERVICE_NAME.err.log

[Install]
WantedBy=multi-user.target
EOF

    # Crear directorio para el socket si es necesario (y si el path es /run/...)
    # Esto es más robusto si el socket está en /run/nombre_del_servicio/gunicorn.sock
    # y se usa RuntimeDirectory=nombre_del_servicio en el [Service] block.
    # Por ahora, si GUNICORN_BIND usa un socket en /run, el usuario debe asegurar que el dir exista.
    if [[ "$GUNICORN_BIND" == unix:* ]]; then
        SOCKET_DIR=$(dirname "${GUNICORN_BIND#unix:}")
        if [[ "$SOCKET_DIR" == /run/* ]] && [ ! -d "$SOCKET_DIR" ]; then
            mkdir -p "$SOCKET_DIR"
            chown "$APP_USER":www-data "$SOCKET_DIR" # o el grupo apropiado
            chmod 770 "$SOCKET_DIR" # Permisos para usuario y grupo
            echo "Directorio para socket $SOCKET_DIR creado."
        fi
    fi

    systemctl daemon-reload
    systemctl enable "$SERVICE_NAME"
    systemctl start "$SERVICE_NAME"

    echo "Servicio Systemd '$SERVICE_NAME' creado, habilitado e iniciado."
    echo "Puede verificar el estado con: systemctl status $SERVICE_NAME"
    echo "Logs en: /var/log/$SERVICE_NAME.log y /var/log/$SERVICE_NAME.err.log"
    echo "Asegúrese de que la ruta al proyecto, venv, usuario y módulo WSGI sean correctos en $SYSTEMD_SERVICE_FILE."
    echo "Y que el usuario '$APP_USER' tenga permisos sobre '$project_path'."
  else
    echo "No se configurará Systemd para Gunicorn."
  fi
fi
echo # Salto de línea

# --- Configuración de Firewall (UFW) ---
if confirm_action "configurar UFW (firewall)"; then
  if ! command -v ufw &> /dev/null; then
    echo "Instalando UFW..."
    apt install ufw -y
  fi
  ufw default deny incoming
  ufw default allow outgoing
  ufw allow ssh # O el puerto SSH que uses

  if [[ "$INSTALL_TYPE" == "servidor" ]] && $NGINX_CONFIGURED_FOR_DJANGO; then
    echo "Permitiendo tráfico HTTP y HTTPS para Nginx en UFW..."
    ufw allow 'Nginx Full'
  elif [[ "$INSTALL_TYPE" == "desarrollo" ]]; then
    # Para desarrollo, Django runserver usa el puerto 8000 por defecto
    if confirm_action "permitir tráfico en el puerto 8000/tcp para el servidor de desarrollo de Django"; then
        ufw allow 8000/tcp comment 'Django dev server'
    fi
  fi
  
  # Permitir acceso a la base de datos si es necesario (ej. acceso remoto)
  if [[ "$DB_CHOICE" == "postgresql" ]]; then
      if confirm_action "permitir conexiones remotas a PostgreSQL (puerto 5432/tcp) en UFW"; then
          ufw allow 5432/tcp comment 'PostgreSQL'
      fi
  elif [[ "$DB_CHOICE" == "mariadb" || "$DB_CHOICE" == "mysql" ]]; then
      if confirm_action "permitir conexiones remotas a MariaDB/MySQL (puerto 3306/tcp) en UFW"; then
          ufw allow 3306/tcp comment 'MariaDB/MySQL'
      fi
  fi

  if confirm_action "habilitar UFW ahora"; then
    echo "y" | ufw enable
    ufw status verbose
  else
    echo "UFW configurado pero no habilitado. Ejecute 'sudo ufw enable' para activarlo."
  fi
else
  echo "UFW no configurado. Considere configurarlo manualmente."
fi
echo # Salto de línea

echo "=== INSTALACIÓN DE STACK DJANGO COMPLETADA ==="
echo "Resumen:"
echo "- Entorno: $INSTALL_TYPE"
echo "- Python: $PYTHON_VERSION instalado."
echo "- Base de Datos: $DB_CHOICE (Conector Python: ${DB_PYTHON_CONNECTOR:-ninguno})"
if [ "$INSTALL_TYPE" == "desarrollo" ]; then
  echo "- Herramientas de desarrollo: Django (si se instaló), virtualenvwrapper (si se instaló)."
  echo "- Recuerde usar entornos virtuales para sus proyectos."
fi
if [ "$INSTALL_TYPE" == "servidor" ]; then
  if command -v gunicorn &> /dev/null; then echo "- Gunicorn instalado."; else echo "- Gunicorn NO instalado."; fi
  if $NGINX_CONFIGURED_FOR_DJANGO; then echo "- Nginx configurado como proxy para $django_domain."; elif command -v nginx &> /dev/null; then echo "- Nginx instalado pero NO configurado para Django."; else echo "- Nginx NO instalado."; fi
  if [ -f "$SYSTEMD_SERVICE_FILE" ]; then echo "- Systemd servicio '$SERVICE_NAME' configurado para Gunicorn."; else echo "- Systemd NO configurado para Gunicorn."; fi
  echo "- Asegúrese de que su aplicación Django esté correctamente configurada en '$project_path',"
  echo "  que las dependencias estén instaladas en el venv '$venv_path',"
  echo "  y que haya ejecutado 'python manage.py collectstatic'."
fi
echo "- UFW: Configurado (verifique el estado)."
echo # Salto de línea
echo "¡Revise los logs y configuraciones para asegurar que todo funcione como se espera!"
