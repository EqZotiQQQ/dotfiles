#!/bin/bash

DOTFILES_DIR="$( cd "$( dirname "$0" )" && pwd )"

GREEN='\033[0;32m' # GREEN
RED='\033[0;31m' # RED
NC='\033[0m' # No Color

function update_symlinks() (
    shopt -s dotglob
    printf "Source:      ${RED}$1${NC}\n"
    printf "Destination: ${GREEN}$2${NC}\n"
    for item in $1/*; do
        if [[ -d "$item" ]]; then       # folder
            folder_name=$(echo $item | rev | cut -d'/' -f 1 | rev)
            echo "Item = $item"
            echo "Folder name = $folder_name"
            dist_folder="$2/$folder_name"
            if [ ! -d $dist_folder ]; then
                # printf "Folder ${RED}$dist_folder${NC} doesnt exist! Creating.\n"
                mkdir $dist_folder
            else 
                echo "Folder exists"
            fi
            update_symlinks $item $2/$folder_name
        elif [[ -f "$item" ]]; then     # file
            echo "$item -> $2/$(echo $item | rev | cut -d'/' -f 1 | rev)"
            destination="$2/$(echo $item | rev | cut -d'/' -f 1 | rev)"
            if [ ! -f $dist_folder ]; then
                # printf "Symlink for file: $item -> $destination\n"
                ln -sf $item $destination
            fi
        fi
    done
)

update_symlinks $DOTFILES_DIR/home $HOME