# When u have more then one audio device pulseaudio makes suicide
pulseaudio -k && sudo alsa force-reload
pulseaudio --start
pactl set-default-sink 2
