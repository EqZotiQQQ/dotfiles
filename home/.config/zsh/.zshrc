#!/bin/zsh

# p10k instant prompt — must stay near the top
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export EDITOR="nvim"

export ZINIT_HOME="${ZDOTDIR}/zinit"
export ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/"
[[ ! -d "${ZSH_CACHE_DIR}" ]] && mkdir -p "${ZSH_CACHE_DIR}"

if [[ -z "$ZDOTDIR" ]]; then
  export ZDOTDIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"
fi

HISTFILE=~/.zsh_history

# команды с пробелом в начале не пишутся в историю
# история синхронизируется между сессиями
setopt APPEND_HISTORY HIST_IGNORE_DUPS SHARE_HISTORY HIST_IGNORE_SPACE

HISTSIZE=100000
SAVEHIST=100000

source "${ZDOTDIR}/settings/plugins.zsh"
source "${ZDOTDIR}/settings/bindings.zsh"

[[ ! -f "${ZDOTDIR}/settings/p10k.zsh" ]] || source "${ZDOTDIR}/settings/p10k.zsh"

for file in ${ZDOTDIR}/aliases/*; do
  source ${file}
done

[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh
