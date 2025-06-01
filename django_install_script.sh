#!/bin/bash

# Este script automatiza la instalación de un stack completo para Django Python
# optimizado para desarrollo y producción en Ubuntu.
# Incluye Python, Django, PostgreSQL, Redis, Nginx, Gunicorn y herramientas adicionales.
# Cada componente es opcional y puede elegir instalarlo o no.
# Se puede elegir entre repositorios oficiales o de la distribución.

# Asegurar ejecución como root
if [[ "$EUID" -ne 0 ]]; then
    echo "Por favor, ejecuta este script como root."
    exit 1
fi

echo # Salto de línea
echo "=== INSTALACIÓN DE SERVIDOR DJANGO EN UBUNTU ==="
echo # Salto de línea

echo "Este script puede instalar Python, PostgreSQL, Redis, Nginx, y herramientas para Django."
echo "Cada componente es opcional. Se puede elegir la fuente de los paquetes (oficial o local/distribución)."
echo "En entornos de desarrollo prefiera las versiones oficiales de los paquetes."
echo "En entornos de producción considere las versiones de los paquetes del sistema para mayor estabilidad."
echo # Salto de línea

# --- Variables Globales ---
PYTHON_VERSION_SELECTED="" # Guardará la versión de Python seleccionada (ej. 3.11)
POSTGRES_VERSION_SELECTED="" # Guardará la versión de PostgreSQL seleccionada
ENVIRONMENT_TYPE="" # desarrollo o produccion
PROJECT_USER="" # Usuario para proyectos Django

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

choose_environment_type() {
    read -p "¿Este servidor será para desarrollo (d) o producción (p)? (d/p) [d]: " env_type
    env_type=${env_type:-d}
    if [[ "$env_type" == "p" ]]; then
        ENVIRONMENT_TYPE="produccion"
    else
        ENVIRONMENT_TYPE="desarrollo"
    fi
    echo "Configurando para entorno de $ENVIRONMENT_TYPE..."
}

# --- Elegir tipo de entorno ---
choose_environment_type
echo # Salto de línea

# --- Actualizar Paquetes del Sistema ---
read -p "¿Desea actualizar los paquetes del sistema? (s/n): " update_system
if [[ "$update_system" == "s" ]]; then
    echo "Actualizando paquetes del sistema..."
    apt update && apt full-upgrade -y && apt autoremove -y && apt clean -y
    echo "Actualización de paquetes completada."
    echo # Salto de línea
fi

# --- Instalar dependencias básicas ---
echo "Instalando dependencias básicas del sistema..."
apt install -y curl wget gnupg2 software-properties-common apt-transport-https \
    ca-certificates lsb-release build-essential git vim nano htop tree \
    unzip zip python3-pip python3-venv python3-dev libpq-dev pkg-config
echo "Dependencias básicas instaladas."
echo # Salto de línea

# --- Crear usuario para proyectos Django ---
if [[ "$ENVIRONMENT_TYPE" == "produccion" ]]; then
    read -p "¿Desea crear un usuario específico para proyectos Django? (s/n) [s]: " create_django_user
    create_django_user=${create_django_user:-s}
    if [[ "$create_django_user" == "s" ]]; then
        read -p "Nombre del usuario para proyectos Django [django]: " django_username
        django_username=${django_username:-django}
        
        if ! id "$django_username" &>/dev/null; then
            useradd -m -s /bin/bash "$django_username"
            echo "Usuario $django_username creado."
            PROJECT_USER="$django_username"
        else
            echo "El usuario $django_username ya existe."
            PROJECT_USER="$django_username"
        fi
    fi
    echo # Salto de línea
fi

# --- Instalar Python ---
if confirm_install "Python (versión específica)"; then
    PYTHON_REPO_SOURCE=$(choose_repository_source "Python")

    if [[ "$PYTHON_REPO_SOURCE" == "oficial" ]]; then
        echo "Versiones disponibles de Python (desde ppa:deadsnakes/ppa):"
        echo "1) Python 3.9"
        echo "2) Python 3.10"
        echo "3) Python 3.11 (Recomendado)"
        echo "4) Python 3.12"
        read -p "Seleccione la versión de Python a instalar (1-4) [3]: " python_version_option
        python_version_option=${python_version_option:-3}

        case $python_version_option in
        1) PYTHON_VERSION_SELECTED="3.9" ;;
        2) PYTHON_VERSION_SELECTED="3.10" ;;
        3) PYTHON_VERSION_SELECTED="3.11" ;;
        4) PYTHON_VERSION_SELECTED="3.12" ;;
        *)
            PYTHON_VERSION_SELECTED="3.11"
            echo "Opción no válida, se instalará Python 3.11 por defecto."
            ;;
        esac

        echo "Instalando Python $PYTHON_VERSION_SELECTED desde ppa:deadsnakes/ppa..."
        add-apt-repository ppa:deadsnakes/ppa -y
        apt update
        apt install -y python$PYTHON_VERSION_SELECTED python$PYTHON_VERSION_SELECTED-venv \
            python$PYTHON_VERSION_SELECTED-dev python$PYTHON_VERSION_SELECTED-distutils
        
        # Crear enlaces simbólicos
        update-alternatives --install /usr/bin/python3 python3 /usr/bin/python$PYTHON_VERSION_SELECTED 1
        
        echo "Python $PYTHON_VERSION_SELECTED instalado y configurado como python3 por defecto."
    else
        echo "Usando Python de la distribución..."
        PYTHON_VERSION_SELECTED=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
        echo "Python versión $PYTHON_VERSION_SELECTED detectada."
    fi
    
    # Actualizar pip
    python3 -m pip install --upgrade pip
    echo "pip actualizado."
    echo # Salto de línea
fi

# --- Instalar PostgreSQL ---
if confirm_install "PostgreSQL"; then
    POSTGRES_REPO_SOURCE=$(choose_repository_source "PostgreSQL")
    
    if [[ "$POSTGRES_REPO_SOURCE" == "oficial" ]]; then
        echo "Versiones disponibles de PostgreSQL:"
        echo "1) PostgreSQL 13"
        echo "2) PostgreSQL 14"
        echo "3) PostgreSQL 15"
        echo "4) PostgreSQL 16 (Recomendado)"
        read -p "Seleccione la versión de PostgreSQL (1-4) [4]: " postgres_version_option
        postgres_version_option=${postgres_version_option:-4}

        case $postgres_version_option in
        1) POSTGRES_VERSION_SELECTED="13" ;;
        2) POSTGRES_VERSION_SELECTED="14" ;;
        3) POSTGRES_VERSION_SELECTED="15" ;;
        4) POSTGRES_VERSION_SELECTED="16" ;;
        *)
            POSTGRES_VERSION_SELECTED="16"
            echo "Opción no válida, se instalará PostgreSQL 16 por defecto."
            ;;
        esac

        echo "Instalando PostgreSQL $POSTGRES_VERSION_SELECTED desde repositorio oficial..."
        wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
        echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list
        apt update
        apt install -y postgresql-$POSTGRES_VERSION_SELECTED postgresql-client-$POSTGRES_VERSION_SELECTED \
            postgresql-contrib-$POSTGRES_VERSION_SELECTED
    else
        echo "Instalando PostgreSQL desde repositorios de la distribución..."
        apt install -y postgresql postgresql-contrib
        POSTGRES_VERSION_SELECTED=$(sudo -u postgres psql -c "SHOW server_version;" | grep PostgreSQL | awk '{print $2}' | cut -d'.' -f1)
    fi

    echo "Configurando PostgreSQL..."
    systemctl start postgresql
    systemctl enable postgresql

    # Configurar usuario de PostgreSQL para Django
    read -p "¿Desea crear un usuario de base de datos para Django? (s/n) [s]: " create_db_user
    create_db_user=${create_db_user:-s}
    if [[ "$create_db_user" == "s" ]]; then
        read -p "Nombre del usuario de la base de datos [django_user]: " db_username
        db_username=${db_username:-django_user}
        read -s -p "Contraseña para el usuario de la base de datos: " db_password
        echo

        sudo -u postgres psql -c "CREATE USER $db_username WITH PASSWORD '$db_password';"
        sudo -u postgres psql -c "ALTER USER $db_username CREATEDB;"
        echo "Usuario de base de datos $db_username creado con permisos para crear bases de datos."
    fi

    echo "PostgreSQL $POSTGRES_VERSION_SELECTED instalado y configurado."
    echo # Salto de línea
fi

# --- Instalar Redis ---
if confirm_install "Redis (caché y cola de tareas)"; then
    REDIS_REPO_SOURCE=$(choose_repository_source "Redis")
    
    if [[ "$REDIS_REPO_SOURCE" == "oficial" ]]; then
        echo "Instalando Redis desde repositorio oficial..."
        curl -fsSL https://packages.redis.io/gpg | gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" > /etc/apt/sources.list.d/redis.list
        apt update
        apt install -y redis
    else
        echo "Instalando Redis desde repositorios de la distribución..."
        apt install -y redis-server
    fi

    echo "Configurando Redis..."
    systemctl start redis-server
    systemctl enable redis-server

    # Configuración básica de seguridad para Redis
    if [[ "$ENVIRONMENT_TYPE" == "produccion" ]]; then
        read -p "¿Desea configurar una contraseña para Redis? (s/n) [s]: " set_redis_password
        set_redis_password=${set_redis_password:-s}
        if [[ "$set_redis_password" == "s" ]]; then
            read -s -p "Contraseña para Redis: " redis_password
            echo
            sed -i "s/# requirepass foobared/requirepass $redis_password/" /etc/redis/redis.conf
            systemctl restart redis-server
            echo "Contraseña de Redis configurada."
        fi
    fi

    echo "Redis instalado y configurado."
    echo # Salto de línea
fi

# --- Instalar Nginx (solo para producción) ---
if [[ "$ENVIRONMENT_TYPE" == "produccion" ]] && confirm_install "Nginx (servidor web)"; then
    NGINX_REPO_SOURCE=$(choose_repository_source "Nginx")
    
    if [[ "$NGINX_REPO_SOURCE" == "oficial" ]]; then
        echo "Instalando Nginx desde repositorio oficial..."
        curl -fsSL https://nginx.org/keys/nginx_signing.key | apt-key add -
        echo "deb https://nginx.org/packages/ubuntu $(lsb_release -cs) nginx" > /etc/apt/sources.list.d/nginx.list
        apt update
        apt install -y nginx
    else
        echo "Instalando Nginx desde repositorios de la distribución..."
        apt install -y nginx
    fi

    echo "Configurando Nginx..."
    systemctl start nginx
    systemctl enable nginx

    # Configuración básica de Nginx para Django
    cat > /etc/nginx/sites-available/django_template << 'EOF'
# Plantilla de configuración para proyectos Django
# Copiar y modificar según necesidades

server {
    listen 80;
    server_name tu_dominio.com www.tu_dominio.com;
    
    # Logs
    access_log /var/log/nginx/django_access.log;
    error_log /var/log/nginx/django_error.log;
    
    # Archivos estáticos
    location /static/ {
        alias /home/django/tu_proyecto/staticfiles/;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    
    # Archivos de media
    location /media/ {
        alias /home/django/tu_proyecto/media/;
    }
    
    # Proxy a Gunicorn
    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

    echo "Nginx instalado. Plantilla de configuración creada en /etc/nginx/sites-available/django_template"
    echo # Salto de línea
fi

# --- Instalar herramientas Python para Django ---
if confirm_install "Herramientas Python para Django (Django, Gunicorn, psycopg2, etc.)"; then
    echo "Instalando herramientas Python para Django..."
    
    # Crear directorio para entornos virtuales
    VENV_DIR="/opt/venv"
    if [[ "$ENVIRONMENT_TYPE" == "desarrollo" ]]; then
        CURRENT_USER=$(logname 2>/dev/null || echo $SUDO_USER)
        if [ -n "$CURRENT_USER" ] && [ "$CURRENT_USER" != "root" ]; then
            VENV_DIR="/home/$CURRENT_USER/venvs"
            sudo -u "$CURRENT_USER" mkdir -p "$VENV_DIR"
        fi
    else
        mkdir -p "$VENV_DIR"
        if [ -n "$PROJECT_USER" ]; then
            chown -R "$PROJECT_USER:$PROJECT_USER" "$VENV_DIR"
        fi
    fi

    # Lista de paquetes Python esenciales
    PYTHON_PACKAGES=(
        "Django>=4.2,<5.0"
        "gunicorn"
        "psycopg2-binary"
        "redis"
        "celery"
        "django-redis"
        "python-decouple"
        "whitenoise"
        "Pillow"
        "requests"
    )

    # Paquetes adicionales para desarrollo
    if [[ "$ENVIRONMENT_TYPE" == "desarrollo" ]]; then
        PYTHON_PACKAGES+=(
            "django-debug-toolbar"
            "django-extensions"
            "ipython"
            "pytest"
            "pytest-django"
            "black"
            "flake8"
            "isort"
        )
    fi

    # Instalar paquetes globalmente o crear un entorno virtual de ejemplo
    read -p "¿Desea crear un entorno virtual de ejemplo con Django? (s/n) [s]: " create_example_venv
    create_example_venv=${create_example_venv:-s}
    
    if [[ "$create_example_venv" == "s" ]]; then
        EXAMPLE_VENV_PATH="$VENV_DIR/django_example"
        echo "Creando entorno virtual de ejemplo en $EXAMPLE_VENV_PATH..."
        
        if [[ "$ENVIRONMENT_TYPE" == "desarrollo" && -n "$CURRENT_USER" && "$CURRENT_USER" != "root" ]]; then
            sudo -u "$CURRENT_USER" python3 -m venv "$EXAMPLE_VENV_PATH"
            sudo -u "$CURRENT_USER" "$EXAMPLE_VENV_PATH/bin/pip" install --upgrade pip
            for package in "${PYTHON_PACKAGES[@]}"; do
                sudo -u "$CURRENT_USER" "$EXAMPLE_VENV_PATH/bin/pip" install "$package"
            done
        else
            python3 -m venv "$EXAMPLE_VENV_PATH"
            "$EXAMPLE_VENV_PATH/bin/pip" install --upgrade pip
            for package in "${PYTHON_PACKAGES[@]}"; do
                "$EXAMPLE_VENV_PATH/bin/pip" install "$package"
            done
            if [ -n "$PROJECT_USER" ]; then
                chown -R "$PROJECT_USER:$PROJECT_USER" "$EXAMPLE_VENV_PATH"
            fi
        fi
        echo "Entorno virtual de ejemplo creado en $EXAMPLE_VENV_PATH"
        echo "Para activarlo: source $EXAMPLE_VENV_PATH/bin/activate"
    else
        echo "Instalando paquetes Python globalmente..."
        for package in "${PYTHON_PACKAGES[@]}"; do
            pip3 install "$package"
        done
    fi

    echo "Herramientas Python para Django instaladas."
    echo # Salto de línea
fi

# --- Instalar herramientas adicionales de desarrollo ---
if [[ "$ENVIRONMENT_TYPE" == "desarrollo" ]] && confirm_install "Herramientas adicionales de desarrollo"; then
    echo "Instalando herramientas adicionales de desarrollo..."
    
    # Node.js y npm (para herramientas de frontend)
    if confirm_install "Node.js y npm (para herramientas de frontend)"; then
        curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
        apt install -y nodejs
        echo "Node.js y npm instalados."
    fi
    
    # Docker (opcional)
    if confirm_install "Docker (para contenedores)"; then
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
        apt update
        apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
        
        # Añadir usuario al grupo docker
        CURRENT_USER=$(logname 2>/dev/null || echo $SUDO_USER)
        if [ -n "$CURRENT_USER" ] && [ "$CURRENT_USER" != "root" ]; then
            usermod -aG docker "$CURRENT_USER"
            echo "Usuario $CURRENT_USER añadido al grupo docker."
        fi
        
        systemctl start docker
        systemctl enable docker
        echo "Docker instalado y configurado."
    fi
    
    echo "Herramientas adicionales de desarrollo instaladas."
    echo # Salto de línea
fi

# --- Configurar UFW (Firewall) ---
if confirm_install "UFW (Uncomplicated Firewall)"; then
    echo "Instalando y configurando UFW..."
    apt install -y ufw

    echo "Configurando reglas básicas de UFW..."
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow ssh

    # Reglas específicas según el entorno
    if [[ "$ENVIRONMENT_TYPE" == "produccion" ]]; then
        if command -v nginx >/dev/null 2>&1; then
            ufw allow 'Nginx Full'
            echo "Reglas para Nginx añadidas a UFW."
        fi
    else
        # Para desarrollo, permitir puerto 8000 (Django dev server)
        ufw allow 8000/tcp
        echo "Puerto 8000 (Django dev server) permitido en UFW."
    fi

    read -p "¿Desea habilitar UFW ahora? (s/n) [s]: " enable_ufw_now
    enable_ufw_now=${enable_ufw_now:-s}
    if [[ "$enable_ufw_now" == "s" ]]; then
        echo "y" | ufw enable
        ufw status verbose
        echo "UFW habilitado y configurado."
    else
        echo "UFW configurado pero NO habilitado. Ejecuta 'sudo ufw enable' para activarlo."
    fi
    echo # Salto de línea
fi

# --- Crear estructura de directorios para proyectos ---
if [[ "$ENVIRONMENT_TYPE" == "produccion" ]] && [ -n "$PROJECT_USER" ]; then
    echo "Creando estructura de directorios para proyectos Django..."
    PROJECT_HOME="/home/$PROJECT_USER"
    sudo -u "$PROJECT_USER" mkdir -p "$PROJECT_HOME/projects"
    sudo -u "$PROJECT_USER" mkdir -p "$PROJECT_HOME/logs"
    sudo -u "$PROJECT_USER" mkdir -p "$PROJECT_HOME/static"
    sudo -u "$PROJECT_USER" mkdir -p "$PROJECT_HOME/media"
    echo "Estructuras de directorios creadas en $PROJECT_HOME"
    echo # Salto de línea
fi

# --- Configurar variables de entorno del sistema ---
echo "Configurando variables de entorno del sistema..."
cat >> /etc/environment << EOF
# Variables para Django
DJANGO_SETTINGS_MODULE=myproject.settings.production
DJANGO_SECRET_KEY=your-secret-key-here
DATABASE_URL=postgresql://django_user:password@localhost/django_db
REDIS_URL=redis://localhost:6379/0
EOF
echo "Variables de entorno básicas añadidas a /etc/environment"
echo # Salto de línea

# --- Resumen Final ---
echo "=== RESUMEN DE INSTALACIÓN SERVIDOR DJANGO ==="
echo "Tipo de entorno: $ENVIRONMENT_TYPE"
# Python
if command -v python3 >/dev/null 2>&1; then echo "✓ Python $PYTHON_VERSION_SELECTED instalado"; else echo "✗ Python no instalado"; fi
# PostgreSQL  
if command -v psql >/dev/null 2>&1; then echo "✓ PostgreSQL $POSTGRES_VERSION_SELECTED instalado"; else echo "✗ PostgreSQL no instalado"; fi
# Redis
if command -v redis-server >/dev/null 2>&1; then echo "✓ Redis instalado"; else echo "✗ Redis no instalado"; fi
# Nginx
if command -v nginx >/dev/null 2>&1; then echo "✓ Nginx instalado"; else echo "✗ Nginx no instalado"; fi
# Django (verificar en el entorno virtual de ejemplo si existe)
if [ -f "$VENV_DIR/django_example/bin/django-admin" ]; then echo "✓ Django instalado (entorno virtual de ejemplo)"; else echo "✗ Django no instalado"; fi
# UFW
if command -v ufw >/dev/null 2>&1; then echo "✓ UFW instalado/configurado"; else echo "✗ UFW no instalado"; fi
echo # Salto de línea

echo "PRÓXIMOS PASOS:"
echo "1. CONFIGURACIÓN DE BASE DE DATOS:"
echo "   - Crear base de datos para tu proyecto: sudo -u postgres createdb nombre_proyecto"
echo "   - Configurar settings.py con los datos de conexión"

echo "2. CREAR PROYECTO DJANGO:"
if [ -f "$VENV_DIR/django_example/bin/activate" ]; then
    echo "   - Activar entorno virtual: source $VENV_DIR/django_example/bin/activate"
else
    echo "   - Crear entorno virtual: python3 -m venv mi_proyecto_venv"
    echo "   - Activar entorno virtual: source mi_proyecto_venv/bin/activate"
    echo "   - Instalar Django: pip install Django"
fi
echo "   - Crear proyecto: django-admin startproject nombre_proyecto"
echo "   - Configurar settings.py (base de datos, archivos estáticos, etc.)"

if [[ "$ENVIRONMENT_TYPE" == "produccion" ]]; then
    echo "3. CONFIGURACIÓN DE PRODUCCIÓN:"
    echo "   - Configurar Nginx virtual host (usar plantilla en /etc/nginx/sites-available/django_template)"
    echo "   - Configurar Gunicorn como servicio systemd"
    echo "   - Configurar SSL/HTTPS con Let's Encrypt (certbot)"
    echo "   - Configurar colección de archivos estáticos: python manage.py collectstatic"
    if [ -n "$PROJECT_USER" ]; then
        echo "   - Todos los proyectos deben ejecutarse como usuario: $PROJECT_USER"
    fi
else
    echo "3. DESARROLLO:"
    echo "   - Ejecutar servidor de desarrollo: python manage.py runserver"
    echo "   - Acceder a http://localhost:8000"
fi

echo "4. CONFIGURACIONES ADICIONALES:"
echo "   - Editar /etc/environment con tus variables de entorno reales"
echo "   - Configurar Celery para tareas asíncronas (si es necesario)"
echo "   - Configurar backups de base de datos"

if [[ "$ENVIRONMENT_TYPE" == "desarrollo" ]]; then
    CURRENT_USER=$(logname 2>/dev/null || echo $SUDO_USER)
    if [ -n "$CURRENT_USER" ] && [ "$CURRENT_USER" != "root" ]; then
        echo "   - Reiniciar sesión para aplicar cambios de grupos de usuario ($CURRENT_USER)"
    fi
fi

echo # Salto de línea
echo "Instalación del servidor Django completada."
echo "Documentación de Django: https://docs.djangoproject.com/"