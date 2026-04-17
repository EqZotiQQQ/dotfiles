#!/bin/bash

set -e

# usage:
# kitty_conf

grep -v '^[#;/%<]\|^\s*$' "${HOME}/.config/kitty/kitty.conf"
