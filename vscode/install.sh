#!/bin/bash

# =============================================================================
# vscode/install.sh
# Nombre:       Visual Studio Code
# Descripción:  Editor de código fuente desarrollado por Microsoft
# Web:          https://code.visualstudio.com
# Gestor:       Homebrew (macOS) · Homebrew + cask workaround (Linux)
# Nota Linux:   Los casks son exclusivos de macOS. En Linux se instala
#               el paquete oficial .deb/.rpm via repositorio de Microsoft.
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

TOOL_NAME="Visual Studio Code"

# --- Detectar OS ---
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
    elif [[ -f /etc/os-release ]]; then
        source /etc/os-release
        OS="linux"
        DISTRO_ID="$ID"
    else
        print_error "Sistema operativo no reconocido"
        exit 1
    fi
    print_info "Sistema detectado: $OS"
}

# --- Instalar Homebrew si no existe ---
ensure_brew() {
    if command -v brew &>/dev/null; then
        print_info "Homebrew $(brew --version | head -1) encontrado"
        return 0
    fi

    print_info "Instalando Homebrew..."
    if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" >> "$LOG_FILE" 2>&1; then
        if [[ "$OS" == "linux" ]]; then
            eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        fi
        print_ok "Homebrew instalado"
    else
        print_error "No se pudo instalar Homebrew"
        exit 1
    fi
}

# --- Verificar si está instalado ---
is_installed() {
    command -v code &>/dev/null
}

# --- Obtener versión ---
get_version() {
    code --version 2>/dev/null | head -1
}

# --- Instalar ---
do_install() {
    if [[ "$OS" == "macos" ]]; then
        brew install --cask visual-studio-code >> "$LOG_FILE" 2>&1
    else
        # En Linux los casks no están disponibles en Homebrew.
        # Instalamos via repositorio oficial de Microsoft.
        case "${DISTRO_ID:-}" in
            ubuntu|debian|linuxmint|pop)
                curl -fsSL https://packages.microsoft.com/keys/microsoft.asc \
                    | gpg --dearmor \
                    | sudo tee /usr/share/keyrings/microsoft.gpg > /dev/null 2>> "$LOG_FILE"
                echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] \
                    https://packages.microsoft.com/repos/code stable main" \
                    | sudo tee /etc/apt/sources.list.d/vscode.list >> "$LOG_FILE" 2>&1
                sudo apt-get update >> "$LOG_FILE" 2>&1
                sudo apt-get install -y code >> "$LOG_FILE" 2>&1
                ;;
            fedora|rhel|centos|rocky)
                sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc >> "$LOG_FILE" 2>&1
                sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo' >> "$LOG_FILE" 2>&1
                sudo dnf install -y code >> "$LOG_FILE" 2>&1
                ;;
            arch|manjaro)
                sudo pacman -S --noconfirm code >> "$LOG_FILE" 2>&1
                ;;
            *)
                print_error "Distro no soportada para VSCode: ${DISTRO_ID:-desconocida}"
                return 1
                ;;
        esac
    fi
}

# --- Actualizar ---
do_update() {
    if [[ "$OS" == "macos" ]]; then
        brew upgrade --cask visual-studio-code >> "$LOG_FILE" 2>&1
    else
        case "${DISTRO_ID:-}" in
            ubuntu|debian|linuxmint|pop)
                sudo apt-get install --only-upgrade -y code >> "$LOG_FILE" 2>&1 ;;
            fedora|rhel|centos|rocky)
                sudo dnf upgrade -y code >> "$LOG_FILE" 2>&1 ;;
            arch|manjaro)
                sudo pacman -Syu --noconfirm code >> "$LOG_FILE" 2>&1 ;;
        esac
    fi
}

# --- Main ---
main() {
    print_section "$TOOL_NAME"
    detect_os
    ensure_brew

    if is_installed; then
        local version
        version=$(get_version)
        print_info "$TOOL_NAME $version ya instalado — actualizando..."
        if do_update; then
            print_ok "$TOOL_NAME actualizado"
        else
            print_warn "$TOOL_NAME ya está en la última versión"
        fi
    else
        print_info "Instalando $TOOL_NAME..."
        if do_install; then
            print_ok "$TOOL_NAME instalado"
        else
            print_error "Error al instalar $TOOL_NAME"
            exit 1
        fi
    fi
}

if [[ -z "${LOG_FILE:-}" ]]; then
    LOG_DIR="$HOME/.dev-install"
    LOG_FILE="$LOG_DIR/vscode-$(date '+%Y-%m-%d_%H-%M-%S').log"
    mkdir -p "$LOG_DIR"
fi

main
