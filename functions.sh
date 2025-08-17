# -----------------------------
# funciones útiles
# -----------------------------
function cddev() {
    # --- Comandos con ruta absoluta ---
    local FIND_CMD="/usr/bin/find"
    local DIRNAME_CMD="/usr/bin/dirname"

    # --- Validación ---
    if [[ -z "$1" ]]; then
        echo "❌ Error: Debes proporcionar un nombre de directorio para buscar."
        echo "   Uso: cdp <nombre_del_directorio_hijo>"
        return 1
    fi

    if [[ -z "$DEV_DIR" || ! -d "$DEV_DIR" ]]; then
        echo "❌ Error: La variable \$DEV_DIR no está definida o no es un directorio."
        return 1
    fi

    # --- Lógica Principal ---
    local found_dir
    # Busca el primer directorio que coincida y detiene la búsqueda (-quit).
    found_dir=$("$FIND_CMD" "$DEV_DIR" -name "$1" -type d -print -quit)

    # Verifica si se encontró un directorio.
    if [[ -z "$found_dir" ]]; then
        echo "🔎 No se encontró ningún directorio con el nombre '$1' en $DEV_DIR."
        return 1
    fi

    # Obtiene el directorio padre.
    local parent_dir
    parent_dir=$("$DIRNAME_CMD" "$found_dir")

    # Finalmente, cambia al directorio padre.
    echo "==> Moviendo a: $parent_dir"
    cd "$parent_dir"
}

# Lista los repositorios de git dentro del directorio de desarrollo.
function lsdev() {
    # --- Comandos con ruta absoluta para evitar problemas con $PATH ---
    local FIND_CMD="/usr/bin/find"
    local SED_CMD="/usr/bin/sed"
    
    # 1. Verificar si la variable DEV_DIR está definida.
    if [[ -z "$DEV_DIR" ]]; then
        echo "❌ Error: La variable de entorno \$DEV_DIR no está definida."
        echo "   Asegúrate de añadir 'export DEV_DIR=\"\$HOME/dev\"' a tu ~/.zshrc"
        return 1
    fi
    
    # 2. Verificar si el directorio realmente existe.
    if [[ ! -d "$DEV_DIR" ]]; then
        echo "❌ Error: El directorio especificado en \$DEV_DIR no existe: $DEV_DIR"
        return 1
    fi

    # --- Lógica Principal ---
    # Se usa -maxdepth 4 para encontrar .git en estructuras como host/org/repo
    "$FIND_CMD" "$DEV_DIR" -maxdepth 4 -type d -name .git | "$SED_CMD" 's|/.git$||' | "$SED_CMD" "s|^$DEV_DIR/||"
}

# --------------------------------------------------
# Automatización de Clonado (Versión "Bulletproof")
# --------------------------------------------------

# Esta versión utiliza rutas absolutas para funcionar incluso con un PATH dañado.
# Verifica las rutas en tu sistema con `which git` o `which mkdir` si es necesario.
function clone_repo() {
    local input=$1
    local use_ssh=${2:-false}

    # --- Variables de Comandos (rutas absolutas) ---
    local GIT_CMD="/usr/bin/git"
    local MKDIR_CMD="/usr/bin/mkdir"
    # --- Fin de Variables de Comandos ---

    if [[ -z "$input" ]]; then
        echo "Error: Debes proporcionar una URL o un formato corto (ej: user/repo)."
        return 1
    fi
    
    if [[ -z "$HOME" ]]; then
        echo "Error: La variable de entorno \$HOME no está definida."
        return 1
    fi

    # Función interna para clonar, para no pasar los comandos como argumentos.
    _clone_repo_internal() {
        local clone_url=$1
        local target_dir=$2
        
        echo "==> Objetivo: $target_dir"
        echo "==> URL: $clone_url"

        if [ -d "$target_dir" ]; then
            echo "Aviso: El directorio '$target_dir' ya existe. Omitiendo clonado."
            return 0
        fi

        # Crear directorio padre
        "$MKDIR_CMD" -p "$(dirname "$target_dir")"

        # Clonar repositorio
        "$GIT_CMD" clone "$clone_url" "$target_dir"

        # Verificar si el clonado fue exitoso
        if [ $? -eq 0 ]; then
            echo "✅ Repositorio clonado exitosamente en: $target_dir"
        else
            echo "❌ Error al clonar el repositorio."
            return 1
        fi
    }

    # Lógica de Parseo (sin dependencias externas)
    local host="github.com"
    local path
    local org
    local repo

    # Si es una URL completa (HTTPS o SSH)
    if [[ "$input" =~ ^(https|git)@?([^/:]+)[/:]([^/]+)/([^/.]+)(\.git)?/?.*$ ]]; then
        host="${BASH_REMATCH[2]}"
        org="${BASH_REMATCH[3]}"
        repo="${BASH_REMATCH[4]}"
        
        _clone_repo_internal "$input" "$HOME/dev/$host/$org/$repo"
    
    # Si es un formato corto (user/repo o host/user/repo)
    else
        path="$input"
        if [[ "$input" == *"/"*"/"* ]]; then
            host="${input%%/*/*}"
            path="${input#*/}"
        fi
        
        org="${path%%/*}"
        repo="${path#*/}"

        if [[ -z "$org" || -z "$repo" || "$org" == "$repo" ]]; then
            echo "Error: Formato corto '$input' no válido. Usa 'user/repo' o 'host/user/repo'."
            return 1
        fi
        
        local clone_url
        if [[ "$use_ssh" == "true" ]]; then
            clone_url="git@$host:$org/$repo.git"
        else
            clone_url="https://$host/$org/$repo.git"
        fi

        _clone_repo_internal "$clone_url" "$HOME/dev/$host/$org/$repo"
    fi
}

# -----------------------------
# mantener repositorios
# -----------------------------
function update_repos() {
    local dev_dir="$HOME/dev"
    
    if [[ ! -d "$dev_dir" ]]; then
        echo "El directorio $dev_dir no existe."
        return 1
    fi
    
    echo "Actualizando repositorios en $dev_dir..."
    
    find "$dev_dir" -name ".git" -type d | while read -r git_dir; do
        repo_dir=$(dirname "$git_dir")
        echo "Actualizando: $repo_dir"
        cd "$repo_dir" || continue
        
        # Solo actualizar si está en main/master y limpio
        if git diff --quiet && git diff --cached --quiet; then
            git fetch origin
            local_branch=$(git rev-parse --abbrev-ref HEAD)
            if [[ $local_branch == "main" || $local_branch == "master" ]]; then
                git pull origin "$local_branch"
            fi
        else
            echo "  ⚠️  Cambios locales detectados, omitiendo..."
        fi
    done
    
    echo "Actualización completa."
}
