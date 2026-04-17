#!/bin/zsh

# Homebrew (macOS)
# eval "$(/opt/homebrew/bin/brew shellenv)"

# ssh-agent
if [ -z "$SSH_AUTH_SOCK" ]; then
    eval "$(ssh-agent -s)" > /dev/null
fi

# Инициализация менеджеров версий (тяжёлые)
# eval "$(rbenv init - zsh)"
