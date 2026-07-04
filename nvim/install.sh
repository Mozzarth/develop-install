#!/bin/bash

# =============================================================================
# nvim/install.sh
# Nombre:       Neovim
# Descripción:  Editor de texto modal hiperextensible basado en Vim
# Web:          https://neovim.io
# Gestor:       Homebrew (macOS y Linux)
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

TOOL_NAME="Neovim"

# --- Detectar OS ---
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
    elif [[ -f /etc/os-release ]]; then
        source /etc/os-release
        OS="linux"
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
    command -v nvim &>/dev/null
}

# --- Obtener versión ---
get_version() {
    nvim --version 2>/dev/null | head -1 | awk '{print $2}'
}

# --- Instalar ---
do_install() {
    brew install neovim >> "$LOG_FILE" 2>&1
}

# --- Actualizar ---
do_update() {
    brew upgrade neovim >> "$LOG_FILE" 2>&1
}

# --- Aplicar configuración ---
apply_config() {
    local config_dir="$HOME/.config/nvim"
    mkdir -p "$config_dir"
    cp "$SCRIPT_DIR/init.lua" "$config_dir/init.lua"
    print_ok "init.lua aplicado en $config_dir"
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
            print_ok "$TOOL_NAME actualizado → $(get_version)"
        else
            print_warn "$TOOL_NAME ya está en la última versión"
        fi
    else
        print_info "Instalando $TOOL_NAME..."
        if do_install; then
            print_ok "$TOOL_NAME instalado → $(get_version)"
        else
            print_error "Error al instalar $TOOL_NAME"
            exit 1
        fi
    fi

    apply_config
}

if [[ -z "${LOG_FILE:-}" ]]; then
    LOG_DIR="$HOME/.dev-install"
    LOG_FILE="$LOG_DIR/nvim-$(date '+%Y-%m-%d_%H-%M-%S').log"
    mkdir -p "$LOG_DIR"
fi

main
