###########################
#  Fish-like suggestions  #
###########################
function zsh-autosuggestions-override() {
    # ignore commands in vi-mode
    ZSH_AUTOSUGGEST_ACCEPT_WIDGETS=(forward-char end-of-line)
    ZSH_AUTOSUGGEST_USE_ASYNC=true
    ZSH_AUTOSUGGEST_STRATEGY=match_prev_cmd
    ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=vi-cmd-mode
}
zinit ice lucid wait"0" atload"_zsh_autosuggest_start"

zinit light "zdharma-continuum/fast-syntax-highlighting"
zinit light "zsh-users/zsh-autosuggestions"
zinit light "romkatv/powerlevel10k"
zinit light "ael-code/zsh-colored-man-pages"
zinit light "RobertDeRose/virtualenv-autodetect"

zinit wait lucid for \
 atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay" \
    zdharma-continuum/fast-syntax-highlighting \
 blockf \
    zsh-users/zsh-completions \
 atload"!_zsh_autosuggest_start" \
    zsh-users/zsh-autosuggestions
