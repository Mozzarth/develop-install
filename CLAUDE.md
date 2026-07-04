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

detect_os()    # detecta OS y setea $OS y $DISTRO_ID
ensure_brew()  # instala Homebrew si no existe; lo activa en PATH en Linux
is_installed() # retorna 0 si el programa ya está instalado
get_version()  # retorna la versión como string
do_install()   # instala via brew en macOS, alternativa en Linux
do_update()    # actualiza via brew en macOS, alternativa en Linux
main()         # llama detect_os → ensure_brew → is_installed → install/update

# Bloque al final para LOG_FILE cuando se ejecuta de forma independiente
if [[ -z "${LOG_FILE:-}" ]]; then ...
```

## Reglas

- **Cada script es autónomo**: detecta su propio OS y garantiza que brew esté instalado. No depende del orquestador para eso.
- **Homebrew es el gestor principal**: se instala primero en todos los scripts. En macOS se usa para todo. En Linux se instala igual, pero los casks no existen — usar la alternativa oficial del programa.
- **`lib/common.sh` solo tiene**: colores, funciones `print_*` y `log`. Sin lógica de OS ni de brew.
- **Log**: `LOG_FILE` se recibe como variable de entorno desde el orquestador, o se crea localmente si el script corre solo. Los logs van a `~/.dev-install/`.
- **Salida con `exit 1`** si falla una instalación. Las advertencias (`print_warn`) no abortan.
- **Agregar un programa nuevo**: crear carpeta `<programa>/`, copiar cualquier `install.sh` existente como plantilla, completar las 4 funciones (`is_installed`, `get_version`, `do_install`, `do_update`) y agregar una línea al array `TOOLS` en el `install.sh` raíz.

## Programas actuales

| Carpeta   | Nombre               | macOS            | Linux               |
|-----------|----------------------|------------------|---------------------|
| `git/`    | Git                  | brew formula     | brew formula        |
| `vscode/` | Visual Studio Code   | brew cask        | repo Microsoft      |
| `ghostty/`| Ghostty              | brew cask        | Flatpak             |
| `ohmyzsh/`| Oh My Zsh            | brew (zsh) + curl installer + git clone plugins | brew (zsh) + curl installer + git clone plugins |
| `claude/` | Claude Code          | brew (node) + npm install -g | brew (node) + npm install -g |
| `nvim/`   | Neovim               | brew formula | brew formula |
