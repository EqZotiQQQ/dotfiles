export ZDOTDIR="${HOME}/.config/zsh"
export PATH="$PATH:${HOME}/.cargo/bin/cargo"

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

source "${HOME}/.cargo/env"
if [[ ! -d "${HOME}/git/hidden_env/sat_remote.sh" ]]; then
    source "${HOME}/git/hidden_env/sat_remote.sh"
fi

fix_audio() {
    pulseaudio -k && sudo alsa force-reload
    pulseaudio --start
}
