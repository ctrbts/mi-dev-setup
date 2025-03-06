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

# Actualizar paquetes del sistema
echo "Actualizando paquetes del sistema..."
apt update && apt full-upgrade -y && apt dist-upgrade -y && apt autoremove -y && apt clean
apt install software-properties-common curl git zsh mc ssh htop -y
echo "Actualización de paquetes y dependencias completada."
echo # Salto de línea

# Instalar Nginx desde el repositorio oficial
echo "Instalando Nginx..."
apt install curl gnupg2 ca-certificates lsb-release ubuntu-keyring -y
curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor | tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null
echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/ubuntu $(lsb_release -cs) nginx" | tee /etc/apt/sources.list.d/nginx.list
echo -e "Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n" | tee /etc/apt/preferences.d/99nginx
apt update && apt install nginx -y
echo "Instalación de Nginx completada."
echo # Salto de línea

# Instalar MariaDB
echo "Instalando MariaDB..."
apt install mariadb-server -y
echo "Instalación de MariaDB completada."
echo # Salto de línea

# Instalar PHP 8.3 y extensiones necesarias para Laravel
echo "Instalando PHP 8.3 y extensiones..."
add-apt-repository ppa:ondrej/php -y
apt update && apt install php8.3-fpm php8.3-cli php8.3-mysql php8.3-gd php8.3-curl php8.3-zip php8.3-xml php8.3-mbstring php8.3-bcmath php8.3-tokenizer php8.3-xml php8.3-common php8.3-opcache php8.3-intl -y
echo "Instalación de PHP y extensiones completada."
echo # Salto de línea

# Configurar PHP-FPM para Laravel
echo "Configurando PHP-FPM..."
sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php/8.3/fpm/php.ini
sed -i 's/memory_limit = 128M/memory_limit = 128M/g' /etc/php/8.3/fpm/php.ini
sed -i 's/post_max_size = 8M/post_max_size = 128M/g' /etc/php/8.3/fpm/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 128M/g' /etc/php/8.3/fpm/php.ini
service php8.3-fpm restart
echo "Configuración de PHP-FPM completada."
echo # Salto de línea

# Instalar Composer
echo "Instalando Composer..."
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
echo "Instalación de Composer completada."
echo # Salto de línea

# Ajustar permisos para directorios web
echo "Ajustando permisos de directorios web..."
chown -R www-data:www-data /var/www/
chmod -R 755 /var/www/
chown -R www-data:www-data /usr/share/nginx/
chmod -R 755 /usr/share/nginx/
echo "Permisos ajustados."
echo # Salto de línea

# Instalar Redis
echo "Instalando Redis..."
curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list
apt update && apt install redis -y
systemctl enable redis-server.service
systemctl start redis-server.service
apt install php8.3-redis -y
echo "Instalación de Redis completada."
echo # Salto de línea

# Preguntar si se desea instalar Certbot
read -p "¿Desea instalar Certbot? (s/n): " install_certbot

if [[ "$install_certbot" == "s" ]]; then
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

# Restaurar desde copia de seguridad (si existe)
if [[ -d "backup" ]]; then
  echo "Restaurando desde copia de seguridad..."
  cd backup

  # Restaurar configuración de Nginx
  echo "Restaurando configuración de Nginx..."
  mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
  cp -r nginx/* /etc/nginx/
  echo "Configuración de Nginx restaurada."

  # Restaurar archivos del sitio web
  echo "Restaurando archivos del sitio web..."
  apt install unzip -y
  unzip site.zip -d /var/www/
  chown -R www-data:www-data /var/www/
  echo "Archivos del sitio web restaurados."

  # Restaurar base de datos MariaDB
  echo "Restaurando base de datos MariaDB..."
  for sql_file in db/*.sql; do
    db_name=$(basename "$sql_file" .sql)
    mysql -u root -e "CREATE DATABASE IF NOT EXISTS \`$db_name\`"
    mysql -u root "$db_name" < "$sql_file"
  done
  echo "Base de datos MariaDB restaurada."

  cd ..
else
  echo "Directorio de respaldo 'backup' no encontrado."
fi

# Reiniciar servicios
echo "Reiniciando servicios..."
systemctl restart nginx php8.3-fpm redis-server
echo "Servicios reiniciados."
echo # Salto de línea

# Ejecutar mysql_secure_installation
echo "Por favor, ejecuta 'mysql_secure_installation' para asegurar MariaDB."
echo # Salto de línea
