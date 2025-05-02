# Use emacs keybindings (default in most terminals)
bindkey -e

# Ctrl+L — clear screen
bindkey "^L" clear-screen


# -----------------------------------------
# 🎹 Keyboard Bindings
# -----------------------------------------

# Line navigation

# Ctrl+A / Ctrl+E — move to beginning/end of line
# Ctrl+U         — delete to beginning
# Ctrl+K         — delete to end
# Ctrl+W         — delete word backward
# Alt+F / Alt+B  — move forward/backward one word

bindkey "^A" beginning-of-line
bindkey "^E" end-of-line
bindkey "^U" backward-kill-line
bindkey "^K" kill-line
bindkey "^W" backward-kill-word

# Word movement with Ctrl+Left / Ctrl+Right (xterm compatible)
bindkey "\e[1;5D" backward-word
bindkey "\e[1;5C" forward-word


# -----------------------------------------
# 🔍 Fuzzy History Search (fzf)
# -----------------------------------------

# Define fuzzy history widget
fzf-history-widget() {
  BUFFER=$(history -n 1 | tac | fzf --height 40% --reverse --border --tiebreak=index --no-sort)
  CURSOR=$#BUFFER
  zle redisplay
}
zle -N fzf-history-widget

# Bind Alt+H to fuzzy history
# bindkey '^[h' fzf-history-widget  # Alt+H

# Ctrl+R — fzf search (if fzf installed)
if (( $+commands[fzf] )); then
  bindkey '^R' fzf-history-widget

  # Load fzf key bindings if installed via git
  [[ -f ~/.fzf/shell/key-bindings.zsh ]] && source ~/.fzf/shell/key-bindings.zsh
fi


# Ctrl+⬅️ / Ctrl+➡️ Move by word
bindkey "^[[1;4D"  beginning-of-line   # Ctrl+Left  -> to start of line
bindkey "^[[1;4C"  end-of-line         # Ctrl+Right  -> to end of line


bindkey "^\e[1;5C" forward-word        # Shift+Alt+Right  -> forward word
bindkey "^\e[1;5D" backward-word       # Shift+Alt+Left -> bacward word

bindkey "^[[3;6~" backward-kill-line   # Ctrl + Shift + Delete -> delete line

