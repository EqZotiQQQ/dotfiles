bindkey -e

# Word movement stops at separators (/ - . _ etc.), not just whitespace
WORDCHARS=''

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

# Ctrl+Left / Ctrl+Right — word movement, stops at the next separator
bindkey "\e[1;5D" backward-word
bindkey "\e[1;5C" emacs-forward-word

# Ctrl+Shift+Left / Ctrl+Shift+Right — beginning / end of line
# (kitty on Linux sends Home / End for these instead, see kitty/linux.conf)
bindkey "\e[1;6D" beginning-of-line
bindkey "\e[1;6C" end-of-line

# Ctrl+Backspace / Ctrl+Delete — delete word backward / forward
bindkey "^H"      backward-kill-word
bindkey "\e[3;5~" kill-word

# Shift+Alt+Left / Shift+Alt+Right — word movement
bindkey "\e[1;4D" backward-word
bindkey "\e[1;4C" forward-word

# Alt+B / Alt+F — word movement (kitty sends these for Cmd+Left / Cmd+Right;
# Cmd+Shift+Left/Right send Home / End, bound above)
bindkey "\eb" backward-word
bindkey "\ef" forward-word

# Ctrl+Shift+Delete — delete to end of line
# (Ctrl+Shift+Backspace — delete to beginning of line: terminals send it as ^H,
# so kitty/linux.conf maps it to ^U)
bindkey "^[[3;6~" kill-line

# Ctrl+R — fzf history search (provided by ~/.fzf.zsh key-bindings)
# fzf key-bindings.zsh is sourced in .zshrc via ~/.fzf.zsh

# ↑/↓ — history-substring-search; биндятся в plugins.zsh через atload
