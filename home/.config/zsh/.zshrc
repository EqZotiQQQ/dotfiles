#!/bin/zsh

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.config/zsh/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Language environment
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

export TERM=terminator
export ZINIT_HOME="${ZDOTDIR}/zinit"

# Create cache dir if missing
export ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/"
if [[ ! -d "${ZSH_CACHE_DIR}" ]]; then
  mkdir -p "${ZSH_CACHE_DIR}"
fi

if [ -z "$ZDOTDIR" ]; then
  export ZDOTDIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"
fi

# History settings
HISTFILE=~/.zsh_history         # File where command history is stored
HISTSIZE=10000                   # Number of commands kept in memory
SAVEHIST=10000                   # Number of commands saved to the file

# History behavior options
setopt append_history           # Append new commands to the history file
setopt hist_ignore_dups         # Ignore duplicated commands in a row
setopt share_history            # Share command history across sessions

# Enable autocompletion
autoload -Uz compinit
compinit


# Create cache dir if missing
if [[ ! -d "${ZSH_CACHE_DIR}" ]]; then
  mkdir -p "${ZSH_CACHE_DIR}"
fi

source "${ZINIT_HOME}/bin/zinit.zsh"
source "${ZDOTDIR}/plugins.zsh"
# source "${ZDOTDIR}/bindings.zsh"

# To customize prompt, run `p10k configure` or edit ~/.config/zsh/.p10k.zsh.
[[ ! -f "${ZDOTDIR}/.p10k.zsh" ]] || source "${ZDOTDIR}/.p10k.zsh"

# Load aliases
for file in ${ZDOTDIR}/aliases/*; do
  source ${file}
done

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
