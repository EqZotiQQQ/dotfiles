setopt auto_pushd pushd_ignore_dups pushdminus auto_cd

alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'
alias -g ......='../../../../..'

alias -- -='cd -'
alias 1='cd -'
alias 2='cd -2'
alias 3='cd -3'
alias 4='cd -4'
alias 5='cd -5'
alias 6='cd -6'
alias 7='cd -7'
alias 8='cd -8'
alias 9='cd -9'

alias md='mkdir -p'
alias rd='rmdir'
alias d='dirs -v | head -10'

alias l='ls --long --all --group'
alias ll='ls --long'
alias la='ls --long --almost-all'
alias lsa='ls --long --all --group --header'

if (( $+commands[eza] )); then
  alias ls='eza --group-directories-first'
  alias l='eza -la --group --header'
  alias ll='eza -l'
  alias la='eza -la'
else
  alias ls='ls --color=auto'
  alias l='ls -lAh'
  alias ll='ls -lh'
  alias la='ls -lAh'
fi
