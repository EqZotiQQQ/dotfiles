#!/usr/bin/env bash

EWW_WINDOWS=(bar bar2 square)

start() {
    eww daemon
    eww open-many "${EWW_WINDOWS[@]}"
}

stop() {
    eww kill
}

restart() {
    stop
    sleep 0.3
    start
}

case "$1" in
    start)   start ;;
    stop)    stop ;;
    restart) restart ;;
    *)
        echo "Usage: $(basename "$0") {start|stop|restart}"
        exit 1
        ;;
esac
