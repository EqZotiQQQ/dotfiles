zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*'  # регистр не важен, dl → Downloads
zstyle ':completion:*' menu no                      # меню показывает fzf-tab
zstyle ':completion:*:descriptions' format '[%d]'   # группы в fzf-tab
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$ZSH_CACHE_DIR/zcompcache"
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'