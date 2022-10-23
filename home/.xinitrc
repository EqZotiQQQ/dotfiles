#!/bin/sh
# This script launch X.
# Launches window manager
# Launches apps on system start
# First of all xinit checks for a ~/.xinitrc.
# If file doesn't exists in home - executes default file in /var/X11R6/lib/xinit/xinitrc

. /etc/X11/xinit/xinitrc

# exec picom&

exec awesome

# Setup home dual monitors
# todo make it flexible?

