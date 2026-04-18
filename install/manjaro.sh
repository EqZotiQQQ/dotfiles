#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------------------------
# Groups
#   base      — system update, base-devel, paru AUR helper
#   shell     — zsh (zinit is auto-bootstrapped by plugins.zsh)
#   cli       — modern CLI replacements: eza, bat, duf, ripgrep, fzf, htop
#   terminal  — kitty, terminator
#   editor    — neovim + AstroNvim, VS Code
#   wm        — Hyprland stack: waybar, mako, wofi, wlogout, rofi, flameshot, i3lock
#   dev       — cmake, make, bash-lsp, docker
#   apps      — discord, telegram, chrome, obsidian, qbittorrent, nekobox, mpv
#   fonts     — Iosevka
#
# Profiles
#   --minimal   base + shell + cli + terminal
#   --desktop   minimal + wm + editor + fonts
#   --full      everything
# ---------------------------------------------------------------------------

DO_BASE=false
DO_SHELL=false
DO_CLI=false
DO_TERMINAL=false
DO_EDITOR=false
DO_WM=false
DO_DEV=false
DO_APPS=false
DO_FONTS=false

usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Component flags:
  --base        System update, base-devel, paru
  --shell       Zsh
  --cli         eza, bat, duf, ripgrep, fzf, htop
  --terminal    Kitty, Terminator
  --editor      Neovim (AstroNvim), VS Code
  --wm          Hyprland, Waybar, Mako, Wofi, Wlogout, Rofi, Flameshot, i3lock
  --dev         cmake, make, bash-language-server, Docker
  --apps        Discord, Telegram, Chrome, Obsidian, qBittorrent, Nekobox, mpv
  --fonts       Iosevka

Profiles:
  --minimal     base + shell + cli + terminal
  --desktop     minimal + wm + editor + fonts
  --full        everything

  -h, --help    Show this help
EOF
    exit 0
}

[[ $# -eq 0 ]] && usage

for arg in "$@"; do
    case "$arg" in
        --base)     DO_BASE=true ;;
        --shell)    DO_SHELL=true ;;
        --cli)      DO_CLI=true ;;
        --terminal) DO_TERMINAL=true ;;
        --editor)   DO_EDITOR=true ;;
        --wm)       DO_WM=true ;;
        --dev)      DO_DEV=true ;;
        --apps)     DO_APPS=true ;;
        --fonts)    DO_FONTS=true ;;
        --minimal)
            DO_BASE=true; DO_SHELL=true; DO_CLI=true; DO_TERMINAL=true ;;
        --desktop)
            DO_BASE=true; DO_SHELL=true; DO_CLI=true; DO_TERMINAL=true
            DO_WM=true;   DO_EDITOR=true; DO_FONTS=true ;;
        --full)
            DO_BASE=true; DO_SHELL=true; DO_CLI=true; DO_TERMINAL=true
            DO_WM=true;   DO_EDITOR=true; DO_DEV=true; DO_APPS=true; DO_FONTS=true ;;
        -h|--help) usage ;;
        *) echo "Unknown option: $arg"; usage ;;
    esac
done

# ---------------------------------------------------------------------------

install_base() {
    echo "==> [base] system update + base-devel"
    sudo pacman -Syu --noconfirm
    sudo pacman -S --needed --noconfirm base-devel git

    if ! command -v paru &>/dev/null; then
        echo "==> [base] installing paru"
        local tmp; tmp=$(mktemp -d)
        git clone https://aur.archlinux.org/paru.git "$tmp/paru"
        (cd "$tmp/paru" && makepkg -si --noconfirm)
    else
        echo "==> [base] paru already installed, skipping"
    fi
}

install_shell() {
    echo "==> [shell] zsh"
    paru -S --skipreview --noconfirm zsh
    chsh -s "$(which zsh)"
}

install_cli() {
    echo "==> [cli] eza, bat, duf, ripgrep, fzf, htop"
    paru -S --skipreview --noconfirm eza bat duf ripgrep fzf htop

    if [[ ! -d "$HOME/.fzf" ]]; then
        git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
        "$HOME/.fzf/install" --all
    else
        echo "==> [cli] fzf already installed, skipping"
    fi
}

install_terminal() {
    echo "==> [terminal] kitty, terminator"
    paru -S --skipreview --noconfirm kitty terminator
}

install_editor() {
    echo "==> [editor] neovim"
    paru -S --skipreview --noconfirm neovim

    echo "==> [editor] AstroNvim"
    for dir in ~/.config/nvim ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim; do
        [[ -d "$dir" ]] && mv "$dir" "${dir}.bak.$(date +%s)"
    done
    git clone --depth 1 https://github.com/AstroNvim/template ~/.config/nvim
    rm -rf ~/.config/nvim/.git

    echo "==> [editor] VS Code"
    paru -S --skipreview --noconfirm visual-studio-code-bin
}

install_wm() {
    echo "==> [wm] Hyprland stack"
    paru -S --skipreview --noconfirm \
        hyprland \
        waybar \
        mako \
        wofi \
        hyprpaper \
        wlogout \
        flameshot \
        i3lock-color \
        hyprpaper \
        hyprshot \
        hypridle \
        hyprpolkitagent \
        hyprlock \
        xdg-desktop-portal-hyprland
}

install_dev() {
    echo "==> [dev] build tools + docker"
    paru -S --skipreview --noconfirm \
        cmake \
        make \
        bash-language-server \
        docker \
        docker-compose

    echo "==> [dev] docker post-setup"
    sudo groupadd docker 2>/dev/null || true
    sudo usermod -aG docker "$USER"
    sudo setfacl --modify "user:$(whoami):rw" /var/run/docker.sock || true

    mkdir -p "$HOME/open_source"
}

install_apps() {
    echo "==> [apps] desktop applications"
    paru -S --skipreview --noconfirm \
        discord \
        telegram-desktop-git \
        google-chrome \
        obsidian \
        qbittorrent \
        nekobox \
        dolphin \
        mpv
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
$DO_WM       && install_wm
$DO_DEV      && install_dev
$DO_APPS     && install_apps
$DO_FONTS    && install_fonts

echo "==> Done."
