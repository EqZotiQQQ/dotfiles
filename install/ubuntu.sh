#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------------------------
# Groups
#   base      — apt update/upgrade, build-essential, git, curl
#   shell     — zsh
#   cli       — eza, bat, ripgrep, fzf, htop, net-tools, duf, delta
#   terminal  — kitty
#   editor    — neovim + AstroNvim, VS Code
#   wm        — Hyprland stack built from source (hyprbuntu), Quickshell (source), wofi, flameshot,
#               qylock lockscreen, proctree
#   cpp       — gcc, clang (+ clang-22/clangd-22), cmake, make, ninja, meson, libstdc++ headers
#   python    — python3, pip, venv, deadsnakes PPA, graphviz
#   lua       — lua-posix, luarocks
#   docker    — docker engine, docker-compose, post-setup
#   audio     — pavucontrol
#   perf      — linux-tools (perf)
#   apps      — telegram, discord, vlc, google chrome, dolphin
#   fonts     — Iosevka, Nerd Fonts (Hack, Iosevka)
#
# Profiles
#   --minimal      base + shell + cli + terminal
#   --workstation  minimal + editor + cpp + python + docker
#   --desktop      minimal + wm + editor + fonts
#   --full         everything
# ---------------------------------------------------------------------------

DO_BASE=false
DO_SHELL=false
DO_CLI=false
DO_TERMINAL=false
DO_EDITOR=false
DO_WM=false
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
  --editor      Neovim (AstroNvim), VS Code
  --wm          Hyprland stack (hyprbuntu, from source), Quickshell, wofi, flameshot, qylock, proctree
  --cpp         gcc, clang, clang-22, clangd-22, cmake, make, ninja, meson, libstdc++ headers
  --python      python3, pip, venv, graphviz (deadsnakes PPA)
  --lua         lua-posix, luarocks
  --docker      Docker Engine + Compose, post-setup (rootless group, acl)
  --audio       pavucontrol
  --perf        linux-tools (perf)
  --apps        Telegram, Discord, VLC, Google Chrome, Dolphin
  --fonts       Iosevka, Hack/Iosevka Nerd Fonts

Profiles:
  --minimal      base + shell + cli + terminal
  --workstation  minimal + editor + cpp + python + docker
  --desktop      minimal + wm + editor + fonts
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
        --wm)        DO_WM=true ;;
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
        --desktop)
            DO_BASE=true; DO_SHELL=true; DO_CLI=true; DO_TERMINAL=true
            DO_WM=true;   DO_EDITOR=true; DO_FONTS=true ;;
        --full)
            DO_BASE=true; DO_SHELL=true; DO_CLI=true; DO_TERMINAL=true
            DO_EDITOR=true; DO_WM=true; DO_CPP=true; DO_PYTHON=true; DO_LUA=true
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

    echo "==> [editor] VS Code"
    if ! command -v code &>/dev/null; then
        local tmp; tmp=$(mktemp -d)
        curl -fL -o "$tmp/code.deb" "https://update.code.visualstudio.com/latest/linux-deb-x64/stable"
        sudo apt install -y "$tmp/code.deb" # the package adds Microsoft's apt repo for updates
    else
        echo "==> [editor] code already installed, skipping"
    fi
}

install_wm() {
    local repo; repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

    # apt builds of hyprwm libs (left behind by apt install/remove hyprland) live in /usr/lib/x86_64-linux-gnu,
    # which the linker searches before /usr/lib where hyprbuntu installs: Hyprland would load the stale .so
    local stale
    stale=$(dpkg-query -W -f='${db:Status-Status} ${Package}\n' hyprland hyprpicker xdg-desktop-portal-hyprland \
        'libhypr*' 'libaquamarine*' 2>/dev/null | awk '$1 == "installed" { print $2 }' || true)
    if [[ -n "$stale" ]]; then
        echo "==> [wm] purging apt hyprwm packages:" $stale
        sudo apt-get purge -y $stale
    fi

    # hyprbuntu writes a default hypridle.conf / mako config when there is none, and ./dot -s links after this script
    for f in .config/hypr/hypridle.conf .config/mako/config; do
        if [[ ! -e "$HOME/$f" && ! -L "$HOME/$f" ]]; then
            mkdir -p "$(dirname "$HOME/$f")"
            ln -s "$repo/home/$f" "$HOME/$f"
        fi
    done

    echo "==> [wm] Hyprland stack from source (hyprbuntu)"
    local hyprbuntu="$HOME/open_source/hyprbuntu"
    if [[ -d "$hyprbuntu" ]]; then
        git -C "$hyprbuntu" pull --ff-only
    else
        git clone https://gitlab.com/kralos/hyprbuntu.git "$hyprbuntu"
    fi
    # mako, not swaync; dolphin instead of thunar; the bar is Quickshell, not waybar; login via GDM, no tuigreet
    NVIDIA_SETUP=true THEME_PREF=dark NOTIFICATION_DAEMON_PREF=mako \
        HYPRPAPER_SETUP=true HYPRLOCK_SETUP=true HYPRIDLE_SETUP=true HYPRSHOT_SETUP=true SWAYOSD_SETUP=true \
        THUNAR_SETUP=false WAYBAR_SETUP=false TUIGREET_SETUP=false DISABLE_CONFIRM=true \
        "$hyprbuntu/hyprbuntu.sh"

    # RTX 50xx runs only on the open kernel module; the closed one (from the Ubuntu installer) loads instead
    # when both are there: nvidia-smi says "No devices were found"
    if dpkg-query -W -f='${db:Status-Status}\n' 'nvidia-driver-*-open' 2>/dev/null | grep -qx installed; then
        local closed
        closed=$(dpkg-query -W -f='${db:Status-Status} ${Package}\n' 'linux-modules-nvidia-*' 2>/dev/null \
            | awk '$1 == "installed" && $2 !~ /-open-/ { print $2 }' || true)
        if [[ -n "$closed" ]]; then
            echo "==> [wm] purging closed nvidia kernel modules:" $closed
            sudo apt-get purge -y $closed
            sudo update-initramfs -u
        fi
    fi

    # hyprland.lua starts the agent by its Arch path; hyprbuntu installs it into /usr/libexec
    sudo mkdir -p /usr/lib/hyprpolkitagent
    sudo ln -sfn /usr/libexec/hyprpolkitagent /usr/lib/hyprpolkitagent/hyprpolkitagent

    echo "==> [wm] wofi, wtype, imagemagick, jq, flameshot"
    sudo apt install -y wofi wtype imagemagick jq flameshot

    echo "==> [wm] Quickshell (not in apt, built from source)"
    sudo apt install -y \
        cmake ninja-build pkg-config spirv-tools libcli11-dev \
        qt6-base-dev qt6-base-private-dev qt6-declarative-dev qt6-declarative-private-dev \
        qt6-wayland-dev qt6-wayland-private-dev qt6-shadertools-dev qt6-svg-dev \
        libwayland-dev wayland-protocols libdrm-dev libgbm-dev libpipewire-0.3-dev \
        libpam0g-dev libjemalloc-dev libpolkit-agent-1-dev libglib2.0-dev libxcb1-dev \
        qml6-module-qtquick qml6-module-qtquick-layouts qml6-module-qtquick-shapes \
        qml6-module-qtquick-effects qml6-module-qtquick-controls qml6-module-qtquick-window \
        qml6-module-qtqml-workerscript qml6-module-qt5compat-graphicaleffects
    if ! command -v qs &>/dev/null; then
        local qs_src="$HOME/open_source/quickshell"
        [[ -d "$qs_src" ]] || git clone --branch v0.3.2 https://git.outfoxxed.me/quickshell/quickshell "$qs_src"
        # the crash handler needs cpptrace, which Ubuntu doesn't package
        cmake -S "$qs_src" -B "$qs_src/build" -GNinja -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCRASH_HANDLER=OFF
        cmake --build "$qs_src/build"
        sudo cmake --install "$qs_src/build"
    else
        echo "==> [wm] quickshell already installed, skipping"
    fi

    # lockscreen engine for ~/.local/bin/lock (qylock, sparse: no theme videos); more themes: lock --fetch <name>
    # video backgrounds of qylock themes need Qt Multimedia + gstreamer
    echo "==> [wm] qylock lockscreen engine"
    sudo apt install -y qml6-module-qtmultimedia qt6-svg-plugins \
        gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad \
        gstreamer1.0-plugins-ugly gstreamer1.0-libav
    "$repo/home/.local/bin/lock" --fetch

    # proctree is started by hyprland.lua from ~/.local/bin; its source isn't cloned here
    echo "==> [wm] proctree"
    sudo apt install -y libsdl3-dev libyaml-cpp-dev libboost-program-options-dev libgtest-dev
    local proctree="$HOME/my_projects/proctree"
    if [[ -d "$proctree" ]]; then
        make -C "$proctree" release
        mkdir -p "$HOME/.local/bin"
        ln -sfn "$proctree/build/proctree" "$HOME/.local/bin/proctree"
    else
        echo "==> [wm] no $proctree, skipping build (clone it and rerun --wm)"
    fi
}

install_cpp() {
    echo "==> [cpp] compilers + build tools"
    sudo apt install -y \
        gcc \
        clang \
        clang-22 \
        clangd-22 \
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
    sudo apt install -y snapd
    sudo snap install telegram-desktop
    sudo snap install discord
    sudo snap install vlc
    mkdir -p "$HOME/Pictures/Screenshots"

    echo "==> [apps] google chrome"
    if ! command -v google-chrome-stable &>/dev/null; then
        local tmp; tmp=$(mktemp -d)
        curl -fL -o "$tmp/chrome.deb" https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
        sudo apt install -y "$tmp/chrome.deb" # the package adds Google's apt repo for updates
    else
        echo "==> [apps] google chrome already installed, skipping"
    fi

    echo "==> [apps] dolphin"
    sudo apt install -y dolphin
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

    # the bar's icons are Hack Nerd Font, kitty uses Iosevka Nerd Font; apt only has the plain ones
    echo "==> [fonts] Nerd Fonts: Hack, Iosevka"
    mkdir -p ~/.local/share/fonts/nerd
    for f in Hack Iosevka; do
        curl -fL "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$f.tar.xz" \
            | tar -xJ -C ~/.local/share/fonts/nerd
    done
    fc-cache -f -v
}

# ---------------------------------------------------------------------------

$DO_BASE     && install_base
$DO_SHELL    && install_shell
$DO_CLI      && install_cli
$DO_TERMINAL && install_terminal
$DO_EDITOR   && install_editor
$DO_WM       && install_wm
$DO_CPP      && install_cpp
$DO_PYTHON   && install_python
$DO_LUA      && install_lua
$DO_DOCKER   && install_docker
$DO_AUDIO    && install_audio
$DO_PERF     && install_perf
$DO_APPS     && install_apps
$DO_FONTS    && install_fonts

echo "==> Done."

# curl -fsSL https://tailscale.com/install.sh | sh