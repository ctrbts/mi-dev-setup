#!/bin/bash

# Este script automatiza la instalación de un stack LAMP (Linux, Apache, MySQL/MariaDB, PHP)
# optimizado para desarrollo en Ubuntu.
# Cada componente es opcional y puede elegir instalarlo o no.
# Se puede elegir entre repositorios oficiales o de la distribución.

# Asegurar ejecución como root
if [[ "$EUID" -ne 0 ]]; then
    echo "Por favor, ejecuta este script como root."
    exit 1
fi

echo # Salto de línea
echo "=== INSTALACIÓN DE LAMP EN UBUNTU ==="
echo # Salto de línea
echo "Este script puede instalar Apache, MariaDB/MySQL, PHP y Composer."
echo "Cada componente es opcional. Se puede elegir la fuente de los paquetes (oficial o local/distribución)."
echo "En entornos de desarrollo prefiera las versiones oficiales de los paquetes. En entornos de producción prefiera las versiones de los paquetes del sistema."
echo # Salto de línea

# --- Variables Globales ---
PHP_VERSION_SELECTED="" # Guardará la versión de PHP seleccionada (ej. 8.3)

# --- Funciones Auxiliares ---
confirm_install() {
    local component=$1
    read -p "¿Desea instalar $component? (s/n): " confirm
    if [[ "$confirm" == "s" ]]; then
        return 0 # Sí
    else
        return 1 # No
    fi
}

choose_repository_source() {
    local component_name=$1
    read -p "¿Desea instalar $component_name desde el repositorio oficial (o) o el de la distribución (d)? (o/d): " repo_choice
    if [[ "$repo_choice" == "o" ]]; then
        echo "oficial"
    else
        echo "distribucion"
    fi
}

# --- Actualizar Paquetes del Sistema ---
read -p "¿Desea actualizar los paquetes del sistema? (s/n): " update_system
if [[ "$update_system" == "s" ]]; then
    echo "Actualizando paquetes del sistema..."
    apt update && apt full-upgrade -y && apt autoremove -y && apt clean -y
    echo "Actualización de paquetes completada."
    echo # Salto de línea
fi

# --- Instalar Apache ---
if confirm_install "Apache Web Server"; then
    # Apache generalmente se instala desde los repositorios de la distribución.
    # No suele haber un "repositorio oficial" de Apache en el mismo sentido que Nginx o PHP de Ondrej.
    echo "Instalando Apache desde los repositorios de la distribución..."
    apt install apache2 -y
    echo "Instalación de Apache completada."

    echo "Configurando UFW para Apache..."
    if command -v ufw >/dev/null 2>&1; then
        ufw allow 'Apache Full' # Permite HTTP y HTTPS
        # ufw allow 'Apache' # Solo HTTP
        # ufw allow 'Apache Secure' # Solo HTTPS
        echo "Reglas de UFW para Apache aplicadas. Asegúrate de que UFW esté habilitado."
    else
        echo "UFW no está instalado. Considera instalarlo y configurarlo."
    fi

    # Habilitar módulos comunes
    read -p "¿Desea habilitar módulos comunes de Apache (rewrite, headers, ssl)? (s/n): " enable_apache_mods
    if [[ "$enable_apache_mods" == "s" ]]; then
        echo "Habilitando módulos de Apache..."
        a2enmod rewrite
        a2enmod headers
        a2enmod ssl
        systemctl restart apache2
        echo "Módulos de Apache habilitados y servicio reiniciado."
    fi
    echo # Salto de línea

    # Ajustar permisos para directorios web de Apache
    echo "Ajustando permisos de directorios web para Apache..."
    APACHE_WEB_DIR="/var/www"
    if [ ! -d "$APACHE_WEB_DIR/html" ]; then
        mkdir -p "$APACHE_WEB_DIR/html"
        echo "Directorio $APACHE_WEB_DIR/html creado."
    fi
    # Es común que el usuario www-data sea el propietario.
    # Para desarrollo, a veces es útil que el usuario actual tenga permisos o pertenezca al grupo www-data.
    chown -R www-data:www-data "$APACHE_WEB_DIR"
    # El usuario actual se añade al grupo www-data para poder escribir en /var/www
    CURRENT_USER=$(logname 2>/dev/null || echo $SUDO_USER)
    if [ -n "$CURRENT_USER" ] && [ "$CURRENT_USER" != "root" ]; then
        usermod -aG www-data "$CURRENT_USER"
        echo "Usuario $CURRENT_USER añadido al grupo www-data. Necesitarás cerrar sesión y volver a entrar para que los cambios de grupo surtan efecto."
    fi
    chmod -R 775 "$APACHE_WEB_DIR"                        # Permite al grupo escribir
    find "$APACHE_WEB_DIR" -type d -exec chmod 2775 {} \; # SetGID para directorios
    find "$APACHE_WEB_DIR" -type f -exec chmod 0664 {} \; # Archivos
    echo "Permisos para Apache ajustados en $APACHE_WEB_DIR."
    echo "Se recomienda crear VirtualHosts específicos en lugar de usar directamente /var/www/html para múltiples sitios."
    echo # Salto de línea
fi

# --- Instalar PHP ---
if confirm_install "PHP"; then
    PHP_REPO_SOURCE=$(choose_repository_source "PHP")

    if [[ "$PHP_REPO_SOURCE" == "oficial" ]]; then
        echo "Versiones disponibles de PHP (desde ppa:ondrej/php):"
        echo "1) PHP 8.1"
        echo "2) PHP 8.2"
        echo "3) PHP 8.3 (Recomendado LTS)"
        # Podrías añadir más o incluso intentar obtenerlas dinámicamente si fuera necesario.
        read -p "Seleccione la versión de PHP a instalar (1-3) [3]: " php_version_option
        php_version_option=${php_version_option:-3}

        case $php_version_option in
        1) PHP_VERSION_SELECTED="8.1" ;;
        2) PHP_VERSION_SELECTED="8.2" ;;
        3) PHP_VERSION_SELECTED="8.3" ;;
        *)
            PHP_VERSION_SELECTED="8.3"
            echo "Opción no válida, se instalará PHP 8.3 por defecto."
            ;;
        esac

        echo "Instalando PHP $PHP_VERSION_SELECTED y extensiones desde ppa:ondrej/php..."
        add-apt-repository ppa:ondrej/php -y
        apt update
        apt install php$PHP_VERSION_SELECTED libapache2-mod-php$PHP_VERSION_SELECTED php$PHP_VERSION_SELECTED-cli php$PHP_VERSION_SELECTED-common php$PHP_VERSION_SELECTED-mysql -y
        # Módulo para la base de datos seleccionada
    else
        echo "Instalando PHP y extensiones desde los repositorios de la distribución..."
        # Esto instalará la versión de PHP por defecto de Ubuntu 24.04 (probablemente PHP 8.3)
        apt install php libapache2-mod-php php-cli php-common php-mysql -y
        # Detectar la versión de PHP instalada
        PHP_VERSION_SELECTED=$(php -v | head -n 1 | awk '{print $2}' | cut -d'.' -f1-2)
        if [ -z "$PHP_VERSION_SELECTED" ]; then
            echo "No se pudo detectar la versión de PHP instalada. La instalación de extensiones específicas podría fallar."
        else
            echo "PHP versión $PHP_VERSION_SELECTED detectada."
        fi
    fi

    # Extensiones comunes de PHP
    read -p "¿Desea instalar extensiones comunes de PHP (curl, gd, mbstring, xml, zip, intl, bcmath, opcache)? (s/n): " php_extensions
    if [[ "$php_extensions" == "s" ]]; then
        if [[ "$PHP_REPO_SOURCE" == "oficial" ]]; then
            apt install php$PHP_VERSION_SELECTED-curl php$PHP_VERSION_SELECTED-gd php$PHP_VERSION_SELECTED-mbstring php$PHP_VERSION_SELECTED-xml php$PHP_VERSION_SELECTED-zip php$PHP_VERSION_SELECTED-intl php$PHP_VERSION_SELECTED-bcmath php$PHP_VERSION_SELECTED-opcache -y
        else
            # Para la versión de la distribución, los paquetes no llevan el prefijo de versión
            apt install php-curl php-gd php-mbstring php-xml php-zip php-intl php-bcmath php-opcache -y
        fi
        echo "Extensiones comunes de PHP instaladas."
    fi
    echo "Instalación de PHP completada."
    echo # Salto de línea

    # Configurar PHP para Apache (php.ini)
    read -p "¿Desea configurar php.ini para desarrollo (límites de memoria, tamaño de carga, etc.)? (s/n): " config_php_ini
    if [[ "$config_php_ini" == "s" ]]; then
        PHP_INI_PATH=""
        if [[ "$PHP_REPO_SOURCE" == "oficial" ]]; then
            PHP_INI_PATH="/etc/php/$PHP_VERSION_SELECTED/apache2/php.ini"
        else
            # Encontrar el php.ini para Apache de la versión por defecto
            # Esto puede ser un poco más complicado si hay múltiples versiones o configuraciones no estándar.
            # Usualmente es /etc/php/VERSION/apache2/php.ini
            if [ ! -z "$PHP_VERSION_SELECTED" ]; then
                PHP_INI_PATH="/etc/php/$PHP_VERSION_SELECTED/apache2/php.ini"
            else
                # Intento genérico, puede no ser el correcto
                PHP_INI_PATH=$(find /etc/php -name php.ini -path "*/apache2/php.ini" | head -n 1)
            fi
        fi

        if [ -f "$PHP_INI_PATH" ]; then
            echo "Configurando $PHP_INI_PATH..."
            sed -i "s/memory_limit = .*/memory_limit = 256M/g" "$PHP_INI_PATH"
            sed -i "s/post_max_size = .*/post_max_size = 128M/g" "$PHP_INI_PATH"
            sed -i "s/upload_max_filesize = .*/upload_max_filesize = 128M/g" "$PHP_INI_PATH"
            sed -i "s/display_errors = .*/display_errors = On/g" "$PHP_INI_PATH"
            sed -i "s/error_reporting = .*/error_reporting = E_ALL/g" "$PHP_INI_PATH"
            # Habilitar opcache si no está ya
            sed -i "s/;opcache.enable=0/opcache.enable=1/g" "$PHP_INI_PATH"
            sed -i "s/;opcache.enable=1/opcache.enable=1/g" "$PHP_INI_PATH"
            sed -i "s/opcache.memory_consumption=.*/opcache.memory_consumption=128/g" "$PHP_INI_PATH"
            sed -i "s/opcache.max_accelerated_files=.*/opcache.max_accelerated_files=10000/g" "$PHP_INI_PATH"
            sed -i "s/opcache.revalidate_freq=.*/opcache.revalidate_freq=2/g" "$PHP_INI_PATH"

            echo "Configuración de php.ini completada."
            systemctl restart apache2
            echo "Apache reiniciado."
        else
            echo "No se pudo encontrar el archivo php.ini en $PHP_INI_PATH. Omita la configuración automática."
        fi
        echo # Salto de línea
    fi
fi

# --- Instalar Composer ---
if confirm_install "Composer (gestor de dependencias para PHP)"; then
    COMPOSER_SOURCE=$(choose_repository_source "Composer")
    if [[ "$COMPOSER_SOURCE" == "oficial" ]]; then
        echo "Instalando Composer desde el script oficial..."
        # Descargar e instalar Composer globalmente
        EXPECTED_CHECKSUM="$(php -r 'copy("https://composer.github.io/installer.sig", "php://stdout");')"
        php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
        ACTUAL_CHECKSUM="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"

        if [ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]; then
            echo >&2 'ERROR: Invalid installer checksum'
            rm composer-setup.php
            exit 1
        fi

        php composer-setup.php --install-dir=/usr/local/bin --filename=composer
        rm composer-setup.php
    else
        echo "Instalando Composer desde los repositorios de la distribución..."
        apt install composer -y
    fi
    echo "Instalación de Composer completada."
    # Verificar Composer
    composer --version
    echo # Salto de línea
fi

# --- Instalar y Configurar UFW (Firewall) ---
if confirm_install "UFW (Uncomplicated Firewall)"; then
    echo "Instalando UFW..."
    apt install ufw -y

    echo "Configurando reglas básicas de UFW..."
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow ssh # O el puerto SSH que uses

    if command -v apache2 >/dev/null 2>&1; then
        ufw allow 'Apache Full' # HTTP y HTTPS
        echo "Reglas para Apache añadidas a UFW."
    fi

    read -p "¿Desea habilitar UFW ahora? (s/n) [s]: " enable_ufw_now
    enable_ufw_now=${enable_ufw_now:-s}
    if [[ "$enable_ufw_now" == "s" ]]; then
        echo "y" | ufw enable # El "y" es para auto-confirmar
        ufw status verbose
        echo "UFW habilitado y configurado."
    else
        echo "UFW configurado pero NO habilitado. Ejecuta 'sudo ufw enable' para activarlo."
    fi
    echo "Instalación y configuración de UFW completada."
    echo # Salto de línea
fi

# --- Resumen Final ---
echo "=== RESUMEN DE INSTALACIÓN LAMP ==="
# Apache
if command -v apache2 >/dev/null 2>&1; then echo "✓ Apache instalado"; else echo "✗ Apache no instalado"; fi
# PHP
if command -v php >/dev/null 2>&1; then echo "✓ PHP $PHP_VERSION_SELECTED instalado"; else echo "✗ PHP no instalado"; fi
# Composer
if command -v composer >/dev/null 2>&1; then echo "✓ Composer instalado"; else echo "✗ Composer no instalado"; fi
# UFW
if command -v ufw >/dev/null 2>&1; then echo "✓ UFW instalado/configurado"; else echo "✗ UFW no instalado"; fi
echo # Salto de línea

echo "TAREAS PENDIENTES:"
if command -v apache2 >/dev/null 2>&1; then
    echo "- Configura VirtualHosts en Apache para tus proyectos (/etc/apache2/sites-available/)."
    echo "- Asegúrate de que tu usuario ($CURRENT_USER) tiene permisos en /var/www o en los directorios de tus VirtualHosts."
    echo "  (Puede ser necesario cerrar sesión y volver a entrar si se añadió al grupo www-data)."
fi
echo "- Si instalaste PHP desde ppa:ondrej/php, considera fijar la versión para evitar actualizaciones automáticas no deseadas a versiones mayores si es necesario."
echo # Salto de línea
echo "Instalación LAMP completada."
