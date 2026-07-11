#!/bin/bash

# =============================================================================
# ghostty/install.sh
# Nombre:       Ghostty
# Descripción:  Terminal GPU-accelerated escrito en Zig
# Web:          https://ghostty.org
# Gestor:       Homebrew (macOS) · Flatpak via Homebrew (Linux)
# Nota:         Windows no está soportado oficialmente
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

TOOL_NAME="Ghostty"

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

# --- Detectar si es un servidor sin entorno gráfico ---
is_headless() {
    [[ -z "${DISPLAY:-}" ]] && [[ -z "${WAYLAND_DISPLAY:-}" ]]
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
    command -v ghostty &>/dev/null || [[ -d "/Applications/Ghostty.app" ]]
}

# --- Obtener versión ---
get_version() {
    ghostty --version 2>/dev/null | head -1 || echo "instalado"
}

# --- Instalar ---
do_install() {
    if [[ "$OS" == "macos" ]]; then
        brew install --cask ghostty >> "$LOG_FILE" 2>&1
    else
        # En Linux los casks no están disponibles en Homebrew.
        # Ghostty se distribuye via Flatpak en Linux.
        if ! command -v flatpak &>/dev/null; then
            print_info "Instalando Flatpak via Homebrew..."
            brew install flatpak >> "$LOG_FILE" 2>&1
        fi
        flatpak remote-add --if-not-exists flathub \
            https://dl.flathub.org/repo/flathub.flatpakrepo >> "$LOG_FILE" 2>&1
        flatpak install -y flathub com.mitchellh.ghostty >> "$LOG_FILE" 2>&1
    fi
}

# --- Actualizar ---
do_update() {
    if [[ "$OS" == "macos" ]]; then
        brew upgrade --cask ghostty >> "$LOG_FILE" 2>&1
    else
        flatpak update -y com.mitchellh.ghostty >> "$LOG_FILE" 2>&1
    fi
}

# --- Main ---
main() {
    print_section "$TOOL_NAME"
    detect_os

    if [[ "$OS" == "linux" ]] && is_headless; then
        print_skip "$TOOL_NAME omitido — servidor sin entorno gráfico (headless), no aplica"
        exit 2
    fi

    ensure_brew

    if is_installed; then
        local version
        version=$(get_version)
        print_info "$TOOL_NAME ($version) ya instalado — actualizando..."
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
    LOG_FILE="$LOG_DIR/ghostty-$(date '+%Y-%m-%d_%H-%M-%S').log"
    mkdir -p "$LOG_DIR"
fi

main
