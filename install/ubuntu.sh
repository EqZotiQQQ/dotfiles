#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------------------------
# Groups
#   base      — apt update/upgrade, build-essential, git, curl
#   shell     — zsh
#   cli       — eza, bat, ripgrep, fzf, htop, net-tools, duf, delta
#   terminal  — kitty
#   editor    — neovim + AstroNvim
#   cpp       — gcc, clang, cmake, make, ninja, meson, libstdc++ headers
#   python    — python3, pip, venv, deadsnakes PPA, graphviz
#   lua       — lua-posix, luarocks
#   docker    — docker engine, docker-compose, post-setup
#   audio     — pavucontrol
#   perf      — linux-tools (perf)
#   apps      — telegram, discord, vlc
#   fonts     — Iosevka
#
# Profiles
#   --minimal      base + shell + cli + terminal
#   --workstation  minimal + editor + cpp + python + docker
#   --full         everything
# ---------------------------------------------------------------------------

DO_BASE=false
DO_SHELL=false
DO_CLI=false
DO_TERMINAL=false
DO_EDITOR=false
DO_CPP=false
DO_PYTHON=false
DO_LUA=false
DO_DOCKER=false
DO_AUDIO=false
DO_PERF=false
DO_APPS=false
DO_FONTS=false

usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Component flags:
  --base        apt update/upgrade, build-essential, git, curl
  --shell       Zsh
  --cli         eza, bat, ripgrep, fzf, htop, net-tools, duf, delta
  --terminal    Kitty
  --editor      Neovim (AstroNvim)
  --cpp         gcc, clang, cmake, make, ninja, meson, libstdc++ headers
  --python      python3, pip, venv, graphviz (deadsnakes PPA)
  --lua         lua-posix, luarocks
  --docker      Docker Engine + Compose, post-setup (rootless group, acl)
  --audio       pavucontrol
  --perf        linux-tools (perf)
  --apps        Telegram, Discord, VLC
  --fonts       Iosevka

Profiles:
  --minimal      base + shell + cli + terminal
  --workstation  minimal + editor + cpp + python + docker
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
        --lua)       DO_LUA=true ;;
        --docker)    DO_DOCKER=true ;;
        --audio)     DO_AUDIO=true ;;
        --perf)      DO_PERF=true ;;
        --apps)      DO_APPS=true ;;
        --fonts)     DO_FONTS=true ;;
        --minimal)
            DO_BASE=true; DO_SHELL=true; DO_CLI=true; DO_TERMINAL=true ;;
        --workstation)
            DO_BASE=true; DO_SHELL=true; DO_CLI=true; DO_TERMINAL=true
            DO_EDITOR=true; DO_CPP=true; DO_PYTHON=true; DO_DOCKER=true ;;
        --full)
            DO_BASE=true; DO_SHELL=true; DO_CLI=true; DO_TERMINAL=true
            DO_EDITOR=true; DO_CPP=true; DO_PYTHON=true; DO_LUA=true
            DO_DOCKER=true; DO_AUDIO=true; DO_PERF=true; DO_APPS=true; DO_FONTS=true ;;
        -h|--help) usage ;;
        *) echo "Unknown option: $arg"; usage ;;
    esac
done

# ---------------------------------------------------------------------------

install_base() {
    echo "==> [base] apt update + base tools"
    sudo apt update
    sudo apt upgrade -y
    sudo apt install -y build-essential git curl wget ca-certificates gnupg lsb-release
    mkdir -p "$HOME/open_source"
}

install_shell() {
    echo "==> [shell] zsh"
    sudo apt install -y zsh
    chsh -s "$(which zsh)"
}

install_cli() {
    echo "==> [cli] modern CLI tools"
    # bat, ripgrep, htop, net-tools available in apt
    sudo apt install -y bat ripgrep htop net-tools

    # eza (not in standard apt — install via cargo or download binary)
    if ! command -v eza &>/dev/null; then
        sudo mkdir -p /etc/apt/keyrings
        wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc \
            | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
        echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" \
            | sudo tee /etc/apt/sources.list.d/gierens.list
        sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
        sudo apt update
        sudo apt install -y eza
    else
        echo "==> [cli] eza already installed, skipping"
    fi

    # duf — not in standard apt
    if ! command -v duf &>/dev/null; then
        local tmp; tmp=$(mktemp -d)
        curl -s https://api.github.com/repos/muesli/duf/releases/latest \
            | grep '"browser_download_url".*linux_amd64.deb' \
            | cut -d '"' -f 4 \
            | xargs curl -L -o "$tmp/duf.deb"
        sudo dpkg -i "$tmp/duf.deb"
    else
        echo "==> [cli] duf already installed, skipping"
    fi

    # delta — git-delta есть в apt с Ubuntu 23.04, иначе .deb с GitHub
    if ! command -v delta &>/dev/null; then
        if apt-cache show git-delta &>/dev/null; then
            sudo apt install -y git-delta
        else
            local tmp; tmp=$(mktemp -d)
            curl -s https://api.github.com/repos/dandavison/delta/releases/latest \
                | grep '"browser_download_url".*git-delta_.*_amd64.deb' \
                | cut -d '"' -f 4 \
                | head -n1 \
                | xargs curl -L -o "$tmp/delta.deb"
            sudo dpkg -i "$tmp/delta.deb"
        fi
    else
        echo "==> [cli] delta already installed, skipping"
    fi

    # fzf
    sudo apt install -y fzf
    if [[ ! -d "$HOME/.fzf" ]]; then
        git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
        "$HOME/.fzf/install" --all
    else
        echo "==> [cli] fzf shell integration already installed, skipping"
    fi
}

install_terminal() {
    echo "==> [terminal] kitty"
    sudo apt install -y kitty
}

install_editor() {
    echo "==> [editor] neovim"
    # Use PPA for a recent version — apt ships an old neovim on most Ubuntu releases
    sudo add-apt-repository ppa:neovim-ppa/unstable -y
    sudo apt update
    sudo apt install -y neovim

    echo "==> [editor] AstroNvim"
    for dir in ~/.config/nvim ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim; do
        [[ -d "$dir" ]] && mv "$dir" "${dir}.bak.$(date +%s)"
    done
    git clone --depth 1 https://github.com/AstroNvim/template ~/.config/nvim
    rm -rf ~/.config/nvim/.git
}

install_cpp() {
    echo "==> [cpp] compilers + build tools"
    sudo apt install -y \
        gcc \
        clang \
        cmake \
        make \
        ninja-build \
        meson \
        libstdc++-12-dev \
        libc++abi-dev
}

install_python() {
    echo "==> [python] python3 + pip + venv"
    sudo add-apt-repository ppa:deadsnakes/ppa -y
    sudo apt update
    sudo apt install -y \
        python3 \
        python3-pip \
        python3-venv \
        python3-dev \
        graphviz
}

install_lua() {
    echo "==> [lua] lua + luarocks"
    sudo apt install -y lua-posix luarocks
}

install_docker() {
    echo "==> [docker] Docker Engine"
    if ! command -v docker &>/dev/null; then
        sudo install -m 0755 -d /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
            | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        sudo chmod a+r /etc/apt/keyrings/docker.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
            | sudo tee /etc/apt/sources.list.d/docker.list
        sudo apt update
        sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    else
        echo "==> [docker] docker already installed, skipping"
    fi

    echo "==> [docker] post-setup"
    sudo groupadd docker 2>/dev/null || true
    sudo usermod -aG docker "$USER"
    sudo setfacl --modify "user:$(whoami):rw" /var/run/docker.sock || true
}

install_audio() {
    echo "==> [audio] pavucontrol"
    sudo apt install -y pavucontrol
}

install_perf() {
    echo "==> [perf] linux-tools"
    sudo apt install -y "linux-tools-$(uname -r)" linux-tools-generic || \
        echo "WARNING: kernel-specific tools not available for $(uname -r), install manually"
}

install_apps() {
    echo "==> [apps] telegram, discord, vlc"
    sudo snap install telegram-desktop
    sudo snap install discord
    sudo snap install vlc
    mkdir -p "$HOME/Pictures/Screenshots"
}

install_fonts() {
    echo "==> [fonts] Iosevka"
    local tmp; tmp=$(mktemp -d)
    curl -s https://api.github.com/repos/be5invis/Iosevka/releases/latest \
        | grep '"browser_download_url".*PkgTTC-Iosevka-.*\.zip' \
        | cut -d '"' -f 4 \
        | xargs curl -L -o "$tmp/iosevka.zip"
    unzip "$tmp/iosevka.zip" -d "$tmp/iosevka"
    mkdir -p ~/.local/share/fonts/iosevka
    cp "$tmp"/iosevka/*.ttc ~/.local/share/fonts/iosevka/ 2>/dev/null \
        || cp "$tmp"/iosevka/*.ttf ~/.local/share/fonts/iosevka/
    fc-cache -f -v
}

# ---------------------------------------------------------------------------

$DO_BASE     && install_base
$DO_SHELL    && install_shell
$DO_CLI      && install_cli
$DO_TERMINAL && install_terminal
$DO_EDITOR   && install_editor
$DO_CPP      && install_cpp
$DO_PYTHON   && install_python
$DO_LUA      && install_lua
$DO_DOCKER   && install_docker
$DO_AUDIO    && install_audio
$DO_PERF     && install_perf
$DO_APPS     && install_apps
$DO_FONTS    && install_fonts

echo "==> Done."
