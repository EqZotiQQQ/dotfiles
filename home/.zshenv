#!/bin/zsh

source "${HOME}/.local/share/zinit/plugins/RobertDeRose---virtualenv-autodetect/virtualenv-autodetect.sh"

if [ -d "${HOME}/shared" ]; then
    for file in ${HOME}/shared/*; do
        source $file
    done
fi
