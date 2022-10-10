export ZDOTDIR="${HOME}/.config/zsh"

export PATH="$PATH:${HOME}/.cargo/bin/cargo"
export PATH="$PATH:${HOME}/open_source/emsdk"
export PATH="$PATH:${HOME}/open_source/emsdk/node/14.18.2_64bit/bin"
export PATH="$PATH:${HOME}/open_source/emsdk/node/14.18.2_64bit/bin"

[ -f ~/.fzf.bash ] && source ~/.fzf.bash


source "${HOME}/.cargo/env"

# alias helper
# https://github.com/djui/alias-tips
source "${HOME}/open_source/alias-tips/alias-tips.plugin.zsh"
export ZSH_PLUGINS_ALIAS_TIPS_TEXT="Alias tip: "

if [[ ! -d "${HOME}/git/hidden_env/sat_remote.sh" ]]; then
    source "${HOME}/git/hidden_env/sat_remote.sh"
fi

fix_audio() {
    pulseaudio -k && sudo alsa force-reload
    pulseaudio --start
    pactl set-default-sink 2
}

perf_app() {
    sudo perf record -v -F 997 -BNT -e cpu-clock --call-graph dwarf,65528 --clockid=monotonic_raw -o ~/my_app_$1.perf -p $1 -- sleep 10

    sudo perf script -i ~/my_app_$1.perf | /home/mikhail/open_source/FlameGraph/stackcollapse-perf.pl | /home/mikhail/open_source/FlameGraph/flamegraph.pl > flame_$1.svg
}

# pactl list short sink # Show audio devices
# pactl set-default-sink 2

source emsdk_env.sh
clear
