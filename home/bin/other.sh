# When u have more then one audio device pulseaudio makes suicide
fix_audio() {
    pulseaudio -k && sudo alsa force-reload
    pulseaudio --start
    pactl set-default-sink 2
}
