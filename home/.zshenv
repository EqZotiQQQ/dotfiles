export ZDOTDIR="${HOME}/.config/zsh"
export PATH="$PATH:${HOME}/.cargo/bin/cargo"

source "${HOME}/.cargo/env"

if [[ ! -d "${HOME}/git/hidden_env/sat_remote.sh" ]]; then
    source "${HOME}/git/hidden_env/sat_remote.sh"
fi

cvpn() {
    sudo openconnect https://vpn.sbauto.tech
}

fix_audio() {
    pulseaudio -k && sudo alsa force-reload
    pulseaudio --start
}
