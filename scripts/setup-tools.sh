cat << 'EOF' > install_tools_universal.sh
#!/bin/bash
set -e

echo "==> Detectando distribución del sistema..."

KERNEL=$(uname -s)

if [ "$KERNEL" = "Darwin" ]; then
    OS_ID="macos"
    OS_ID_LIKE=""
elif [ -f /etc/os-release ]; then
    . /etc/os-release
    OS_ID=$ID
    OS_ID_LIKE=${ID_LIKE:-""}
else
    echo "No se pudo identificar la distribución."
    exit 1
fi

if [ "$KERNEL" = "Darwin" ]; then
    NAME="macOS"
fi

echo "Sistema detectado: $NAME ($OS_ID)"

# -------------------------------------------------------------
# 1. Instalación según la familia de la distro
# -------------------------------------------------------------
if [[ "$OS_ID" =~ ^(almalinux|rocky|rhel|centos|fedora)$ ]] || [[ "$OS_ID_LIKE" =~ (rhel|fedora) ]]; then
    echo "==> [Familia RHEL] Instalando dependencias con DNF..."
    sudo dnf install -y epel-release curl tar
    sudo dnf install -y bat ripgrep

    # Intentar instalar eza vía DNF; si no está en EPEL, descargar binario oficial
    if ! sudo dnf install -y eza 2>/dev/null; then
        echo "Descargando binario de eza..."
        curl -Lo /tmp/eza.tar.gz "https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-gnu.tar.gz"
        tar -xzf /tmp/eza.tar.gz -C /tmp/
        sudo mv /tmp/eza /usr/local/bin/eza
        sudo chmod +x /usr/local/bin/eza
        rm -f /tmp/eza.tar.gz
    fi

elif [[ "$OS_ID" == "macos" ]]; then
    echo "==> [macOS] Instalando dependencias con Homebrew..."

    if ! command -v brew &>/dev/null; then
        echo "Homebrew no está instalado. Instalándolo..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        # Añadir brew al PATH para esta sesión
        if [ -x /opt/homebrew/bin/brew ]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [ -x /usr/local/bin/brew ]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    fi

    brew update
    brew install bat ripgrep eza

elif [[ "$OS_ID" =~ ^(debian|ubuntu)$ ]] || [[ "$OS_ID_LIKE" =~ (debian|ubuntu) ]]; then
    echo "==> [Familia Debian] Instalando dependencias con APT..."
    sudo apt update
    sudo apt install -y bat ripgrep gpg curl tar

    # En Debian/Ubuntu el binario de bat se llama batcat por colisión de nombres
    if command -v batcat &>/dev/null && ! command -v bat &>/dev/null; then
        sudo ln -sf /usr/bin/batcat /usr/local/bin/bat
    fi

    # Repositorio oficial de eza para Debian/Ubuntu
    echo "Configurando repositorio oficial de eza..."
    sudo mkdir -p /etc/apt/keyrings
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor --yes -o /etc/apt/keyrings/gierens.gpg
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list > /dev/null
    sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
    sudo apt update
    sudo apt install -y eza

else
    echo "Distribución no soportada automáticamente por este instalador."
    exit 1
fi

# -------------------------------------------------------------
# 2. Configurar Aliases en ~/.bashrc (y ~/.zshrc si existe)
# -------------------------------------------------------------
echo "==> Configurando aliases de terminal..."

RC_FILES=("$HOME/.bashrc")
[ -f "$HOME/.zshrc" ] && RC_FILES+=("$HOME/.zshrc")

for RC in "${RC_FILES[@]}"; do
    if ! grep -q "# --- Reemplazo de cat con bat ---" "$RC" 2>/dev/null; then
cat << 'CONFIG' >> "$RC"

# --- Reemplazo de cat con bat (con colores, sin números ni paginador) ---
alias cat="bat --plain --paging=never"

# --- Reemplazo de ls con eza (iconos, colores y carpetas primero) ---
alias ls="eza --icons --group-directories-first"
alias ll="eza -la --icons --octal-permissions --group-directories-first --time-style=relative"
alias la="eza -a --icons --group-directories-first"

# --- Vista de árbol (fijo a 2 niveles e ignorando carpetas pesadas) ---
alias tree='eza --tree --level=2 --icons --group-directories-first --ignore-glob="node_modules|.git|.next|dist"'
CONFIG
        echo "Aliases agregados en: $RC"
    else
        echo "Los aliases ya existían en: $RC"
    fi
done

echo ""
echo "Instalación completada con éxito. Ejecuta: source ~/.bashrc"
EOF

chmod +x install_tools_universal.sh
./install_tools_universal.sh
rm -f install_tools_universal.sh
source ~/.bashrc
