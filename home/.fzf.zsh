# Setup fzf
# ---------
if [[ ! "$PATH" == */home/eqzotiqqq/.fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/home/eqzotiqqq/.fzf/bin"
fi

source <(fzf --zsh)
