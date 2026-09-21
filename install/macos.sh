#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------------------------
# Groups
#   base      — Homebrew, git, curl, coreutils
#   shell     — zsh (zinit is auto-bootstrapped by plugins.zsh)
#   cli       — eza, bat, duf, ripgrep, fzf, htop, git-delta
#   terminal  — kitty
#   editor    — neovim + AstroNvim, VS Code
#   cpp       — llvm, cmake, make, ninja, meson
#   python    — python3, pipx, graphviz
#   docker    — Docker Desktop (cask)
#   apps      — telegram, discord, chrome, obsidian, vlc, mpv
#   fonts     — Iosevka
#
# Profiles
#   --minimal      base + shell + cli + terminal
#   --workstation  minimal + editor + cpp + python
#   --full         everything
# ---------------------------------------------------------------------------

DO_BASE=false
DO_SHELL=false
DO_CLI=false
DO_TERMINAL=false
DO_EDITOR=false
DO_CPP=false
DO_PYTHON=false
DO_DOCKER=false
DO_APPS=false
DO_FONTS=false

usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Component flags:
  --base        Homebrew, git, curl, coreutils
  --shell       Zsh
  --cli         eza, bat, duf, ripgrep, fzf, htop, git-delta
  --terminal    Kitty
  --editor      Neovim (AstroNvim), VS Code
  --cpp         llvm, cmake, make, ninja, meson
  --python      python3, pipx, graphviz
  --docker      Docker Desktop
  --apps        Telegram, Discord, Chrome, Obsidian, VLC, mpv
  --fonts       Iosevka

Profiles:
  --minimal      base + shell + cli + terminal
  --workstation  minimal + editor + cpp + python
  --full         everything

  -h, --help    Show this help
EOF
    exit 0
}

[[ $# -eq 0 ]] && usage

for arg in "$@"; do
    case "$arg" in
        --base)      DO_BASE=true ;;
        --shell)     DO_SHELL=true ;;
        --cli)       DO_CLI=true ;;
        --terminal)  DO_TERMINAL=true ;;
        --editor)    DO_EDITOR=true ;;
        --cpp)       DO_CPP=true ;;
        --python)    DO_PYTHON=true ;;
        --docker)    DO_DOCKER=true ;;
        --apps)      DO_APPS=true ;;
        --fonts)     DO_FONTS=true ;;
        --minimal)
            DO_BASE=true; DO_SHELL=true; DO_CLI=true; DO_TERMINAL=true ;;
        --workstation)
            DO_BASE=true; DO_SHELL=true; DO_CLI=true; DO_TERMINAL=true
            DO_EDITOR=true; DO_CPP=true; DO_PYTHON=true ;;
        --full)
            DO_BASE=true; DO_SHELL=true; DO_CLI=true; DO_TERMINAL=true
            DO_EDITOR=true; DO_CPP=true; DO_PYTHON=true; DO_DOCKER=true
            DO_APPS=true; DO_FONTS=true ;;
        -h|--help) usage ;;
        *) echo "Unknown option: $arg"; usage ;;
    esac
done

# ---------------------------------------------------------------------------

install_base() {
    echo "==> [base] Homebrew + base tools"
    if ! command -v brew &>/dev/null; then
        echo "==> [base] installing Homebrew"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        # Add brew to PATH for the rest of this run (Apple Silicon vs Intel)
        if [[ -x /opt/homebrew/bin/brew ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -x /usr/local/bin/brew ]]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    else
        echo "==> [base] Homebrew already installed, skipping"
    fi

    brew update
    brew install git curl coreutils
    mkdir -p "$HOME/open_source"
}

install_shell() {
    echo "==> [shell] zsh"
    brew install zsh
    local zsh_path; zsh_path="$(brew --prefix)/bin/zsh"
    # Register the Homebrew zsh and make it the login shell
    if ! grep -qx "$zsh_path" /etc/shells; then
        echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
    fi
    chsh -s "$zsh_path"
}

install_cli() {
    echo "==> [cli] eza, bat, duf, ripgrep, fzf, htop, git-delta"
    brew install eza bat duf ripgrep fzf htop git-delta

    if [[ ! -d "$HOME/.fzf" ]]; then
        git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
        "$HOME/.fzf/install" --all
    else
        echo "==> [cli] fzf already installed, skipping"
    fi
}

install_terminal() {
    echo "==> [terminal] kitty"
    brew install --cask kitty
}

install_editor() {
    echo "==> [editor] neovim"
    brew install neovim

    echo "==> [editor] AstroNvim"
    for dir in ~/.config/nvim ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim; do
        [[ -d "$dir" ]] && mv "$dir" "${dir}.bak.$(date +%s)"
    done
    git clone --depth 1 https://github.com/AstroNvim/template ~/.config/nvim
    rm -rf ~/.config/nvim/.git

    echo "==> [editor] VS Code"
    brew install --cask visual-studio-code
}

install_cpp() {
    echo "==> [cpp] compilers + build tools"
    brew install llvm cmake make ninja meson
}

install_python() {
    echo "==> [python] python3 + pipx + graphviz"
    brew install python pipx graphviz
    pipx ensurepath
}

install_docker() {
    echo "==> [docker] Docker Desktop"
    brew install --cask docker
}

install_apps() {
    echo "==> [apps] desktop applications"
    brew install --cask \
        telegram \
        discord \
        google-chrome \
        obsidian \
        vlc
    brew install mpv
    mkdir -p "$HOME/Pictures/Screenshots"
}

install_fonts() {
    echo "==> [fonts] Iosevka"
    brew install --cask font-iosevka
}

# ---------------------------------------------------------------------------

$DO_BASE     && install_base
$DO_SHELL    && install_shell
$DO_CLI      && install_cli
$DO_TERMINAL && install_terminal
$DO_EDITOR   && install_editor
$DO_CPP      && install_cpp
$DO_PYTHON   && install_python
$DO_DOCKER   && install_docker
$DO_APPS     && install_apps
$DO_FONTS    && install_fonts

echo "==> Done."
