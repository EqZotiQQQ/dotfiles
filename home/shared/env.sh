#!/bin/bash

# Rust init
[ -d "${HOME}/.cargo/bin" ] && export PATH="${HOME}/.cargo/bin:${PATH}"
[ -d "${HOME}/.cargo/bin/cargo" ] && export PATH="$PATH:${HOME}/.cargo/bin/cargo"
[ -d "${HOME}/.cargo/env" ] && source "${HOME}/.cargo/env"

# C++
if [[ -f /usr/bin/clang++ ]]; then
    export CXX="/usr/bin/clang++"
    export CC="/usr/bin/clang"
fi

# Add public apps to PATH
[ -d "${HOME}/bin" ] && export PATH="${HOME}/bin:${PATH}"

# Add private apps to PATH
[ -d "${HOME}/.local/bin" ] && export PATH="${HOME}/.local/bin:${PATH}"

# EMSDK for webassembly C++
if [[ -d "${HOME}/open_source/emsdk" ]]; then
    export PATH="${PATH}:${HOME}/open_source/emsdk"
    export PATH="${PATH}:${HOME}/open_source/emsdk/node/14.18.2_64bit/bin"
fi

# FZF
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# Super-duper-secret-things
[ -d "${HOME}/git/hidden_env" ] && source "${HOME}/git/hidden_env/sat_remote.sh"
