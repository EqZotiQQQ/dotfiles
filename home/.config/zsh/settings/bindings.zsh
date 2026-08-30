bindkey -e

# Basic line editing
bindkey "^A"    beginning-of-line
bindkey "^E"    end-of-line
bindkey "^U"    backward-kill-line
bindkey "^K"    kill-line
bindkey "^W"    backward-kill-word
bindkey "^L"    clear-screen
bindkey "^[[3~" delete-char

# Home / End keys
bindkey "^[[H"  beginning-of-line
bindkey "^[[F"  end-of-line

# Ctrl+Left / Ctrl+Right — beginning / end of line
bindkey "\e[1;5D" beginning-of-line
bindkey "\e[1;5C" end-of-line

# Shift+Alt+Left / Shift+Alt+Right — word movement
bindkey "\e[1;4D" backward-word
bindkey "\e[1;4C" forward-word

# Ctrl+Shift+Delete — delete to beginning of line
bindkey "^[[3;6~" backward-kill-line

# Ctrl+R — fzf history search (provided by ~/.fzf.zsh key-bindings)
# fzf key-bindings.zsh is sourced in .zshrc via ~/.fzf.zsh

# ↑/↓ — history-substring-search; биндятся в plugins.zsh через atload
