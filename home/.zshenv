#!/bin/zsh

[ -d "${HOME}/.config/zsh" ] && export ZDOTDIR="${HOME}/.config/zsh"

[ ! -d "${HOME}/open_source/alias-tips" ] && git clone https://github.com/djui/alias-tips.git "${OPEN_SOURCE_DIR}/alias-tips"

source "${HOME}/open_source/alias-tips/alias-tips.plugin.zsh"
export ZSH_PLUGINS_ALIAS_TIPS_TEXT="Alias tip: "

[ -d "${HOME}/shared" ] && source "${HOME}/shared/env.sh"
