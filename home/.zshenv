#!/bin/zsh

echo '.zshenv home'

[ -d "${HOME}/.config/zsh" ] && export ZDOTDIR="${HOME}/.config/zsh" && source "${ZDOTDIR}/.zshenv"

