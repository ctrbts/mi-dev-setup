#!/bin/bash

# ==============================================================================
# Script para configurar un entorno de desarrollo profesional en Ubuntu.
#
# Stack: PHP, Apache, Nginx, Python, y MariaDB (vía Docker).
# Versión 2: Corregido para ser compatible con versiones de desarrollo de Ubuntu.
#
# Ejecución:
# 1. Guardar como 'setup_dev_env.sh'
# 2. Dar permisos: chmod +x setup_dev_env.sh
# 3. Ejecutar: ./setup_dev_env.sh
# ==============================================================================

# Detener la ejecución del script si un comando falla.
set -e

# --- Variables de Color para una salida más legible ---
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Sin Color

# --- Funciones de Instalación Modulares ---

# 1. Instala paquetes básicos y dependencias de compilación.
install_essentials() {
    echo -e "${BLUE}--- 1. Actualizando el sistema e instalando herramientas esenciales ---${NC}"
    sudo apt-get update
    sudo apt-get upgrade -y
    sudo apt-get install -y \
    curl \
    wget \
    vim \
    nano \
    git \
    zsh \
    build-essential \
    make \
    cmake \
    gcc \
    g++ \
    dpkg-dev \
    net-tools \
    httping \
    iputils-ping \
    iputils-tracepath \
    dnsutils \
    smartmontools \
    traceroute \
    whois \
    neofetch \
    nmap \
    ca-certificates \
    gnupg \
    htop \
    ncdu \
    unzip \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    llvm \
    libncurses5-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libxml2-dev \
    libxmlsec1-dev \
    libffi-dev \
    liblzma-dev \
    libcurl4-openssl-dev \
    libonig-dev \
    libzip-dev \
    libxslt-dev
    echo -e "${GREEN}Herramientas esenciales y dependencias de compilación instaladas.${NC}"
}

# 2. Instala Docker y Docker Compose para gestionar servicios como MariaDB.
install_docker() {
    echo -e "${BLUE}--- 2. Instalando Docker y Docker Compose ---${NC}"
    
    # --- LÓGICA MEJORADA PARA COMPATIBILIDAD ---
    # Determinar el codename de la versión de Ubuntu
    source /etc/os-release
    UBUNTU_CODENAME=$VERSION_CODENAME

    # Para versiones de desarrollo, Docker no tiene un repo oficial.
    # Hacemos un fallback al repo de la última versión LTS estable (ej. Noble 24.04).
    case "$UBUNTU_CODENAME" in
        # Lista de codenames estables conocidos para los que Docker tiene repos
        "jammy" | "noble")
            DOCKER_CODENAME=$UBUNTU_CODENAME
            ;;
        # Para cualquier otro (versiones de desarrollo como oracular), usar el último LTS
        *)
            echo -e "${YELLOW}Versión de desarrollo de Ubuntu ('$UBUNTU_CODENAME') detectada.${NC}"
            echo -e "${YELLOW}Haciendo fallback al repositorio de Docker para Ubuntu 24.04 (noble).${NC}"
            DOCKER_CODENAME="noble"
            ;;
    esac

    # Añadir el repositorio oficial de Docker si no existe
    if [ ! -f /etc/apt/sources.list.d/docker.list ]; then
        sudo install -m 0755 -d /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        sudo chmod a+r /etc/apt/keyrings/docker.gpg

        echo \
          "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
          $DOCKER_CODENAME stable" | \
          sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        
        sudo apt-get update
    fi

    # Instalar los paquetes de Docker
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # Añadir el usuario actual al grupo 'docker' para evitar usar 'sudo'
    if ! getent group docker | grep -q "\b$USER\b"; then
        sudo usermod -aG docker $USER
        echo -e "${YELLOW}Tu usuario ha sido añadido al grupo 'docker'.${NC}"
    fi
    
    # Activar y habilitar el servicio de Docker
    sudo systemctl enable docker.service
    sudo systemctl enable containerd.service

    echo -e "${GREEN}Docker instalado. Es la herramienta recomendada para gestionar MariaDB.${NC}"
}

# 3. Instala el gestor de versiones asdf y los plugins para tu stack.
install_asdf() {
    echo -e "${BLUE}--- 3. Instalando asdf y plugins ---${NC}"
    # Clonar el repositorio de asdf si no existe
    if [ ! -d "$HOME/.asdf" ]; then
        git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.0
    fi

    # Añadir asdf a bashrc (asumiendo Bash como shell por defecto)
    if ! grep -q ".asdf/asdf.sh" ~/.bashrc; then
        echo -e '\n# --- Configuración de asdf ---' >> ~/.bashrc
        echo '. "$HOME/.asdf/asdf.sh"' >> ~/.bashrc
        echo '. "$HOME/.asdf/completions/asdf.bash"' >> ~/.bashrc
    fi
    
    # Cargar asdf en la sesión actual para poder usar sus comandos
    # shellcheck source=/dev/null
    source "$HOME/.asdf/asdf.sh"

    # Instalar plugins para tu stack (usamos '|| true' para no fallar si ya existen)
    echo "Instalando plugins de asdf para tu stack..."
    asdf plugin add python || true
    asdf plugin add php || true
    asdf plugin add httpd || true # Para Apache HTTP Server
    asdf plugin add nginx || true

    echo -e "${GREEN}asdf y plugins (python, php, httpd, nginx) instalados.${NC}"
}

# 4. Instala Visual Studio Code (opcional pero muy recomendado).
install_vscode() {
    echo -e "${BLUE}--- 4. (Opcional) Instalando Visual Studio Code ---${NC}"
    if ! command -v code &> /dev/null; then
        # Añadir el repositorio y la clave de Microsoft
        sudo apt-get install -y wget gpg
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
        sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
        sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
        rm -f packages.microsoft.gpg

        # Instalar VS Code
        sudo apt-get install -y apt-transport-https
        sudo apt-get update
        sudo apt-get install -y code
        echo -e "${GREEN}Visual Studio Code instalado.${NC}"
    else
        echo -e "${YELLOW}Visual Studio Code ya está instalado.${NC}"
    fi
}

# --- Función Principal que orquesta la ejecución ---
main() {
    install_essentials
    install_docker
    install_asdf
    install_vscode

    echo -e "\n\n${GREEN}✅ ¡Entorno de desarrollo configurado! ✅${NC}"
    echo -e "\n${YELLOW}--- Pasos Finales MUY IMPORTANTES ---${NC}"
    echo "1. Para usar Docker sin 'sudo', necesitas ${GREEN}CERRAR SESIÓN Y VOLVER A INICIARLA${NC}."
    echo "2. Para que los cambios de 'asdf' se apliquen, cierra y vuelve a abrir tu terminal o ejecuta: ${GREEN}source ~/.bashrc${NC}"
    echo "3. Una vez reiniciada la terminal, puedes instalar versiones de tus herramientas. Por ejemplo:"
    echo -e "   ${GREEN}asdf install php 8.3.9${NC}"
    echo -e "   ${GREEN}asdf global php 8.3.9${NC}"
    echo -e "\n${YELLOW}Recordatorio sobre MariaDB:${NC} La mejor práctica es gestionar tus bases de datos con Docker Compose dentro de cada proyecto."
    echo "Crea un archivo 'docker-compose.yml' para definir tu servicio de MariaDB."
}

# --- Punto de Entrada del Script ---
main

