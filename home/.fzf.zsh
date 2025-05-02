# Setup fzf
# ---------
if [[ ! "$PATH" == "*/${FZF}/.fzf/bin*" ]]; then
  PATH="${PATH:+${PATH}:}/${FZF}/.fzf/bin"
fi

source <(fzf --zsh)
