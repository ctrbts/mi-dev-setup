#!/bin/bash

# Este script automatiza la configuración base de Ubuntu 24.04 LTS
# Incluye actualizaciones del sistema, instalación de herramientas esenciales,
# gestores de paquetes y configuración de Zsh, adaptado para servidor o escritorio.

# Asegurar ejecución como root
if [[ "$EUID" -ne 0 ]]; then
  echo "Por favor, ejecuta este script como root."
  exit 1
fi

echo # Salto de línea
echo "=== CONFIGURACIÓN BASE DE UBUNTU 24.04 LTS ==="
echo # Salto de línea

# --- Selección del Tipo de Instalación ---
INSTALL_TYPE=""
while [[ "$INSTALL_TYPE" != "s" && "$INSTALL_TYPE" != "l" ]]; do
  read -p "¿Esta configuración es para un entorno de servidor o local? (s/l): " install_type_choice
  INSTALL_TYPE=$(echo "$install_type_choice" | tr '[:upper:]' '[:lower:]') # Convertir a minúsculas
  if [[ "$INSTALL_TYPE" != "s" && "$INSTALL_TYPE" != "l" ]]; then
    echo "Opción no válida. Por favor, introduce 's' o 'l'."
  fi
done
echo "Configurando para un entorno de: $INSTALL_TYPE"
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

# --- Actualización del Sistema ---
if confirm_action "actualizar los paquetes del sistema"; then
  echo "Actualizando paquetes del sistema..."
  apt update && apt full-upgrade -y && apt autoremove -y && apt autoclean -y
  echo "Actualización de paquetes completada."
  echo # Salto de línea
fi

# --- Instalación de Herramientas y Utilidades Esenciales ---
# Herramientas comunes para ambos entornos
COMMON_TOOLS="curl git software-properties-common"
# Herramientas adicionales que podrían ser más útiles en servidor o para usuarios avanzados
SERVER_ORIENTED_TOOLS="mc htop nmap ssh" # nmap puede ser útil en ambos, pero más común en servidor

TOOLS_TO_INSTALL="$COMMON_TOOLS"

if [[ "$INSTALL_TYPE" == "s" ]]; then
  echo "Herramientas recomendadas para servidor: $COMMON_TOOLS $SERVER_ORIENTED_TOOLS"
  if confirm_action "instalar herramientas básicas para servidor ($COMMON_TOOLS $SERVER_ORIENTED_TOOLS)"; then
    apt install $COMMON_TOOLS $SERVER_ORIENTED_TOOLS -y
    echo "Instalación de herramientas básicas para servidor completada."
  fi
elif [[ "$INSTALL_TYPE" == "l" ]]; then
  echo "Herramientas recomendadas para escritorio: $COMMON_TOOLS"
  if confirm_action "instalar herramientas básicas para escritorio ($COMMON_TOOLS)"; then
    apt install $COMMON_TOOLS -y
    echo "Instalación de herramientas básicas para escritorio completada."
  fi
  if confirm_action "instalar herramientas adicionales como nmap (útil para diagnóstico de red)"; then
    apt install $SERVER_ORIENTED_TOOLS -y
    echo "Instalación de nmap completada."
  fi
fi
echo # Salto de línea

# --- Gestores de Paquetes y Soporte Adicional (Solo para Escritorio) ---
if [[ "$INSTALL_TYPE" == "l" ]]; then
  echo "--- Configuración Específica para Escritorio ---"
  if confirm_action "instalar herramientas de personalización y gestores de paquetes gráficos (gnome-tweaks, dconf-editor, synaptic, apt-xapian-index, tasksel)"; then
    echo "Instalando herramientas de personalización y gestores de paquetes gráficos..."
    apt install gnome-tweaks dconf-editor synaptic apt-xapian-index tasksel -y
    echo "Instalación completada."
    echo # Salto de línea
  fi

  if confirm_action "instalar soporte para Flatpak y añadir el repositorio Flathub"; then
    echo "Instalando Flatpak y el plugin para Gnome Software..."
    apt install flatpak gnome-software-plugin-flatpak -y
    echo "Añadiendo el repositorio Flathub..."
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    echo "Soporte para Flatpak y Flathub configurado."
    echo # Salto de línea
  fi
else
  echo "Omitiendo instalación de herramientas gráficas y Flatpak (seleccionado entorno de servidor)."
  echo # Salto de línea
fi

# --- Configuración de Zsh (Común para ambos) ---
if confirm_action "instalar y configurar Zsh y Oh My Zsh"; then
  echo "Instalando Zsh..."
  apt install zsh -y
  echo "Zsh instalado."
  echo # Salto de línea

  echo "Para establecer Zsh como tu shell por defecto para el usuario actual, ejecuta después del script:"
  echo "chsh -s \$(which zsh) \$USER"
  echo "O para el usuario que ejecutó sudo (si es diferente): chsh -s \$(which zsh) $SUDO_USER"
  echo "Necesitarás cerrar sesión y volver a iniciarla para que el cambio surta efecto."
  echo # Salto de línea

  if confirm_action "instalar Oh My Zsh"; then
    TARGET_USER=""
    HOME_DIR=""

    if [ ! -z "$SUDO_USER" ] && [ "$SUDO_USER" != "root" ]; then
      TARGET_USER=$SUDO_USER
      HOME_DIR=$(getent passwd $SUDO_USER | cut -d: -f6)
    else
      # Si SUDO_USER no está definido o es root, preguntar para qué usuario instalar
      read -p "Oh My Zsh se instalará en el HOME del usuario. ¿Para qué usuario deseas instalarlo? (por defecto: $USER): " target_user_input
      TARGET_USER=${target_user_input:-$USER}
      HOME_DIR=$(getent passwd $TARGET_USER | cut -d: -f6)
      if [ -z "$HOME_DIR" ]; then
        echo "No se pudo determinar el directorio HOME para el usuario $TARGET_USER. Omitiendo instalación de Oh My Zsh."
        # Salir de la sección de Oh My Zsh si no hay HOME_DIR
        # Esto se maneja mejor con un 'continue' si estuviera en un bucle, o simplemente no procediendo.
        # Para este if, simplemente no haremos nada más en esta rama.
      fi
    fi

    if [ -n "$HOME_DIR" ] && [ -d "$HOME_DIR" ]; then
      echo "Oh My Zsh se instalará para el usuario: $TARGET_USER en el directorio $HOME_DIR"

      if [ -d "$HOME_DIR/.oh-my-zsh" ]; then
        echo "Oh My Zsh ya está instalado para $TARGET_USER."
      else
        echo "Instalando Oh My Zsh para $TARGET_USER..."
        # Ejecutar como el usuario objetivo para que la instalación se haga en su directorio home
        sudo -u $TARGET_USER sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh) --unattended"
        # El --unattended es para evitar el prompt de chsh que falla si el script no es interactivo para ese usuario
        echo "Oh My Zsh instalado."

        # Clonar plugins adicionales
        ZSH_CUSTOM_DIR="$HOME_DIR/.oh-my-zsh/custom"
        echo "Instalando plugins adicionales para Oh My Zsh en $ZSH_CUSTOM_DIR/plugins..."
        sudo -u $TARGET_USER git clone https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_CUSTOM_DIR/plugins/zsh-autosuggestions"
        sudo -u $TARGET_USER git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM_DIR/plugins/zsh-syntax-highlighting"
        echo "Plugins adicionales instalados."

        # Configurar plugins en .zshrc
        echo "Por favor, edita tu archivo $HOME_DIR/.zshrc y actualiza la línea de plugins para incluir:"
        echo "plugins=(git common-aliases extract colored-man-pages zsh-autosuggestions zsh-syntax-highlighting)"

        if confirm_action "aplicar la configuración de plugins recomendada automáticamente a $HOME_DIR/.zshrc"; then
          if [ -f "$HOME_DIR/.zshrc" ]; then
            sudo -u $TARGET_USER cp "$HOME_DIR/.zshrc" "$HOME_DIR/.zshrc.bak_$(date +%F-%T)"
            # Reemplazar la línea de plugins. Esto es más robusto si la línea original varía.
            sudo -u $TARGET_USER sed -i -E "s/plugins=\((.*)\)/plugins=(git common-aliases extract colored-man-pages zsh-autosuggestions zsh-syntax-highlighting)/g" "$HOME_DIR/.zshrc"
            # Verificar si el reemplazo tuvo éxito o si la línea no existía en el formato esperado
            if ! sudo -u $TARGET_USER grep -q "plugins=(git common-aliases extract colored-man-pages zsh-autosuggestions zsh-syntax-highlighting)" "$HOME_DIR/.zshrc"; then
              echo "No se pudo actualizar la línea de plugins automáticamente (quizás el formato era inesperado)."
              echo "Añadiendo la línea de plugins al final del archivo $HOME_DIR/.zshrc."
              echo -e "\nplugins=(git common-aliases extract colored-man-pages zsh-autosuggestions zsh-syntax-highlighting)" | sudo -u $TARGET_USER tee -a "$HOME_DIR/.zshrc" >/dev/null
            fi
            echo "Archivo $HOME_DIR/.zshrc actualizado con los plugins."
          else
            echo "No se encontró el archivo $HOME_DIR/.zshrc. Oh My Zsh debería haberlo creado."
            echo "Creando $HOME_DIR/.zshrc con la configuración de plugins..."
            echo "ZSH_THEME=\"robbyrussell\"" | sudo -u $TARGET_USER tee "$HOME_DIR/.zshrc" >/dev/null
            echo "plugins=(git common-aliases extract colored-man-pages zsh-autosuggestions zsh-syntax-highlighting)" | sudo -u $TARGET_USER tee -a "$HOME_DIR/.zshrc" >/dev/null
            echo "export ZSH=\"$HOME_DIR/.oh-my-zsh\"" | sudo -u $TARGET_USER tee -a "$HOME_DIR/.zshrc" >/dev/null
            echo "source \$ZSH/oh-my-zsh.sh" | sudo -u $TARGET_USER tee -a "$HOME_DIR/.zshrc" >/dev/null
            echo "Archivo $HOME_DIR/.zshrc creado con la configuración de plugins."
          fi
        fi
      fi
    else
      echo "No se pudo determinar un directorio HOME válido para el usuario $TARGET_USER. Omitiendo instalación de Oh My Zsh."
    fi
    echo # Salto de línea
  fi
fi

echo "=== CONFIGURACIÓN BASE PARA $INSTALL_TYPE COMPLETADA ==="
echo "Recuerda revisar los mensajes y realizar configuraciones manuales si es necesario (ej. Zsh)."
echo "Puede ser necesario reiniciar la sesión o el sistema para que todos los cambios surtan efecto."
echo # Salto de línea
