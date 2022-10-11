export ZDOTDIR="${HOME}/.config/zsh"

if [[ -d "${HOME}/.cargo/bin/cargo" ]]; then
    export PATH="$PATH:${HOME}/.cargo/bin/cargo"
fi

if [[ -d "${HOME}/open_source/emsdk" ]]; then
    export PATH="$PATH:${HOME}/open_source/emsdk"
    export PATH="$PATH:${HOME}/open_source/emsdk/node/14.18.2_64bit/bin"
    export PATH="$PATH:${HOME}/open_source/emsdk/node/14.18.2_64bit/bin"
fi

[ -f ~/.fzf.bash ] && source ~/.fzf.bash


if [[ -d "${HOME}/.cargo/env" ]]; then
    source "${HOME}/.cargo/env"
fi


# alias helper
# https://github.com/djui/alias-tips
if [[ -d "${HOME}/open_source/alias-tips" ]]; then
    source "${HOME}/open_source/alias-tips/alias-tips.plugin.zsh"
    export ZSH_PLUGINS_ALIAS_TIPS_TEXT="Alias tip: "
else
    echo "No alias-tips plugin found"
fi

# Super sercret things
if [[ ! -d "${HOME}/git/hidden_env" ]]; then
    source "${HOME}/git/hidden_env/sat_remote.sh"
fi

