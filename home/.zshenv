#!/bin/zsh

if [ -d "${HOME}/shared" ]; then
    for file in ${HOME}/shared/*; do
        source $file
    done
fi
