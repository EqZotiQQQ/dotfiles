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
    if [ "$host" = "innotek GmbH" ]
    then
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