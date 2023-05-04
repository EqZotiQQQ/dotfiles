#!/bin/zsh
#
plugins=(virtualenv)

POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status virtualenv)

source "${HOME}/.local/share/zinit/plugins/RobertDeRose---virtualenv-autodetect/virtualenv-autodetect.sh"

if [ -d "${HOME}/shared" ]; then
    for file in ${HOME}/shared/*; do
        source $file
    done
fi
