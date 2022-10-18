#!/bin/sh
# This script launch X.
# Launches window manager
# Launches apps on system start
# First of all xinit checks for a ~/.xinitrc.
# If file doesn't exists in home - executes default file in /var/X11R6/lib/xinit/xinitrc

. /etc/X11/xinit/xinitrc

exec awesome

# Setup home dual monitors
# todo make it flexible?
xrandr --output DP-2 --primary --mode 2560x1440 --rate 239.96 --output DP-0 --mode 1920x1080
