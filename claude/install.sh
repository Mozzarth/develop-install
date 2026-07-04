#!/bin/bash

# =============================================================================
# claude/install.sh
# Nombre:       Claude Code
# Descripción:  CLI oficial de Anthropic para Claude
# Web:          https://claude.ai/code
# Gestor:       Homebrew (Node/npm) + npm install -g
# Config:       Tema dark-daltonized · Idioma español · Status bar personalizado
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

TOOL_NAME="Claude Code"
CLAUDE_DIR="$HOME/.claude"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"
STATUSLINE_DEST="$CLAUDE_DIR/statusline.sh"

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

# --- Asegurar Node y npm via brew ---
ensure_node() {
    if command -v node &>/dev/null; then
        print_info "Node $(node --version) encontrado"
        return 0
    fi

    print_info "Instalando Node.js via Homebrew..."
    if brew install node >> "$LOG_FILE" 2>&1; then
        print_ok "Node.js instalado ($(node --version))"
    else
        print_error "No se pudo instalar Node.js"
        exit 1
    fi
}

# --- Verificar si está instalado ---
is_installed() {
    command -v claude &>/dev/null
}

# --- Obtener versión ---
get_version() {
    claude --version 2>/dev/null | head -1
}

# --- Instalar ---
do_install() {
    npm install -g @anthropic-ai/claude-code >> "$LOG_FILE" 2>&1
}

# --- Actualizar ---
do_update() {
    npm update -g @anthropic-ai/claude-code >> "$LOG_FILE" 2>&1
}

# --- Aplicar configuración en ~/.claude/settings.json ---
apply_settings() {
    mkdir -p "$CLAUDE_DIR"

    # Preservar configuración existente si hay (ej: apiKey)
    local existing="{}"
    if [[ -f "$SETTINGS_FILE" ]]; then
        existing=$(cat "$SETTINGS_FILE")
        print_info "settings.json existente detectado — se fusionarán los valores"
    fi

    # Fusionar: los valores nuevos sobreescriben, el resto se preserva
    echo "$existing" | jq \
        --arg theme "dark-daltonized" \
        --arg lang "es" \
        --arg statusline "$STATUSLINE_DEST" \
        '. + {
            "theme": $theme,
            "preferredLanguage": $lang,
            "statusLine": {
                "type": "command",
                "command": $statusline
            }
        }' > "$SETTINGS_FILE" 2>> "$LOG_FILE"

    print_ok "settings.json configurado (tema: dark-daltonized, idioma: es)"
}

# --- Copiar statusline.sh a ~/.claude/ ---
apply_statusline() {
    cp "$SCRIPT_DIR/statusline.sh" "$STATUSLINE_DEST"
    chmod +x "$STATUSLINE_DEST"
    print_ok "statusline.sh instalado en $STATUSLINE_DEST"
}

# --- Main ---
main() {
    print_section "$TOOL_NAME"
    detect_os
    ensure_brew
    ensure_node

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

    apply_statusline
    apply_settings
}

if [[ -z "${LOG_FILE:-}" ]]; then
    LOG_DIR="$HOME/.dev-install"
    LOG_FILE="$LOG_DIR/claude-$(date '+%Y-%m-%d_%H-%M-%S').log"
    mkdir -p "$LOG_DIR"
fi

main
