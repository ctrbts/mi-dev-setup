#!/bin/bash

# Script para realizar copias de seguridad de un servidor LEMP (Nginx, MariaDB, Laravel)
# y almacenar los respaldos en la carpeta del usuario.

# Configuración
BACKUP_DIR="$HOME/backups" # Directorio de respaldo en la carpeta del usuario
DATE=$(date +%Y%m%d_%H%M%S)
NGINX_CONF_DIR="/etc/nginx"
SITE_DIR="/var/www"
DB_USER="root"
DB_PASS="" # Ingresa la contraseña de root de MariaDB si la tienes.

# Crear directorio de respaldo si no existe
mkdir -p "$BACKUP_DIR/$DATE"

# Copia de seguridad de la configuración de Nginx
echo "Realizando copia de seguridad de la configuración de Nginx..."
cp -r "$NGINX_CONF_DIR" "$BACKUP_DIR/$DATE/nginx"
echo "Copia de seguridad de la configuración de Nginx completada."
echo # Salto de línea

# Copia de seguridad de los archivos del sitio web
echo "Realizando copia de seguridad de los archivos del sitio web..."
cp -r "$SITE_DIR" "$BACKUP_DIR/$DATE/site"
echo "Copia de seguridad de los archivos del sitio web completada."
echo # Salto de línea

# Copia de seguridad de las bases de datos MariaDB
echo "Realizando copia de seguridad de las bases de datos MariaDB..."
DATABASES=$(mysql -u "$DB_USER" -p"$DB_PASS" -e "SHOW DATABASES;" | grep -v "Database" | grep -v "information_schema" | grep -v "performance_schema" | grep -v "mysql")

for DB in $DATABASES; do
  echo "Realizando copia de seguridad de la base de datos: $DB"
  mysqldump -u "$DB_USER" -p"$DB_PASS" "$DB" > "$BACKUP_DIR/$DATE/db/$DB.sql"
done
echo # Salto de línea

echo "Copia de seguridad de las bases de datos MariaDB completada."
echo # Salto de línea

# Comprimir el respaldo
echo "Comprimiendo el respaldo..."
tar -czvf "$BACKUP_DIR/backup_$DATE.tar.gz" -C "$BACKUP_DIR" "$DATE"
rm -rf "$BACKUP_DIR/$DATE" # Opcional: eliminar el directorio sin comprimir
echo "Compresión del respaldo completada."
echo # Salto de línea

echo "Copia de seguridad completada. Respaldos guardados en: $BACKUP_DIR/backup_$DATE.tar.gz"
echo # Salto de línea
