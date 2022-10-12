# When u have more then one audio device pulseaudio makes suicide
fix_audio() {
    pulseaudio -k && sudo alsa force-reload
    pulseaudio --start
    pactl set-default-sink 2
}

#  git clone "https://github.com/brendangregg/FlameGraph.git"
export FLAME_GRAPH_DIR="${HOME}/open_source/FlameGraph"

perf_app() {
    if [[ ! -d "${FLAME_GRAPH_DIR}" ]]; then
        git clone https://github.com/brendangregg/FlameGraph.git "${HOME}/open_source/FlameGraph"
    fi
    sudo perf record -v -F 997 -BNT -e cpu-clock --call-graph dwarf,65528 --clockid=monotonic_raw -o my_app_$1.perf -p $1 -- sleep 20

    sudo perf script -i my_app_$1.perf | ${FLAME_GRAPH_DIR}/stackcollapse-perf.pl | ${FLAME_GRAPH_DIR}/flamegraph.pl > ~/flame_$1.svg
}

function config_kitty_print() {
    # Displays not commented lines of kitty config
    grep -v '^[#;/%<]\|^\s*$' "${HOME}/.config/kitty/kitty.conf"
}
