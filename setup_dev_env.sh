#!/bin/bash

# ==============================================================================
# SysCraft Ultimate Post-Install Script for Ubuntu Developer Workstation
#
# VERSIÓN FINAL 2.1:
# - ACTUALIZADO: La instalación de asdf ahora utiliza el método oficial con
#   el binario de Go, descargando la última release desde GitHub.
# - REVISADO: Se mantiene la lógica de fallback a LTS para Docker por ser
#   la más robusta para versiones intermedias.
#
# Uso:
#   chmod +x post_install.sh
#   ./post_install.sh [OPCIÓN]
#
# Opciones:
#   --all         (Default) Instala todo: dev, diseño y productividad.
#   --dev-only    Instala solo las herramientas de desarrollo base.
# ==============================================================================

# --- Configuración de Seguridad y Robustez ---
set -e
set -o pipefail

# --- Variables Globales y de Color ---
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)

# --- Listas de Paquetes (Fácil de modificar) ---
APT_ESSENTIALS=(
    build-essential git curl wget ca-certificates gnupg zsh ncdu unzip flatpak
    gnome-software-plugin-flatpak gnome-shell-extensions sqlitebrowser php-cli
    # Paquetes que mejoran la productividad
    gnome-sushi shotwell
    # Dependencias de compilación para asdf
    libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev llvm
    libncurses5-dev libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev
    libffi-dev liblzma-dev
)
APT_APPS=(
    google-chrome-stable docker-ce docker-ce-cli containerd.io
    docker-buildx-plugin docker-compose-plugin
)
FLATPAK_APPS=(
    org.mozilla.firefox org.videolan.VLC io.dbeaver.DBeaverCommunity
    org.gnome.Boxes org.gimp.GIMP org.inkscape.Inkscape
)
ASDF_PLUGINS=(
    python php nodejs
)

# --- Funciones de Utilidad ---
_log() { echo -e "\n${BLUE}==> $1${NC}"; }
_success() { echo -e "${GREEN}✅ $1${NC}"; }
_warning() { echo -e "${YELLOW}⚠️ $1${NC}"; }

# --- Funciones de Lógica Principal ---

# 1. Limpia configuraciones de repositorios previas para evitar conflictos.
cleanup_previous_configs() {
    _log "Fase 1: Limpiando configuraciones de repositorios previas"
    
    # Eliminar archivos de lista de repositorios
    sudo rm -f /etc/apt/sources.list.d/vscode.list \
               /etc/apt/sources.list.d/google-chrome.list \
               /etc/apt/sources.list.d/docker.list

    # Eliminar llaves GPG antiguas
    sudo rm -f /usr/share/keyrings/microsoft.gpg

    # Eliminar líneas conflictivas del archivo principal de sources.list
    if [ -f /etc/apt/sources.list ]; then
        sudo sed -i -E '/.*packages\.microsoft\.com\/repos\/code.*/d' /etc/apt/sources.list
        sudo sed -i -E '/.*dl\.google\.com\/linux\/chrome\/deb.*/d' /etc/apt/sources.list
        sudo sed -i -E '/.*download\.docker\.com\/linux\/ubuntu.*/d' /etc/apt/sources.list
    fi
    _success "Limpieza de configuraciones previas completada."
}

# 2. Erradicación completa de Snap.
remove_snap() {
    _log "Fase 2: Erradicando SnapD del sistema"
    # Si snapd no está instalado, salta esta sección
    if ! command -v snap &> /dev/null; then
        _success "Snapd no está instalado. Omitiendo."
        return
    fi

    # Desinstalar todos los snaps
    for snap in $(snap list | awk '!/^Name/{print $1}'); do
        sudo snap remove "$snap"
    done

    sudo apt purge snapd -y
    sudo rm -rf "$USER_HOME/snap" /snap /var/snap /var/lib/snapd
    
    # Bloquear reinstalación
    cat <<EOF | sudo tee /etc/apt/preferences.d/no-snap.pref
Package: snapd
Pin: release *
Pin-Priority: -1
EOF
    _success "Snapd eliminado y bloqueado."
}

# 3. Configura repositorios de terceros (Chrome, Docker).
setup_apt_repos() {
    _log "Fase 3: Configurando repositorios APT de terceros"
    sudo install -m 0755 -d /etc/apt/keyrings

    # Google Chrome
    curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor -o /etc/apt/keyrings/google-chrome.gpg
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list

    # Docker (con fallback a LTS)
    local ubuntu_codename
    ubuntu_codename=$(. /etc/os-release && echo "$VERSION_CODENAME")
    
    # Comprobar si el repositorio existe para la versión actual
    if ! curl -fsSL "https://download.docker.com/linux/ubuntu/dists/$ubuntu_codename/" | grep -q "stable"; then
        _warning "No se encontró un repositorio de Docker para '$ubuntu_codename'. Usando fallback a 'noble' (LTS)."
        ubuntu_codename="noble"
    fi

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $ubuntu_codename stable" | sudo tee /etc/apt/sources.list.d/docker.list

    _success "Repositorios de Chrome y Docker configurados."
}

# 4. Instala todos los paquetes desde APT.
install_apt_packages() {
    _log "Fase 4: Instalando paquetes esenciales y software desde APT"
    sudo apt update
    sudo DEBIAN_FRONTEND=noninteractive apt install -y "${APT_ESSENTIALS[@]}"
    sudo DEBIAN_FRONTEND=noninteractive apt install -y "${APT_APPS[@]}"
    _success "Todos los paquetes APT instalados."
}

# 5. Instala VS Code y Composer usando los métodos oficiales.
install_standalone_tools() {
    _log "Fase 5: Instalando herramientas independientes (VS Code, Composer)"

    # VS Code
    if ! command -v code &> /dev/null; then
        _log "Instalando Visual Studio Code..."
        wget -qO /tmp/vscode.deb "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
        sudo apt install -y /tmp/vscode.deb
        rm /tmp/vscode.deb
        _success "Visual Studio Code instalado."
    else
        _warning "Visual Studio Code ya está instalado. Omitiendo."
    fi

    # Composer
    if ! command -v composer &> /dev/null; then
        _log "Instalando Composer globalmente..."
        wget -qO /tmp/composer-setup.php https://getcomposer.org/installer
        sudo php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer
        rm /tmp/composer-setup.php
        _success "Composer instalado globalmente."
    else
        _warning "Composer ya está instalado. Omitiendo."
    fi
}

# 6. Configura Zsh, Oh My Zsh y los plugins.
setup_zsh() {
    _log "Fase 6: Configurando Zsh y Oh My Zsh"
    
    # Cambiar shell por defecto
    sudo chsh -s "$(which zsh)" "$SUDO_USER"
    
    # Instalar Oh My Zsh
    local oh_my_zsh_dir="$USER_HOME/.oh-my-zsh"
    if [ ! -d "$oh_my_zsh_dir" ]; then
        sudo -u "$SUDO_USER" sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh) --unattended"
    fi

    # Instalar plugins
    local custom_plugins_dir="$oh_my_zsh_dir/custom/plugins"
    sudo -u "$SUDO_USER" git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions.git "$custom_plugins_dir/zsh-autosuggestions" || true
    sudo -u "$SUDO_USER" git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$custom_plugins_dir/zsh-syntax-highlighting" || true

    # Activar plugins en .zshrc
    local zshrc_file="$USER_HOME/.zshrc"
    if [ -f "$zshrc_file" ]; then
        sudo -u "$SUDO_USER" sed -i 's/^plugins=(git)$/plugins=(git common-aliases extract colored-man-pages zsh-autosuggestions zsh-syntax-highlighting)/' "$zshrc_file"
    fi
    _success "Zsh y plugins configurados."
}

# 7. Instala aplicaciones GUI vía Flatpak.
install_flatpaks() {
    _log "Fase 7: Instalando aplicaciones GUI desde Flatpak"
    sudo flatpak remote-add-if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    sudo flatpak install -y --noninteractive flathub "${FLATPAK_APPS[@]}"
    _success "Aplicaciones Flatpak instaladas."
}

# 8. Configura el entorno de desarrollo (Docker, asdf).
setup_dev_environment() {
    _log "Fase 8: Configurando entorno de desarrollo (Docker, asdf)"

    # Docker Post-install
    sudo usermod -aG docker "$SUDO_USER"
    sudo systemctl enable --now docker.service

    # asdf (versión Go con binario)
    local asdf_data_dir="$USER_HOME/.asdf"
    if ! command -v asdf &> /dev/null; then
        _log "Instalando asdf (versión Go)..."
        local asdf_version
        asdf_version=$(curl -s "https://api.github.com/repos/asdf-vm/asdf/releases/latest" | grep -oP '"tag_name": "\K(v[0-9\.]+)')
        local asdf_tarball="asdf_${asdf_version}_linux_amd64.tar.gz"

        wget -qO "/tmp/$asdf_tarball" "https://github.com/asdf-vm/asdf/releases/download/$asdf_version/$asdf_tarball"
        
        sudo -u "$SUDO_USER" mkdir -p "$asdf_data_dir/bin"
        sudo -u "$SUDO_USER" tar -xzf "/tmp/$asdf_tarball" -C "$asdf_data_dir/bin"
        rm "/tmp/$asdf_tarball"
        
        # Configurar asdf en .zshrc
        local zshrc_file="$USER_HOME/.zshrc"
        if [ -f "$zshrc_file" ] && ! grep -q "ASDF_DATA_DIR" "$zshrc_file"; then
            # Eliminar la configuración antigua si existe
            sudo -u "$SUDO_USER" sed -i '/\. "$HOME\/\.asdf\/asdf\.sh"/d' "$zshrc_file"
            # Añadir la nueva configuración
            sudo -u "$SUDO_USER" tee -a "$zshrc_file" > /dev/null <<EOF

# --- ASDF (Go Version) ---
export ASDF_DATA_DIR=$asdf_data_dir
export PATH="\$ASDF_DATA_DIR/shims:\$ASDF_DATA_DIR/bin:\$PATH"
EOF
        fi
        _success "asdf instalado."
    else
        _warning "asdf ya está instalado. Omitiendo."
    fi
    
    # Cargar asdf en la sesión actual para instalar plugins
    export ASDF_DATA_DIR=$asdf_data_dir
    export PATH="$ASDF_DATA_DIR/shims:$ASDF_DATA_DIR/bin:$PATH"

    # Instalar plugins
    for plugin in "${ASDF_PLUGINS[@]}"; do
        if ! asdf plugin list | grep -q "$plugin"; then
            asdf plugin add "$plugin"
        fi
    done
    _success "Docker y plugins de asdf configurados."
}

# --- Función Principal que orquesta la ejecución ---
main() {
    # Verificar que se ejecuta con sudo
    if [ "$EUID" -ne 0 ]; then
        _warning "Este script debe ser ejecutado con sudo."
        exit 1
    fi

    # Parseo de argumentos
    MODE="all"
    if [[ "$1" == "--dev-only" ]]; then
        MODE="dev"
    fi
    _log "Iniciando configuración de la workstation en modo: $MODE"

    # Fases de instalación
    cleanup_previous_configs
    remove_snap
    setup_apt_repos
    install_apt_packages
    install_standalone_tools
    setup_zsh
    setup_dev_environment

    if [[ "$MODE" == "all" ]]; then
        install_flatpaks
    fi

    # Limpieza final
    sudo apt autoremove -y && sudo apt autoclean

    # Mensajes finales
    echo -e "\n\n${GREEN}✅ ¡Configuración de la Workstation completada! ✅${NC}"
    echo -e "\n${YELLOW}--- Pasos Finales MUY IMPORTANTES ---${NC}"
    echo "1. Para que todos los cambios (grupo Docker, Zsh como shell) se apliquen correctamente,"
    echo -e "   necesitas ${GREEN}CERRAR SESIÓN Y VOLVER A INICIARLA${NC}."
    echo "2. La primera vez que abras la terminal, Oh My Zsh podría hacerte alguna pregunta."
    echo "3. Una vez en la nueva sesión, puedes instalar las versiones de tus herramientas, por ejemplo:"
    echo -e "   ${GREEN}asdf install python latest${NC}"
    echo -e "   ${GREEN}asdf global python latest${NC}"
}

# --- Punto de Entrada del Script ---
main "$@"
