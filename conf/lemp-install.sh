#!/bin/bash

# Este script automatiza la instalación de un stack LEMP (Linux, Nginx, MariaDB, PHP)
# optimizado para Laravel en Ubuntu 24.04 LTS.
# Opcionalmente, restaura un servidor desde una copia de seguridad.
# Estructura del directorio de respaldo:
# - backup/
#   - nginx/ (archivos de configuración de Nginx)
#   - db/ (archivos .sql para restauración de la base de datos)
#   - site/ (archivos del sitio web)

# Asegurar ejecución como root
if [[ "$EUID" -ne 0 ]]; then
  echo "Por favor, ejecuta este script como root."
  exit 1
fi

echo # Salto de línea
echo "=== INSTALACIÓN DE LEMP PARA LARAVEL EN UBUNTU 24.04 LTS ==="
echo # Salto de línea
echo "Este script puede instalar Nginx, MariaDB, PHP, Composer y Redis."
echo "Cada componente es opcional y puede elegir instalarlo o no. Opcionalmente, restaurará un servidor desde una copia de seguridad."
echo "En entornos de desarrollo prefiera las versiones oficiales de los paquetes. En entornos de producción prefiera las versiones de los paquetes del sistema."
echo # Salto de línea

# Función para confirmar instalación
confirm_install() {
  local component=$1
  read -p "¿Desea instalar $component? (s/n): " confirm
  if [[ "$confirm" == "s" ]]; then
    return 0
  else
    return 1
  fi
}

# Actualizar paquetes del sistema
read -p "¿Desea actualizar los paquetes del sistema? (s/n): " update_system
if [[ "$update_system" == "s" ]]; then
  echo "Actualizando paquetes del sistema..."
  apt update && apt full-upgrade -y && apt dist-upgrade -y && apt autoremove -y && apt clean
  echo "Actualización de paquetes completada."
  echo # Salto de línea
  
  read -p "¿Desea instalar herramientas básicas (software-properties-common, zsh, mc, ssh, htop)? (s/n): " install_tools
  if [[ "$install_tools" == "s" ]]; then
    apt install software-properties-common zsh mc ssh htop -y
    echo "Instalación de herramientas básicas completada."
    echo # Salto de línea
  fi
fi

# Instalar Nginx
if confirm_install "Nginx"; then
  read -p "¿Desea instalar Nginx desde el repositorio oficial (o) o local (l)? (o/l): " nginx_repo
  if [[ "$nginx_repo" == "o" ]]; then
    # Instalar Nginx desde el repositorio oficial
    echo "Instalando Nginx desde el repositorio oficial..."
    apt install curl gnupg2 ca-certificates lsb-release ubuntu-keyring -y
    curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor | tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null
    echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/ubuntu $(lsb_release -cs) nginx" | tee /etc/apt/sources.list.d/nginx.list
    echo -e "Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n" | tee /etc/apt/preferences.d/99nginx
    apt update && apt install nginx -y
  else
    # Instalar Nginx desde el repositorio local
    echo "Instalando Nginx desde el repositorio local..."
    apt install nginx -y
  fi
  echo "Instalación de Nginx completada."
  echo # Salto de línea
  
  # Ajustar permisos para directorios web de Nginx
  echo "Ajustando permisos de directorios web para Nginx..."
  if [ ! -d "/usr/share/nginx/" ]; then
    mkdir -p /usr/share/nginx/
    echo "Directorio /usr/share/nginx/ creado."
  fi
  chown -R www-data:www-data /usr/share/nginx/
  chmod -R 755 /usr/share/nginx/
  echo "Permisos para Nginx ajustados."
  echo # Salto de línea
fi

# Instalar MariaDB
if confirm_install "MariaDB"; then
  echo "Instalando MariaDB..."
  apt install mariadb-server -y
  echo "Instalación de MariaDB completada."
  echo # Salto de línea
fi

# Instalar PHP 
if confirm_install "PHP"; then
  # Preguntar sobre la instalación de PHP
  read -p "¿Desea instalar PHP desde el repositorio oficial (o) o local (l)? (o/l): " php_repo
  
  if [[ "$php_repo" == "o" ]]; then
    # Preguntar sobre la versión de PHP a instalar (solo para repo oficial)
    echo "Versiones disponibles de PHP:"
    echo "1) PHP 8.0"
    echo "2) PHP 8.1" 
    echo "3) PHP 8.2"
    echo "4) PHP 8.3"
    read -p "Seleccione la versión de PHP a instalar (1-4): " php_version
    
    case $php_version in
      1) php_ver="8.0" ;;
      2) php_ver="8.1" ;;
      3) php_ver="8.2" ;;
      4) php_ver="8.3" ;;
      *) php_ver="8.3"
          echo "Opción no válida, se instalará PHP 8.3 por defecto." ;;
    esac
    
    # Instalar PHP desde el repositorio oficial
    echo "Instalando PHP $php_ver y extensiones desde el repositorio oficial..."
    add-apt-repository ppa:ondrej/php -y
    apt update && apt install php$php_ver-fpm php$php_ver-cli php$php_ver-mysql php$php_ver-sqlite3 -y
    
    # Preguntar por extensiones opcionales de PHP
    read -p "¿Desea instalar extensiones adicionales de PHP para Laravel? (s/n): " php_extensions
    if [[ "$php_extensions" == "s" ]]; then
      apt install php$php_ver-gd php$php_ver-curl php$php_ver-zip php$php_ver-xml php$php_ver-mbstring php$php_ver-bcmath php$php_ver-tokenizer php$php_ver-xml php$php_ver-common php$php_ver-opcache php$php_ver-intl -y
    fi
  else
    # Instalar PHP desde el repositorio local (sin preguntar versión)
    echo "Instalando PHP y extensiones desde el repositorio local..."
    apt install php-fpm php-cli php-mysql php-sqlite3 -y
    
    # Detectar la versión de PHP instalada
    php_ver=$(php -v | head -n 1 | awk '{print $2}' | cut -d'.' -f1-2)

    # Preguntar por extensiones opcionales de PHP
    read -p "¿Desea instalar extensiones adicionales de PHP para Laravel? (s/n): " php_extensions
    if [[ "$php_extensions" == "s" ]]; then
      apt install php-gd php-curl php-zip php-xml php-mbstring php-bcmath php-common php-opcache php-intl -y
    fi
  fi
  
  echo "Instalación de PHP y extensiones completada."
  echo # Salto de línea

  # Configurar PHP-FPM para Laravel
  read -p "¿Desea configurar PHP-FPM para Laravel? (s/n): " config_php
  if [[ "$config_php" == "s" ]]; then
    echo "Configurando PHP-FPM..."
    sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php/$php_ver/fpm/php.ini
    
    read -p "¿Desea configurar límites de memoria y tamaño de carga? (s/n): " config_limits
    if [[ "$config_limits" == "s" ]]; then
      read -p "Ingrese el límite de memoria (por defecto 128M): " memory_limit
      memory_limit=${memory_limit:-128M}
      
      read -p "Ingrese el tamaño máximo de POST (por defecto 128M): " post_max
      post_max=${post_max:-128M}
      
      read -p "Ingrese el tamaño máximo de carga (por defecto 128M): " upload_max
      upload_max=${upload_max:-128M}
      
      sed -i "s/memory_limit = 128M/memory_limit = $memory_limit/g" /etc/php/$php_ver/fpm/php.ini
      sed -i "s/post_max_size = 8M/post_max_size = $post_max/g" /etc/php/$php_ver/fpm/php.ini
      sed -i "s/upload_max_filesize = 2M/upload_max_filesize = $upload_max/g" /etc/php/$php_ver/fpm/php.ini
    else
      sed -i 's/memory_limit = 128M/memory_limit = 128M/g' /etc/php/$php_ver/fpm/php.ini
      sed -i 's/post_max_size = 8M/post_max_size = 128M/g' /etc/php/$php_ver/fpm/php.ini
      sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 128M/g' /etc/php/$php_ver/fpm/php.ini
    fi
    
    service php$php_ver-fpm restart
    echo "Configuración de PHP-FPM completada."
    echo # Salto de línea
  fi
fi

# Instalar Composer
if confirm_install "Composer"; then
  read -p "¿Desea instalar Composer desde el repositorio oficial (o) o local (l)? (o/l): " composer_repo
  if [[ "$composer_repo" == "o" ]]; then
    # Instalar Composer desde el repositorio oficial
    echo "Instalando Composer desde el repositorio oficial..."
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
  else
    # Instalar Composer desde el repositorio local
    echo "Instalando Composer desde el repositorio local..."
    apt install composer -y
  fi
  echo "Instalación de Composer completada."
  echo # Salto de línea
fi

# Ajustar permisos para directorios web
read -p "¿Desea ajustar permisos para directorios web? (s/n): " adjust_permissions
if [[ "$adjust_permissions" == "s" ]]; then
  echo "Ajustando permisos de directorios web..."
  # Verificar y crear directorios si no existen
  if [ ! -d "/var/www/" ]; then
    mkdir -p /var/www/
    echo "Directorio /var/www/ creado."
  fi

  chown -R www-data:www-data /var/www/
  chmod -R 755 /var/www/
  echo "Permisos ajustados."
  echo # Salto de línea
fi

# Instalar Redis
if confirm_install "Redis"; then
  read -p "¿Desea instalar Redis desde el repositorio oficial (o) o local (l)? (o/l): " redis_repo
  if [[ "$redis_repo" == "o" ]]; then
    # Instalar Redis desde el repositorio oficial
    echo "Instalando Redis desde el repositorio oficial..."
    curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list
    apt update && apt install redis -y
  else
    # Instalar Redis desde el repositorio local
    echo "Instalando Redis desde el repositorio local..."
    apt install redis-server -y
  fi
  
  read -p "¿Desea habilitar y iniciar el servicio Redis? (s/n): " enable_redis
  if [[ "$enable_redis" == "s" ]]; then
    systemctl enable redis-server.service
    systemctl start redis-server.service
  fi
  
  if [[ -n "$php_ver" ]]; then
    read -p "¿Desea instalar la extensión PHP-Redis? (s/n): " install_php_redis
    if [[ "$install_php_redis" == "s" ]]; then
      apt install php$php_ver-redis -y
    fi
  fi
  
  echo "Instalación de Redis completada."
  echo # Salto de línea
fi

# Instalar Certbot
if confirm_install "Certbot"; then
  # Preguntar método de instalación de Certbot
  read -p "¿Instalar Certbot desde Snap o repositorio oficial? (snap/repo): " certbot_method

  if [[ "$certbot_method" == "snap" ]]; then
    # Instalar Snapd y Certbot desde Snap
    echo "Instalando Snapd..."
    apt install snapd -y
    echo "Snapd instalado."

    echo "Instalando Certbot desde Snap..."
    snap install --classic certbot
    ln -s /snap/bin/certbot /usr/bin/certbot
    echo "Instalación de Certbot completada."
  elif [[ "$certbot_method" == "repo" ]]; then
    # Instalar Certbot desde el repositorio oficial
    echo "Instalando Certbot desde el repositorio oficial..."
    add-apt-repository ppa:certbot/certbot -y
    apt update && apt install certbot python3-certbot-nginx -y
    echo "Instalación de Certbot completada."
  else
    echo "Método de instalación de Certbot no válido."
  fi
fi
echo # Salto de línea

# Restaurar desde copia de seguridad
read -p "¿Desea restaurar desde una copia de seguridad? (s/n): " restore_backup
if [[ "$restore_backup" == "s" ]]; then
  if [[ -d "backup" ]]; then
    echo "Restaurando desde copia de seguridad..."
    cd backup

    # Restaurar configuración de Nginx
    if [[ -d "nginx" && -n "$(ls -A nginx)" ]]; then
      read -p "¿Desea restaurar la configuración de Nginx? (s/n): " restore_nginx
      if [[ "$restore_nginx" == "s" ]]; then
        echo "Restaurando configuración de Nginx..."
        mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
        cp -r nginx/* /etc/nginx/
        echo "Configuración de Nginx restaurada."
      fi
    fi

    # Restaurar archivos del sitio web
    if [[ -f "site.zip" ]]; then
      read -p "¿Desea restaurar los archivos del sitio web? (s/n): " restore_site
      if [[ "$restore_site" == "s" ]]; then
        echo "Restaurando archivos del sitio web..."
        apt install unzip -y
        unzip site.zip -d /var/www/
        chown -R www-data:www-data /var/www/
        echo "Archivos del sitio web restaurados."
      fi
    fi

    # Restaurar base de datos MariaDB
    if [[ -d "db" && -n "$(ls -A db/*.sql 2>/dev/null)" ]]; then
      read -p "¿Desea restaurar las bases de datos MariaDB? (s/n): " restore_db
      if [[ "$restore_db" == "s" ]]; then
        echo "Restaurando base de datos MariaDB..."
        for sql_file in db/*.sql; do
          db_name=$(basename "$sql_file" .sql)
          mysql -u root -e "CREATE DATABASE IF NOT EXISTS \`$db_name\`"
          mysql -u root "$db_name" < "$sql_file"
        done
        echo "Base de datos MariaDB restaurada."
      fi
    fi

    cd ..
  else
    echo "Directorio de respaldo 'backup' no encontrado."
  fi
fi

# Reiniciar servicios
read -p "¿Desea reiniciar los servicios instalados? (s/n): " restart_services
if [[ "$restart_services" == "s" ]]; then
  echo "Reiniciando servicios..."
  
  # Reiniciar Nginx si está instalado
  if command -v nginx >/dev/null 2>&1; then
    systemctl restart nginx
  fi
  
  # Reiniciar PHP-FPM si está instalado
  if [[ -n "$php_ver" ]]; then
    systemctl restart php$php_ver-fpm
  fi
  
  # Reiniciar Redis si está instalado
  if systemctl is-active --quiet redis-server 2>/dev/null; then
    systemctl restart redis-server
  elif systemctl is-active --quiet redis 2>/dev/null; then
    systemctl restart redis
  fi
  
  echo "Servicios reiniciados."
  echo # Salto de línea
fi

# Instalar y configurar UFW
if confirm_install "UFW (Uncomplicated Firewall)"; then
  echo "Instalando UFW..."
  apt install ufw -y
  
  # Configuración básica de UFW
  echo "Configurando reglas básicas de UFW..."
  
  # Denegar todo el tráfico entrante por defecto
  ufw default deny incoming
  
  # Permitir todo el tráfico saliente por defecto
  ufw default allow outgoing
  
  # Permitir SSH (siempre recomendado para evitar bloqueos)
  read -p "¿Desea permitir conexiones SSH? (s/n): " allow_ssh
  if [[ "$allow_ssh" == "s" ]]; then
    read -p "¿En qué puerto está configurado SSH? (por defecto: 22): " ssh_port
    ssh_port=${ssh_port:-22}
    ufw allow $ssh_port/tcp comment 'SSH'
    echo "Acceso SSH permitido en el puerto $ssh_port."
  fi
  
  # Reglas para Nginx
  if command -v nginx >/dev/null 2>&1; then
    read -p "¿Desea configurar reglas de firewall para Nginx? (s/n): " nginx_firewall
    if [[ "$nginx_firewall" == "s" ]]; then
      ufw allow 'Nginx HTTP' comment 'Nginx HTTP'
      
      read -p "¿Desea permitir el tráfico HTTPS? (s/n): " allow_https
      if [[ "$allow_https" == "s" ]]; then
        ufw allow 'Nginx HTTPS' comment 'Nginx HTTPS'
        echo "Tráfico HTTP y HTTPS permitido para Nginx."
      else
        echo "Solo tráfico HTTP permitido para Nginx."
      fi
    fi
  fi
  
  # Reglas para MariaDB
  if command -v mysql >/dev/null 2>&1; then
    read -p "¿Desea permitir conexiones remotas a MariaDB? (s/n): " mariadb_remote
    if [[ "$mariadb_remote" == "s" ]]; then
      read -p "¿Desde qué dirección IP se permitirán conexiones a MariaDB? (ej: 192.168.1.0/24): " mariadb_ip
      if [[ -n "$mariadb_ip" ]]; then
        ufw allow from $mariadb_ip to any port 3306 proto tcp comment 'MariaDB Remote'
        echo "Conexiones remotas a MariaDB permitidas desde $mariadb_ip."
      else
        echo "No se ha especificado una dirección IP válida."
      fi
    else
      # Si no permite conexiones remotas, asegurarse de que MariaDB solo escuche en localhost
      if [[ -f "/etc/mysql/mariadb.conf.d/50-server.cnf" ]]; then
        sed -i 's/^bind-address.*$/bind-address = 127.0.0.1/' /etc/mysql/mariadb.conf.d/50-server.cnf
        echo "MariaDB configurado para escuchar solo en localhost."
      fi
    fi
  fi
  
  # Reglas para FTP (opcional)
  read -p "¿Desea permitir conexiones FTP? (s/n): " allow_ftp
  if [[ "$allow_ftp" == "s" ]]; then
    ufw allow 21/tcp comment 'FTP'
    # Para FTP pasivo
    read -p "¿Desea habilitar FTP pasivo (rango de puertos)? (s/n): " allow_passive_ftp
    if [[ "$allow_passive_ftp" == "s" ]]; then
      read -p "Ingrese el rango de puertos para FTP pasivo (ej: 10000:10100): " passive_range
      if [[ -n "$passive_range" ]]; then
        ufw allow $passive_range/tcp comment 'FTP passive'
        echo "FTP pasivo habilitado en el rango de puertos $passive_range."
      fi
    fi
    echo "Acceso FTP permitido."
  fi
  
  # Reglas para Redis
  if command -v redis-cli >/dev/null 2>&1; then
    read -p "¿Desea permitir conexiones remotas a Redis? (s/n): " redis_remote
    if [[ "$redis_remote" == "s" ]]; then
      read -p "¿Desde qué dirección IP se permitirán conexiones a Redis? (ej: 192.168.1.0/24): " redis_ip
      if [[ -n "$redis_ip" ]]; then
        ufw allow from $redis_ip to any port 6379 proto tcp comment 'Redis Remote'
        echo "Conexiones remotas a Redis permitidas desde $redis_ip."
        
        # Configurar Redis para aceptar conexiones remotas
        if [[ -f "/etc/redis/redis.conf" ]]; then
          # Comentar la línea bind 127.0.0.1 para permitir todas las interfaces o especificar IP
          sed -i 's/^bind 127.0.0.1/# bind 127.0.0.1/' /etc/redis/redis.conf
          # Cambiar protected-mode a no
          sed -i 's/protected-mode yes/protected-mode no/' /etc/redis/redis.conf
          # Recomendar configurar una contraseña
          echo "IMPORTANTE: Se recomienda configurar una contraseña para Redis editando /etc/redis/redis.conf"
          echo "y estableciendo 'requirepass tu_contraseña_segura'."
        fi
      fi
    else
      # Asegurarse de que Redis solo escuche en localhost
      if [[ -f "/etc/redis/redis.conf" ]]; then
        sed -i 's/^# bind 127.0.0.1/bind 127.0.0.1/' /etc/redis/redis.conf
        sed -i 's/^bind 0.0.0.0/bind 127.0.0.1/' /etc/redis/redis.conf
        sed -i 's/protected-mode no/protected-mode yes/' /etc/redis/redis.conf
        echo "Redis configurado para escuchar solo en localhost."
      fi
    fi
  fi
  
  # Configuración avanzada (opcional)
  read -p "¿Desea configurar opciones avanzadas de UFW? (s/n): " advanced_ufw
  if [[ "$advanced_ufw" == "s" ]]; then
    # Habilitar registro de eventos
    read -p "¿Desea habilitar el registro de eventos de UFW? (s/n): " enable_logging
    if [[ "$enable_logging" == "s" ]]; then
      read -p "Nivel de registro (low/medium/high): " log_level
      log_level=${log_level:-low}
      ufw logging $log_level
      echo "Registro de eventos configurado en nivel '$log_level'."
    fi
    
    # Configurar rate limiting para prevenir ataques de fuerza bruta
    read -p "¿Desea configurar rate limiting para SSH (protección contra fuerza bruta)? (s/n): " rate_limit
    if [[ "$rate_limit" == "s" ]]; then
      ssh_port=${ssh_port:-22}
      # Eliminar regla anterior si existe
      ufw delete allow $ssh_port/tcp
      # Agregar regla con rate limiting
      ufw limit $ssh_port/tcp comment 'SSH rate limited'
      echo "Rate limiting configurado para SSH en el puerto $ssh_port."
    fi
    
    # Permitir ping
    read -p "¿Desea permitir pings (ICMP)? (s/n): " allow_ping
    if [[ "$allow_ping" == "s" ]]; then
      # Configurar /etc/ufw/before.rules para permitir ping
      sed -i '/^# ok icmp codes for INPUT/,/^# allow dhcp client to work/ s/-A ufw-before-input -p icmp --icmp-type echo-request -j DROP/-A ufw-before-input -p icmp --icmp-type echo-request -j ACCEPT/' /etc/ufw/before.rules
      echo "Pings (ICMP) habilitados."
    else
      # Configurar /etc/ufw/before.rules para bloquear ping
      sed -i '/^# ok icmp codes for INPUT/,/^# allow dhcp client to work/ s/-A ufw-before-input -p icmp --icmp-type echo-request -j ACCEPT/-A ufw-before-input -p icmp --icmp-type echo-request -j DROP/' /etc/ufw/before.rules
      echo "Pings (ICMP) bloqueados."
    fi
  fi
  
  # Habilitar UFW
  read -p "¿Desea habilitar UFW ahora? (s/n): " enable_ufw
  if [[ "$enable_ufw" == "s" ]]; then
    echo "y" | ufw enable
    ufw status verbose
    echo "UFW habilitado y configurado correctamente."
  else
    echo "IMPORTANTE: UFW ha sido configurado pero NO está habilitado."
    echo "Para habilitarlo manualmente, ejecute: 'ufw enable'"
  fi
  
  echo "Instalación y configuración de UFW completada."
  echo # Salto de línea
fi

# Resumen de instalación
echo "=== RESUMEN DE INSTALACIÓN ==="
if command -v nginx >/dev/null 2>&1; then
  echo "✓ Nginx instalado"
else
  echo "✗ Nginx no instalado"
fi

if command -v mysql >/dev/null 2>&1; then
  echo "✓ MariaDB instalado"
else
  echo "✗ MariaDB no instalado"
fi

if [[ -n "$php_ver" ]]; then
  echo "✓ PHP $php_ver instalado"
else
  echo "✗ PHP no instalado"
fi

if command -v composer >/dev/null 2>&1; then
  echo "✓ Composer instalado"
else
  echo "✗ Composer no instalado"
fi

if command -v redis-cli >/dev/null 2>&1; then
  echo "✓ Redis instalado"
else
  echo "✗ Redis no instalado"
fi

if command -v certbot >/dev/null 2>&1; then
  echo "✓ Certbot instalado"
else
  echo "✗ Certbot no instalado"
fi

if command -v ufw >/dev/null 2>&1; then
  echo "✓ UFW instalado"
else
  echo "✗ UFW no instalado"
fi
echo # Salto de línea

# Información sobre tareas pendientes
echo "TAREAS PENDIENTES:"
if command -v mysql >/dev/null 2>&1; then
  echo "- ejecute 'mysql_secure_installation' para securizar MariaDB."
fi
if command -v nginx >/dev/null 2>&1; then
  echo "- actualice la configuración de Nginx para su servidor."
fi
echo # Salto de línea
