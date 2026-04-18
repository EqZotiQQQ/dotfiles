#!/usr/bin/env bash
# lock_screen.sh — lock via hyprlock (idempotent)
pidof hyprlock || hyprlock
