#!/bin/bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  #
# This file used on waybar modules sourcing defaults set in $HOME/.config/hypr/UserConfigs/01-UserDefaults.conf

$TERM &

# # Define the path to the config file
# config_file=$HOME/.config/hypr/details/00_defaults.conf

# # Check if the config file exists
# if [[ ! -f "$config_file" ]]; then
#     echo "Error: Configuration file not found!"
#     exit 1
# fi


# # Process the config file in memory, removing the $ and fixing spaces
# config_content=$(sed 's/\$//g' "$config_file" | sed 's/ = /=/')

# # Source the modified content directly from the variable
# eval "$config_content"

# # Check if $terminal is set correctly
# if [[ -z "$terminal" ]]; then
#     echo "Error: \$terminal is not set in the configuration file!"
#     echo "Error: \$terminal is not set in the configuration file!" > ~/log.txt
#     exit 1
# fi

# # Execute accordingly based on the passed argument
# if [[ "$1" == "--btop" ]]; then
#     # $terminal --title btop sh -c 'btop'
#     $terminal sh -c 'btop'
# elif [[ "$1" == "--nvtop" ]]; then
#     # $terminal --title nvtop sh -c 'nvtop'
#     $terminal sh -c 'nvtop'
# elif [[ "$1" == "--nmtui" ]]; then
#     # $terminal nmtui
# elif [[ "$1" == "--terminal" ]]; then
#     echo "launch term" > ~/log.txt
#     $terminal &
# else
#     echo "Usage: $0 [--btop | --nvtop | --nmtui | --terminal]"
#     echo "--btop       : Open btop in a new terminal"
#     echo "--nvtop      : Open nvtop in a new terminal"
#     echo "--nmtui      : Open nmtui in a new terminal"
#     echo "--terminal   : Launch a term window"
# fi
