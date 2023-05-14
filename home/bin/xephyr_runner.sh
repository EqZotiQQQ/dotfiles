#!/bin/sh

nohup Xephyr :2 -name 'awesome-xephyr' -screen 1024x768 -br -reset -ac +xinerama > /dev/null 2>&1 & disown

sleep 0.5
DISPLAY=':2' exec awesome
