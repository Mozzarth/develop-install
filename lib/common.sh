#!/bin/bash

# =============================================================================
# lib/common.sh — Helpers de output y log
# =============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
RESET='\033[0m'

# LOG_FILE debe estar definido antes de hacer source de este archivo

log() {
    local level="$1" msg="$2"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $msg" >> "$LOG_FILE"
}

print_info()    { echo -e "${BLUE}  ℹ️  $1${RESET}";    log "INFO"    "$1"; }
print_ok()      { echo -e "${GREEN}  ✅ $1${RESET}";    log "OK"      "$1"; }
print_warn()    { echo -e "${YELLOW}  ⚠️  $1${RESET}";  log "WARN"    "$1"; }
print_skip()    { echo -e "${YELLOW}  ⏭️  $1${RESET}";  log "SKIP"    "$1"; }
print_error()   { echo -e "${RED}  ❌ $1${RESET}" >&2; log "ERROR"   "$1"; }
print_section() { echo -e "\n${BOLD}${BLUE}▶ $1${RESET}\n";          log "SECTION" "=== $1 ==="; }
