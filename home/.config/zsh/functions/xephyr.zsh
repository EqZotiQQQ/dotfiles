function xephyr_run_awesome() {
    Xephyr :2 -screen 1280x720 -ac -br -reset -terminate &
}

function xephyr_export_awesome() {
    DISPLAY=:2 awesome
}
