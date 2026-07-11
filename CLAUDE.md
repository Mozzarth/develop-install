# Dev Environment Installer — Convenciones

## Estructura del proyecto

```
develop-install/
├── install.sh          # Orquestador principal
├── lib/
│   └── common.sh       # Helpers de print y log (solo eso)
├── <programa>/
│   └── install.sh      # Un script por programa
└── CLAUDE.md
```

## Formato estándar de cada `<programa>/install.sh`

Cada script debe seguir este orden y estructura exacta:

```bash
#!/bin/bash

# =============================================================================
# <programa>/install.sh
# Nombre:       <Nombre del programa>
# Descripción:  <Una línea>
# Web:          <URL oficial>
# Gestor:       Homebrew (macOS) · <alternativa> (Linux)
# Nota:         <opcional>
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

TOOL_NAME="<Nombre>"

detect_os()     # detecta OS y setea $OS y $DISTRO_ID
is_headless()   # (solo programas GUI) retorna 0 si no hay entorno gráfico
ensure_brew()  # instala Homebrew si no existe; lo activa en PATH en Linux
is_installed() # retorna 0 si el programa ya está instalado
get_version()  # retorna la versión como string
do_install()   # instala via brew en macOS, alternativa en Linux
do_update()    # actualiza via brew en macOS, alternativa en Linux
main()         # llama detect_os → (is_headless si aplica) → ensure_brew → is_installed → install/update

# Bloque al final para LOG_FILE cuando se ejecuta de forma independiente
if [[ -z "${LOG_FILE:-}" ]]; then ...
```

## Reglas

- **Cada script es autónomo**: detecta su propio OS y garantiza que brew esté instalado. No depende del orquestador para eso.
- **Homebrew es el gestor principal**: se instala primero en todos los scripts. En macOS se usa para todo. En Linux se instala igual, pero los casks no existen — usar la alternativa oficial del programa.
- **`lib/common.sh` solo tiene**: colores, funciones `print_*` y `log`. Sin lógica de OS ni de brew.
- **Log**: `LOG_FILE` se recibe como variable de entorno desde el orquestador, o se crea localmente si el script corre solo. Los logs van a `~/.dev-install/`.
- **Códigos de salida**: `exit 0` = OK, `exit 1` = error real, `exit 2` = omitido intencionalmente (ej. programa GUI en servidor headless). Las advertencias (`print_warn`) no abortan. El orquestador (`install.sh`) clasifica `exit 2` como "Omitido", no como error, y no cuenta para el `exit 1` final.
- **Programas GUI en Linux headless**: los programas de escritorio (VS Code, Ghostty, etc.) deben definir `is_headless()` — retorna 0 si no hay `$DISPLAY` ni `$WAYLAND_DISPLAY` — y comprobarlo en `main()` justo después de `detect_os`, antes de `ensure_brew`. Si es headless: `print_skip "..."` y `exit 2`.
- **Agregar un programa nuevo**: crear carpeta `<programa>/`, copiar cualquier `install.sh` existente como plantilla, completar las 4 funciones (`is_installed`, `get_version`, `do_install`, `do_update`) y agregar una línea al array `TOOLS` en el `install.sh` raíz.
- **Idempotencia**: cualquier modificación a archivos de configuración externos (`~/.claude/settings.json`, dotfiles, etc.) debe sobrescribir por clave completa, nunca fusionar/acumular arrays u objetos anidados. Ejecutar el script N veces debe producir el mismo archivo resultante que ejecutarlo una vez, sin líneas ni entradas duplicadas.

## Programas actuales

| Carpeta   | Nombre               | macOS            | Linux               |
|-----------|----------------------|------------------|---------------------|
| `git/`    | Git                  | brew formula     | brew formula        |
| `vscode/` | Visual Studio Code   | brew cask        | repo Microsoft      |
| `ghostty/`| Ghostty              | brew cask        | Flatpak             |
| `ohmyzsh/`| Oh My Zsh            | brew (zsh) + curl installer + git clone plugins | brew (zsh) + curl installer + git clone plugins |
| `claude/` | Claude Code          | instalador nativo (curl \| bash) | instalador nativo (curl \| bash) |
| `nvim/`   | Neovim               | brew formula | brew formula |
