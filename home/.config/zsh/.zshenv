#!/bin/zsh

# XDG Base Directories
export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_CACHE_HOME="${HOME}/.cache"
export XDG_DATA_HOME="${HOME}/.local/share"
export XDG_STATE_HOME="${HOME}/.local/state"

# PATH
export PATH="${HOME}/.local/bin:${PATH}"

# Use nvim for man pages
export MANPAGER="nvim +Man!"
export MANWIDTH=999

# Lang toolchains
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
