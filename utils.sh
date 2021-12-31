
GREEN='\033[0;32m' # GREEN
RED='\033[0;31m' # RED
NC='\033[0m' # No Color

function package_installed() {
    STATUS=$(dpkg-query -W --showformat='${Status}\n' $1|grep "install ok installed")
    if [ "$STATUS" = "" ]; then
        echo "No $1"
    else 
        echo "$1 installed"
    fi
}

function is_vm() {
    host=`sudo dmidecode -s system-manufacturer`
    if [ "$host" = "innotek GmbH" ]; then
        echo "1"
    else
        echo "0"
    fi
}

function get_ubuntu_version() {
    version=$(cat /etc/lsb-release | grep DISTRIB_RELEASE | cut -d'=' -f 2)
    if [ "$version" = "20.04" ]; then
        echo "20"
    else
        echo "18"
    fi
}

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

function install_app() {
    cd ~
    status=$(package_installed $1)
    echo "status = $status"
    if [ "$status" = "$1 installed" ]; then
        printf "${GREEN}Package $1 already installed${NC}\n"
    else
        printf "${RED}Install $1${NC}\n"
        sudo apt install -y $1
    fi
}
