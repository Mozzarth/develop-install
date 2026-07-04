#!/bin/bash

# =============================================================================
# install.sh — Orquestador principal
# Ejecuta cada script de instalación en orden
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

LOG_DIR="$HOME/.dev-install"
LOG_FILE="$LOG_DIR/install-$(date '+%Y-%m-%d_%H-%M-%S').log"
mkdir -p "$LOG_DIR"
export LOG_FILE

source "$SCRIPT_DIR/lib/common.sh"

TOOLS=(
    "Git:git"
    "Visual Studio Code:vscode"
    "Ghostty:ghostty"
    "Oh My Zsh:ohmyzsh"
    "Claude Code:claude"
    "Neovim:nvim"
)

RESULTS_OK=()
RESULTS_ERROR=()

run_tool() {
    local name="$1"
    local folder="$2"
    local script="$SCRIPT_DIR/$folder/install.sh"

    if [[ ! -f "$script" ]]; then
        print_error "Script no encontrado: $script"
        RESULTS_ERROR+=("$name")
        return
    fi

    if LOG_FILE="$LOG_FILE" bash "$script"; then
        RESULTS_OK+=("$name")
    else
        RESULTS_ERROR+=("$name")
    fi
}

main() {
    echo ""
    echo -e "${BOLD}╔══════════════════════════════════════════╗${RESET}"
    echo -e "${BOLD}║       Dev Environment Installer          ║${RESET}"
    echo -e "${BOLD}╚══════════════════════════════════════════╝${RESET}"
    echo ""
    echo -e "  Log: ${BOLD}$LOG_FILE${RESET}"
    echo ""

    echo -e "${BOLD}  Herramientas:${RESET}"
    for entry in "${TOOLS[@]}"; do
        local name="${entry%%:*}"
        echo -e "  ${BLUE}•${RESET} $name"
    done
    echo ""
    echo -e "  ${YELLOW}Si ya están instaladas, se actualizarán.${RESET}"
    echo ""

    read -rp "  ¿Continuar? [S/n] " confirm
    confirm="${confirm:-S}"
    if [[ ! "$confirm" =~ ^[SsYy]$ ]]; then
        print_warn "Instalación cancelada"
        exit 0
    fi

    log "INFO" "Instalación iniciada"

    for entry in "${TOOLS[@]}"; do
        local name="${entry%%:*}"
        local folder="${entry##*:}"
        run_tool "$name" "$folder"
    done

    echo ""
    echo -e "${BOLD}╔══════════════════════════════════════════╗${RESET}"
    echo -e "${BOLD}║              Resumen Final               ║${RESET}"
    echo -e "${BOLD}╚══════════════════════════════════════════╝${RESET}"
    echo ""

    if [[ ${#RESULTS_OK[@]} -gt 0 ]]; then
        echo -e "${GREEN}  ✅ Completados:${RESET}"
        for item in "${RESULTS_OK[@]}"; do
            echo -e "     • $item"
        done
        echo ""
    fi

    if [[ ${#RESULTS_ERROR[@]} -gt 0 ]]; then
        echo -e "${RED}  ❌ Con errores:${RESET}"
        for item in "${RESULTS_ERROR[@]}"; do
            echo -e "     • $item"
        done
        echo ""
        echo -e "  Detalles en: ${BOLD}$LOG_FILE${RESET}"
        echo ""
        log "ERROR" "Finalizado con ${#RESULTS_ERROR[@]} error(es)"
        exit 1
    fi

    echo -e "  Log guardado en: ${BOLD}$LOG_FILE${RESET}"
    echo ""
    log "INFO" "Instalación completada exitosamente"
}

main "$@"
