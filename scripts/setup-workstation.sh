#!/bin/bash
set -e

# Detectar Sistema Operativo
OS="unknown"
DISTRO="unknown"

if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
elif [[ -f /etc/os-release ]]; then
    OS="linux"
    . /etc/os-release
    DISTRO=$ID
    DISTRO_LIKE=${ID_LIKE:-""}
fi

echo "========================================================="
echo "   INSTALADOR DE ENTORNO DE DESARROLLO (WORKSTATION)"
echo "   Sistema detectado: $OS ($DISTRO)"
echo "========================================================="
echo ""

install_zen_browser() {
    echo "==> [1] Instalando Zen Browser..."
    if [[ "$OS" == "macos" ]]; then
        brew install --cask zen-browser
    elif [[ "$OS" == "linux" ]]; then
        if command -v flatpak &>/dev/null; then
            flatpak install -y flathub app.zen_browser.zen
        else
            curl -Lo /tmp/zen.tar.bz2 "https://github.com/zen-browser/desktop/releases/latest/download/zen.linux-x86_64.tar.bz2"
            sudo tar -xjf /tmp/zen.tar.bz2 -C /opt/
            sudo ln -sf /opt/zen/zen /usr/local/bin/zen
            rm -f /tmp/zen.tar.bz2
        fi
    fi
}

install_container_engine() {
    if [[ "$OS" == "macos" ]]; then
        echo "==> [2] Instalando OrbStack en macOS..."
        brew install --cask orbstack
    elif [[ "$OS" == "linux" ]]; then
        echo "==> [2] Instalando Docker Desktop / Engine en Linux..."
        if [[ "$DISTRO" =~ ^(almalinux|rocky|rhel|centos)$ ]] || [[ "$DISTRO_LIKE" =~ rhel ]]; then
            sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
            sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
            sudo systemctl enable --now docker
            sudo usermod -aG docker $USER
        elif [[ "$DISTRO" =~ ^(debian|ubuntu)$ ]] || [[ "$DISTRO_LIKE" =~ (debian|ubuntu) ]]; then
            sudo apt update
            sudo apt install -y ca-certificates curl gnupg
            sudo install -m 0755 -d /etc/apt/keyrings
            curl -fsSL https://download.docker.com/linux/$DISTRO/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg --yes
            sudo chmod a+r /etc/apt/keyrings/docker.gpg
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$DISTRO $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
            sudo apt update
            sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
            sudo systemctl enable --now docker
            sudo usermod -aG docker $USER
        fi
    fi
}

install_vscode() {
    echo "==> [3] Instalando Visual Studio Code y configurando comando 'code'..."
    if [[ "$OS" == "macos" ]]; then
        brew install --cask visual-studio-code
        # Enlace simbólico para asegurar 'code .' en el PATH sin pasos manuales
        sudo ln -sf "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" /usr/local/bin/code
    elif [[ "$OS" == "linux" ]]; then
        if [[ "$DISTRO" =~ ^(almalinux|rocky|rhel|centos)$ ]] || [[ "$DISTRO_LIKE" =~ rhel ]]; then
            sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
            echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null
            sudo dnf install -y code
        elif [[ "$DISTRO" =~ ^(debian|ubuntu)$ ]] || [[ "$DISTRO_LIKE" =~ (debian|ubuntu) ]]; then
            sudo apt install -y wget gpg apt-transport-https
            wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
            sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
            echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
            rm -f packages.microsoft.gpg
            sudo apt update
            sudo apt install -y code
        fi
    fi
}

install_tableplus() {
    echo "==> [4] Instalando TablePlus..."
    if [[ "$OS" == "macos" ]]; then
        brew install --cask tableplus
    elif [[ "$OS" == "linux" ]]; then
        if [[ "$DISTRO" =~ ^(debian|ubuntu)$ ]] || [[ "$DISTRO_LIKE" =~ (debian|ubuntu) ]]; then
            wget -qO - https://deb.tableplus.com/apt.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/tableplus.gpg > /dev/null
            sudo add-apt-repository "deb [arch=amd64] https://deb.tableplus.com/debian/tableplus tableplus main" -y
            sudo apt update
            sudo apt install -y tableplus
        fi
    fi
}

install_bitwarden() {
    echo "==> [5] Instalando Bitwarden..."
    if [[ "$OS" == "macos" ]]; then
        brew install --cask bitwarden
    elif [[ "$OS" == "linux" ]]; then
        if command -v flatpak &>/dev/null; then
            flatpak install -y flathub com.bitwarden.desktop
        elif [[ "$DISTRO" =~ ^(debian|ubuntu)$ ]]; then
            curl -Lo /tmp/bitwarden.deb "https://vault.bitwarden.com/download/?app=desktop&platform=linux&variant=deb"
            sudo apt install -y /tmp/bitwarden.deb
            rm -f /tmp/bitwarden.deb
        elif [[ "$DISTRO" =~ ^(almalinux|rocky|rhel|centos)$ ]]; then
            curl -Lo /tmp/bitwarden.rpm "https://vault.bitwarden.com/download/?app=desktop&platform=linux&variant=rpm"
            sudo dnf install -y /tmp/bitwarden.rpm
            rm -f /tmp/bitwarden.rpm
        fi
    fi
}

install_localsend() {
    echo "==> [6] Instalando LocalSend..."
    if [[ "$OS" == "macos" ]]; then
        brew install --cask localsend
    elif [[ "$OS" == "linux" ]]; then
        if command -v flatpak &>/dev/null; then
            flatpak install -y flathub org.localsend.localsend_app
        elif [[ "$DISTRO" =~ ^(debian|ubuntu)$ ]]; then
            LATEST_URL=$(curl -s https://api.github.com/repos/localsend/localsend/releases/latest | grep "browser_download_url.*linux-x86-64.deb" | cut -d '"' -f 4)
            curl -Lo /tmp/localsend.deb "$LATEST_URL"
            sudo apt install -y /tmp/localsend.deb
            rm -f /tmp/localsend.deb
        fi
    fi
}

# --- Menú interactivo con selector múltiple ---
echo "Selecciona qué aplicaciones instalar (separadas por espacio, ej: 1 3 5):"
echo "1) Zen Browser"
echo "2) OrbStack (macOS) / Docker (Linux)"
echo "3) Visual Studio Code (con 'code .' habilitado)"
echo "4) TablePlus"
echo "5) Bitwarden"
echo "6) LocalSend"
echo "7) Instalar TODAS"
echo "0) Salir"
echo ""
read -p "Opción(es): " -a OPCIONES

for OPCION in "${OPCIONES[@]}"; do
    case $OPCION in
        1) install_zen_browser ;;
        2) install_container_engine ;;
        3) install_vscode ;;
        4) install_tableplus ;;
        5) install_bitwarden ;;
        6) install_localsend ;;
        7)
            install_zen_browser
            install_container_engine
            install_vscode
            install_tableplus
            install_bitwarden
            install_localsend
            ;;
        0) echo "Cancelado."; exit 0 ;;
        *) echo "Opción no válida: $OPCION" ;;
    esac
done

echo ""
echo "Instalación de aplicaciones de escritorio finalizada con éxito."
