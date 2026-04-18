function xephyr_run() {
    clear
    rm -rf ~/.config/awesome
    ./main.py -sfo
    Xephyr :2 -screen 1280x720 -ac -br -reset -terminate & sleep 1 && DISPLAY=:2 awesome
}