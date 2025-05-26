#!/bin/bash

# Este script automatiza la instalación de un servidor de base de datos
# en Ubuntu 24.04 LTS. Permite elegir entre MariaDB, MySQL y PostgreSQL.

# Asegurar ejecución como root
if [[ "$EUID" -ne 0 ]]; then
    echo "Por favor, ejecuta este script como root."
    exit 1
fi

echo # Salto de línea
echo "=== INSTALACIÓN DE SERVIDOR DE BASE DE DATOS EN UBUNTU 24.04 LTS ==="
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

# --- Selección de Base de Datos ---
echo "Seleccione el servidor de base de datos que desea instalar:"
echo "1) MariaDB (Recomendado, compatible con MySQL)"
echo "2) MySQL (Original)"
echo "3) PostgreSQL"
echo "4) Ninguno (Salir)"
read -p "Ingrese su opción (1-4) [1]: " db_choice_num
db_choice_num=${db_choice_num:-1}

DB_SERVER_NAME=""
DB_PACKAGE_NAME=""
DB_SECURE_COMMAND=""
DB_CLIENT_PACKAGE=""
DB_PORT=3306 # Default para MySQL/MariaDB

case $db_choice_num in
1)
    DB_SERVER_NAME="MariaDB"
    DB_PACKAGE_NAME="mariadb-server"
    DB_CLIENT_PACKAGE="mariadb-client"
    DB_SECURE_COMMAND="mariadb-secure-installation"
    ;;
2)
    DB_SERVER_NAME="MySQL"
    DB_PACKAGE_NAME="mysql-server"
    DB_CLIENT_PACKAGE="mysql-client"
    DB_SECURE_COMMAND="mysql_secure_installation"
    ;;
3)
    DB_SERVER_NAME="PostgreSQL"
    DB_PACKAGE_NAME="postgresql postgresql-contrib" # postgresql-client se instala como dependencia de postgresql
    DB_CLIENT_PACKAGE="postgresql-client"           # Aunque ya venga, para ser explícitos
    DB_PORT=5432
    # PostgreSQL tiene un método de configuración de seguridad diferente.
    ;;
4)
    echo "No se instalará ningún servidor de base de datos. Saliendo."
    exit 0
    ;;
*)
    echo "Opción no válida. Saliendo."
    exit 1
    ;;
esac

echo "Ha seleccionado instalar: $DB_SERVER_NAME"
echo # Salto de línea

# --- Actualizar Paquetes del Sistema (Opcional) ---
if confirm_action "actualizar los paquetes del sistema antes de la instalación"; then
    echo "Actualizando paquetes del sistema..."
    apt update && apt full-upgrade -y && apt autoremove -y && apt clean -y
    echo "Actualización de paquetes completada."
    echo # Salto de línea
fi

# --- Instalación del Servidor de Base de Datos ---
echo "Instalando $DB_SERVER_NAME..."
apt install $DB_PACKAGE_NAME -y
if [ $? -ne 0 ]; then
    echo "Error durante la instalación de $DB_SERVER_NAME. Abortando."
    exit 1
fi
echo "Instalación de $DB_SERVER_NAME completada."
echo # Salto de línea

# --- Configuración de Seguridad ---
if [[ "$DB_SERVER_NAME" == "MariaDB" || "$DB_SERVER_NAME" == "MySQL" ]]; then
    if confirm_action "ejecutar $DB_SECURE_COMMAND para asegurar $DB_SERVER_NAME"; then
        echo "Por favor, siga las instrucciones en pantalla para $DB_SECURE_COMMAND."
        $DB_SECURE_COMMAND
        echo "Configuración de seguridad inicial para $DB_SERVER_NAME completada."
    else
        echo "Omitiendo $DB_SECURE_COMMAND. Recuerde asegurar su instalación manualmente."
    fi
elif [[ "$DB_SERVER_NAME" == "PostgreSQL" ]]; then
    echo "Configuración inicial de PostgreSQL:"
    echo "- Por defecto, PostgreSQL usa autenticación 'peer' para conexiones locales."
    echo "- Para conectarse como usuario 'postgres', puede usar: sudo -u postgres psql"
    echo "- Se recomienda crear un usuario específico para sus bases de datos y cambiar la contraseña del usuario 'postgres'."

    if confirm_action "establecer una contraseña para el usuario 'postgres' de PostgreSQL"; then
        echo "Estableciendo contraseña para el usuario 'postgres'..."
        # Esto requiere que el usuario ingrese la nueva contraseña dos veces
        sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'nueva_contraseña_aqui';"
        echo "Recuerda cambiar 'nueva_contraseña_aqui' por una contraseña segura."
        echo "Contraseña para 'postgres' establecida (o intento realizado)."
        echo "Puede que necesites ajustar pg_hba.conf para permitir la conexión con contraseña (md5 o scram-sha-256)."
    fi

    echo "Para más detalles sobre la configuración de seguridad de PostgreSQL, consulta la documentación oficial."
    echo "Archivos de configuración principales: postgresql.conf y pg_hba.conf"
    # Ubicación típica en Ubuntu
    PG_VERSION_DIR=$(ls /etc/postgresql/) # Esto podría devolver varias versiones si están instaladas
    # Tomar la primera o la más alta. Para simplificar, tomamos la primera.
    PG_MAIN_DIR_GUESS=$(ls -d /etc/postgresql/*/main 2>/dev/null | head -n 1)
    if [ -n "$PG_MAIN_DIR_GUESS" ]; then
        echo "Directorio de configuración probable: $PG_MAIN_DIR_GUESS"
    fi
fi
echo # Salto de línea

# --- Configuración del Firewall (UFW) ---
if command -v ufw >/dev/null 2>&1; then
    if confirm_action "configurar UFW para permitir conexiones a $DB_SERVER_NAME en el puerto $DB_PORT"; then
        read -p "¿Permitir conexiones solo desde localhost (l) o desde IPs específicas/any (e)? (l/e) [l]: " ufw_scope
        ufw_scope=${ufw_scope:-l}

        if [[ "$ufw_scope" == "l" ]]; then
            ufw allow from 127.0.0.1 to any port $DB_PORT proto tcp comment "$DB_SERVER_NAME localhost"
            echo "Regla de UFW añadida para permitir $DB_SERVER_NAME desde localhost en el puerto $DB_PORT."
        elif [[ "$ufw_scope" == "e" ]]; then
            read -p "¿Desde qué dirección IP o rango se permitirán conexiones? (ej: 192.168.1.0/24, 'any' para todas) [ninguna]: " remote_ip
            if [[ -n "$remote_ip" ]] && [[ "$remote_ip" != "ninguna" ]]; then
                ufw allow from $remote_ip to any port $DB_PORT proto tcp comment "$DB_SERVER_NAME remote from $remote_ip"
                echo "Regla de UFW añadida para permitir $DB_SERVER_NAME desde $remote_ip en el puerto $DB_PORT."
                echo "Recuerda configurar $DB_SERVER_NAME para escuchar en interfaces externas si es necesario (ej. listen_addresses = '*' en postgresql.conf o bind-address = 0.0.0.0 en my.cnf)."
            else
                echo "No se especificó IP remota. No se añadió regla de UFW para acceso externo."
            fi
        fi
        echo "Asegúrate de que UFW esté habilitado ('sudo ufw enable')."
    else
        echo "Omitiendo configuración de UFW. Si UFW está activo, deberás configurar las reglas manualmente."
    fi
else
    echo "UFW no está instalado. No se realizarán configuraciones de firewall."
fi
echo # Salto de línea

# --- Estado del Servicio ---
SERVICE_NAME=""
if [[ "$DB_SERVER_NAME" == "MariaDB" ]]; then
    SERVICE_NAME="mariadb"
elif [[ "$DB_SERVER_NAME" == "MySQL" ]]; then
    SERVICE_NAME="mysql"
elif [[ "$DB_SERVER_NAME" == "PostgreSQL" ]]; then
    # El nombre del servicio de PostgreSQL puede variar ligeramente con la versión, pero 'postgresql' suele funcionar.
    SERVICE_NAME="postgresql"
fi

if [ -n "$SERVICE_NAME" ]; then
    echo "Verificando estado del servicio $SERVICE_NAME..."
    systemctl status $SERVICE_NAME --no-pager

    if confirm_action "habilitar el servicio $SERVICE_NAME para que inicie con el sistema"; then
        systemctl enable $SERVICE_NAME
        echo "Servicio $SERVICE_NAME habilitado para el inicio."
    fi
else
    echo "No se pudo determinar el nombre del servicio para $DB_SERVER_NAME."
fi
echo # Salto de línea

echo "=== INSTALACIÓN DE $DB_SERVER_NAME COMPLETADA ==="
echo "Resumen:"
echo "- Servidor: $DB_SERVER_NAME"
echo "- Paquete(s) instalado(s): $DB_PACKAGE_NAME"
if [[ "$DB_SERVER_NAME" == "MariaDB" || "$DB_SERVER_NAME" == "MySQL" ]]; then
    echo "- Considera revisar la configuración en /etc/mysql/ (o /etc/mysql/mariadb.conf.d/ para MariaDB)."
    echo "- Cliente: $DB_CLIENT_PACKAGE (puedes instalarlo con 'sudo apt install $DB_CLIENT_PACKAGE' si no se instaló como dependencia)."
elif [[ "$DB_SERVER_NAME" == "PostgreSQL" ]]; then
    echo "- Archivos de configuración principales en $PG_MAIN_DIR_GUESS (postgresql.conf, pg_hba.conf)."
    echo "- Cliente: $DB_CLIENT_PACKAGE (puedes instalarlo con 'sudo apt install $DB_CLIENT_PACKAGE')."
fi
echo "- Puerto por defecto: $DB_PORT"
echo # Salto de línea
echo "Recuerda configurar usuarios, bases de datos y permisos según tus necesidades."
