#!/bin/bash

[ -d "${HOME}/.config/zsh" ] && export ZDOTDIR="${HOME}/.config/zsh"

open_source_dir="${HOME}/open_source"

[ ! -d "${HOME}/open_source/alias-tips" ] && git clone https://github.com/djui/alias-tips.git "${open_source_dir}/alias-tips"
source "${HOME}/open_source/alias-tips/alias-tips.plugin.zsh"
export ZSH_PLUGINS_ALIAS_TIPS_TEXT="Alias tip: "

