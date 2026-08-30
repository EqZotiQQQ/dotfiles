#!/bin/zsh

# (( $+commands[fzf] )) && source <(fzf --zsh)

if (( $+commands[fzf] )); then
  if fzf --zsh >/dev/null 2>&1; then
    source <(fzf --zsh)
  else
    # fzf < 0.48 has no --zsh flag; fall back to the shipped shell scripts
    for f in /usr/share/doc/fzf/examples/{key-bindings,completion}.zsh /usr/share/fzf/{key-bindings,completion}.zsh; do
      [[ -r "$f" ]] && source "$f"
    done
  fi
fi

