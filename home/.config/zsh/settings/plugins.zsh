# load zinit or download if missing
export ZINIT_HOME="${ZDOTDIR}/zinit"
if [[ ! -a "${ZINIT_HOME}/bin/zinit.zsh" ]]; then
   git clone https://github.com/zdharma-continuum/zinit.git "${ZINIT_HOME}/bin"
fi

source "${ZINIT_HOME}/bin/zinit.zsh"

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

# -----------------------------------------
# 🧩 FZF integration (with key bindings and fuzzy history)
# -----------------------------------------
zinit ice lucid atload"source $HOME/.fzf.zsh"
zinit light junegunn/fzf

# # Optional: fzf-tab for enhanced completion UI
zinit ice depth=1 lucid
zinit light Aloxaf/fzf-tab
