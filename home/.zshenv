export ZDOTDIR="$HOME/.config/zsh"

gclone() {
    git clone "https://github.com/$1/$2"
}

gcme() {
    git clone "https://github.com/eqzotiqqq/$1"
}

source "$HOME/.cargo/env"

config_git() {
    git config user.name "Mikhail Fedyakov"
    git config user.email "fedyakovmikael@gmail.com"
}