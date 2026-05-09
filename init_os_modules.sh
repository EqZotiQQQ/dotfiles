#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${SCRIPT_DIR}/install"

# ---------------------------------------------------------------------------
OS=""
PROFILE=""
OPEN_SOURCE=false
DO_SYMLINKS=false
OVERWRITE=false

usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

  --os OS          Target OS: manjaro | ubuntu  (auto-detected if omitted)
  --profile NAME   Profile passed to the OS install script:
                     manjaro: minimal | desktop | full
                     ubuntu:  minimal | workstation | full
                   Or any component flag(s): --wm, --editor, --dev, ...
  --open-source    Run install/open_source.sh --all  (Ubuntu only)
  --symlinks       Set up dotfile symlinks via main.py
  --overwrite      Overwrite existing symlinks (implies --symlinks)
  -h, --help       Show this help

Examples:
  $(basename "$0") --profile desktop --symlinks
  $(basename "$0") --os ubuntu --profile workstation --open-source --symlinks
  $(basename "$0") --symlinks --overwrite
EOF
    exit 0
}

[[ $# -eq 0 ]] && usage

PROFILE_ARGS=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        --os)         OS="$2"; shift 2 ;;
        --profile)    PROFILE="$2"; shift 2 ;;
        --open-source) OPEN_SOURCE=true; shift ;;
        --symlinks)   DO_SYMLINKS=true; shift ;;
        --overwrite)  OVERWRITE=true; DO_SYMLINKS=true; shift ;;
        -h|--help)    usage ;;
        --*)          PROFILE_ARGS+=("$1"); shift ;;
        *)            echo "Unknown option: $1"; usage ;;
    esac
done

# ---------------------------------------------------------------------------

detect_os() {
    if [[ -f /etc/os-release ]]; then
        # shellcheck source=/dev/null
        source /etc/os-release
        echo "${ID:-unknown}"
    else
        echo "unknown"
    fi
}

run_install() {
    local os="$1"
    local script="${INSTALL_DIR}/${os}.sh"

    if [[ ! -f "$script" ]]; then
        echo "ERROR: no install script for OS '${os}' at ${script}"
        exit 1
    fi

    local args=()
    [[ -n "$PROFILE" ]] && args+=("--${PROFILE}")
    args+=("${PROFILE_ARGS[@]+"${PROFILE_ARGS[@]}"}")

    if [[ ${#args[@]} -eq 0 ]]; then
        echo "WARNING: no --profile specified, running ${os}.sh with no arguments (will show help)"
    fi

    echo "==> Installing packages for ${os}${args:+ (${args[*]})}"
    bash "$script" "${args[@]+"${args[@]}"}"
}

run_open_source() {
    echo "==> Building from source"
    bash "${INSTALL_DIR}/open_source.sh" --all
}

run_symlinks() {
    echo "==> Setting up symlinks"
    local py_args=(-s -f)
    $OVERWRITE && py_args+=(-o)
    python3 "${SCRIPT_DIR}/install/main.py" "${py_args[@]}"
}

run_wallpapers() {
    local src="${SCRIPT_DIR}/wallpapers"
    [[ -d "$src" ]] || return 0

    local dest="${HOME}/Pictures/wallpapers"
    mkdir -p "$dest"
    echo "==> Symlinking wallpapers into ${dest}"

    for file in "$src"/*; do
        [[ -e "$file" ]] || continue
        local name
        name="$(basename "$file")"
        local target="${dest}/${name}"
        if [[ -e "$target" || -L "$target" ]]; then
            if $OVERWRITE; then
                ln -sf "$file" "$target"
                echo "    overwrite: ${name}"
            else
                echo "    skip (exists): ${name}"
            fi
        else
            ln -s "$file" "$target"
            echo "    link: ${name}"
        fi
    done
}

# ---------------------------------------------------------------------------

if [[ -z "$OS" ]]; then
    OS="$(detect_os)"
    echo "==> Detected OS: ${OS}"
fi

[[ -n "$PROFILE" || ${#PROFILE_ARGS[@]} -gt 0 ]] && run_install "$OS"
$OPEN_SOURCE && run_open_source
$DO_SYMLINKS && run_symlinks
$DO_SYMLINKS && run_wallpapers

echo "==> Done."
