# bootstrap zinit if missing
if [[ ! -d "${ZINIT_HOME}/bin" ]]; then
  git clone https://github.com/zdharma-continuum/zinit.git "${ZINIT_HOME}/bin"
fi
source "${ZINIT_HOME}/bin/zinit.zsh"

# p10k — load synchronously so prompt is available immediately
zinit ice depth=1
zinit light "romkatv/powerlevel10k"

# misc plugins — load synchronously (lightweight)
zinit light "ael-code/zsh-colored-man-pages"
zinit light "RobertDeRose/virtualenv-autodetect"
(( $+commands[diff-so-fancy] )) && zinit light "z-shell/zsh-diff-so-fancy"
zinit light "xvoland/Extract"

# deferred plugins — loaded after first prompt
zinit wait lucid for \
  atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay" \
    zdharma-continuum/fast-syntax-highlighting \
  blockf \
    zsh-users/zsh-completions \
  atload"
    ZSH_AUTOSUGGEST_ACCEPT_WIDGETS=(forward-char end-of-line)
    ZSH_AUTOSUGGEST_USE_ASYNC=true
    ZSH_AUTOSUGGEST_STRATEGY=match_prev_cmd
    ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=vi-cmd-mode
    _zsh_autosuggest_start" \
    zsh-users/zsh-autosuggestions

zinit light zsh-users/zsh-syntax-highlighting

zinit wait lucid light-mode for \
  Aloxaf/fzf-tab

zinit light zsh-users/zsh-history-substring-search
