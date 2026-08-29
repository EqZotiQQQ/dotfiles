#!/bin/zsh

# p10k instant prompt — must stay near the top
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export EDITOR="nvim"

export ZINIT_HOME="${ZDOTDIR}/zinit"
export ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/"
[[ ! -d "${ZSH_CACHE_DIR}" ]] && mkdir -p "${ZSH_CACHE_DIR}"

HISTFILE="${XDG_STATE_HOME}/zsh/history"
[[ -d ${HISTFILE:h} ]] || mkdir -p ${HISTFILE:h}
HISTSIZE=100000
SAVEHIST=100000

setopt SHARE_HISTORY          # история общая между сессиями
setopt EXTENDED_HISTORY       # писать таймстампы
setopt HIST_IGNORE_ALL_DUPS   # не хранить повторы
setopt HIST_IGNORE_SPACE      # команда с пробела не попадает в историю
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY            # показать подстановку !! перед выполнением

source "${ZDOTDIR}/settings/plugins.zsh"
source "${ZDOTDIR}/settings/bindings.zsh"

[[ ! -f "${ZDOTDIR}/settings/p10k.zsh" ]] || source "${ZDOTDIR}/settings/p10k.zsh"

for file in ${ZDOTDIR}/aliases/*; do
  source ${file}
done

[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh
