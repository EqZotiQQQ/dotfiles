# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal dotfiles for Manjaro Linux. Window manager: Hyprland (migrated from AwesomeWM). Shell: Zsh with Zinit + Powerlevel10k. Editor: Neovim (AstroNvim).

The repo has two config trees:
- `home/` — current active configs, symlinked into `~`
- `home.legacy/` — archived configs (AwesomeWM era, X11-based), kept for reference

## Setup

**Entry point** — `init_os_modules.sh` auto-detects the OS and wires everything together:

```bash
# Fresh Manjaro install — desktop profile + symlinks:
./init_os_modules.sh --profile desktop --symlinks

# Fresh Ubuntu install — workstation + build from source + symlinks:
./init_os_modules.sh --os ubuntu --profile workstation --open-source --symlinks

# Only set up dotfile symlinks (overwrite existing):
./init_os_modules.sh --symlinks --overwrite

# Individual components instead of a profile:
./init_os_modules.sh --wm --editor --symlinks
```

**`install/`** — все скрипты установки и менеджер симлинков:
- `install/manjaro.sh` — paru-based; profiles: `minimal`, `desktop`, `full`
- `install/ubuntu.sh` — apt-based; profiles: `minimal`, `workstation`, `full`
- `install/open_source.sh` — builds from source: `--i3lock`, `--rofi`, `--picom`, `--cava`
- `install/main.py` + `install/app_settings.py` — менеджер симлинков

**Симлинки напрямую** — `install/main.py` управляет `home/` → `~` и `etc/` → `/etc`:

```bash
python install/main.py -s        # dry-run
python install/main.py -s -f     # применить
python install/main.py -s -f -o  # применить + перезаписать существующие
```

## Zsh config structure

`home/.zshenv` → sets `ZDOTDIR=~/.config/zsh` and sources `~/.config/zsh/.zshenv`.

All zsh config lives in `home/.config/zsh/`:
- `.zshrc` — plugins (Zinit), prompt (p10k), sources all `aliases/*`
- `settings/plugins.zsh` — Zinit plugin declarations
- `settings/bindings.zsh` — key bindings
- `aliases/01_standard_app_replacement.zsh` — modern CLI replacements: `exa`→`ls`, `bat`→`cat`, `duf`→`df`, `rg`→`grep`, `nvim`→`vim`
- `aliases/03_git.zsh` — git shortcuts (`gs`, `gaa`, `gps`, `gpl`, `gd`, `gl`, `gc`, `gcm`, etc.)

## Scripts

`home/.local/scripts/` — shell scripts used by the WM and keybindings:
- `lock_screen.sh` — i3lock wrapper
- `waybar_live_reload.sh` — reloads waybar on config change (used via systemd user service)
- `mount_disk.sh` — mounts Windows disk (iCloud/Obsidian access)
- `brightness_handle.sh` — brightness control

## Submodule

`home/.config/awesome/cosy` — AwesomeWM widget library (legacy, not used in current Hyprland setup).
