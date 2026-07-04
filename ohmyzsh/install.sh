#!/bin/bash

# =============================================================================
# ohmyzsh/install.sh
# Nombre:       Oh My Zsh
# Descripción:  Framework para gestionar la configuración de Zsh con plugins y temas
# Web:          https://ohmyz.sh
# Gestor:       Homebrew (zsh) + curl installer oficial de Oh My Zsh
# Plugins:      zsh-autosuggestions · zsh-syntax-highlighting
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

TOOL_NAME="Oh My Zsh"
OMZ_DIR="$HOME/.oh-my-zsh"
OMZ_INSTALL_URL="https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh"

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
    [[ -d "$OMZ_DIR" ]]
}

# --- Obtener versión ---
get_version() {
    if [[ -f "$OMZ_DIR/oh-my-zsh.sh" ]]; then
        cd "$OMZ_DIR" && git describe --tags 2>/dev/null || echo "instalado"
    fi
}

# --- Instalar zsh via brew ---
install_zsh() {
    if ! command -v zsh &>/dev/null; then
        print_info "Instalando Zsh..."
        brew install zsh >> "$LOG_FILE" 2>&1 && print_ok "Zsh instalado" || {
            print_error "Error al instalar Zsh"
            exit 1
        }
    else
        print_info "Zsh $(zsh --version | awk '{print $2}') ya instalado"
    fi
}

# --- Instalar plugins ---
install_plugins() {
    local plugins_dir="${ZSH_CUSTOM:-$OMZ_DIR/custom}/plugins"

    print_info "Instalando plugin zsh-autosuggestions..."
    if [[ ! -d "$plugins_dir/zsh-autosuggestions" ]]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions \
            "$plugins_dir/zsh-autosuggestions" >> "$LOG_FILE" 2>&1 \
            && print_ok "zsh-autosuggestions instalado" \
            || print_error "Error al instalar zsh-autosuggestions"
    else
        git -C "$plugins_dir/zsh-autosuggestions" pull >> "$LOG_FILE" 2>&1 \
            && print_ok "zsh-autosuggestions actualizado" \
            || print_warn "No se pudo actualizar zsh-autosuggestions"
    fi

    print_info "Instalando plugin zsh-syntax-highlighting..."
    if [[ ! -d "$plugins_dir/zsh-syntax-highlighting" ]]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting \
            "$plugins_dir/zsh-syntax-highlighting" >> "$LOG_FILE" 2>&1 \
            && print_ok "zsh-syntax-highlighting instalado" \
            || print_error "Error al instalar zsh-syntax-highlighting"
    else
        git -C "$plugins_dir/zsh-syntax-highlighting" pull >> "$LOG_FILE" 2>&1 \
            && print_ok "zsh-syntax-highlighting actualizado" \
            || print_warn "No se pudo actualizar zsh-syntax-highlighting"
    fi
}

# --- Copiar .zshrc ---
apply_zshrc() {
    local zshrc_src="$SCRIPT_DIR/.zshrc"
    if [[ -f "$zshrc_src" ]]; then
        cp "$zshrc_src" "$HOME/.zshrc" >> "$LOG_FILE" 2>&1
        print_ok ".zshrc aplicado"
    else
        print_warn ".zshrc no encontrado en $zshrc_src — se omite"
    fi
}

# --- Instalar ---
do_install() {
    install_zsh

    print_info "Instalando Oh My Zsh..."
    sh -c "$(curl -fsSL $OMZ_INSTALL_URL)" "" --unattended >> "$LOG_FILE" 2>&1

    install_plugins
    apply_zshrc
}

# --- Actualizar ---
do_update() {
    print_info "Actualizando Oh My Zsh..."
    zsh -c "source $OMZ_DIR/oh-my-zsh.sh && omz update --unattended" >> "$LOG_FILE" 2>&1

    install_plugins
    apply_zshrc
}

# --- Main ---
main() {
    print_section "$TOOL_NAME"
    detect_os
    ensure_brew

    if is_installed; then
        local version
        version=$(get_version)
        print_info "$TOOL_NAME ($version) ya instalado — actualizando..."
        if do_update; then
            print_ok "$TOOL_NAME actualizado"
        else
            print_error "Error al actualizar $TOOL_NAME"
            exit 1
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
    LOG_FILE="$LOG_DIR/ohmyzsh-$(date '+%Y-%m-%d_%H-%M-%S').log"
    mkdir -p "$LOG_DIR"
fi

main
