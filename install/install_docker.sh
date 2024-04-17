#!/bin/bash


########################
### Variable section ###
########################

VERSION="2.11.0"
TIME_STAMP=$(date +"%d/%m/%Y %H:%M:%S")
# Define colour codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Colour
INSATALL_PATH="install"
log=logs/install_docker.txt


########################
### Function section ###
########################

function check_dependency() {
    command -v $1 >/dev/null 2>&1 || {
        echo -e "${YELLOW}$1 is required but not installed. Would you like to install it? $TIME_STAMP ${NC}"
        echo "$1 is required but not installed. Would you like to install it?" >> $log
        read -p "Install $1? (y/n): " answer
        if [ "$answer" == "y" ] 
        then
            echo "User chosed "y"" >> $log
            sudo apt-get install -y $1
        else
            echo "User chosed "n"" >> $log
            echo "Aborting"
            exit 1
        fi
    }
}

function fedora_install() {
    echo "Host is based on Fedora" >> $log
    # Uninstall old versions
    echo "Uninstalling old versions" >> $log
    sudo dnf remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-selinux docker-engine-selinux docker-engine
    # Set up the repository
    echo "Setting up the repository" >> $log
    sudo dnf -y install dnf-plugins-core
    sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
    # Install Docker Engine (latest)
    echo "Installing Docker Engine (latest)" >> $log
    sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    # Start Docker
    echo "Starting Docker" >> $log
    sudo systemctl start docker
}

function ubuntu_install() {
    # Uninstall all conflicting packages
    for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg -y; done

    # Add Docker's official GPG key:
    echo "Adding Docker's official GPG key" >> $log
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl gnupg
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg

    # Add the repository to Apt sources:
    echo "Adding the repository to Apt sources" >> $log
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release
    echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update

    # Install the latest Docker packages
    echo "Installing Docker" >> $log
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
}

function deploy_portainer() {
    # Asks to deploy Portainer
    read -p "Do you want to deploy the Portainer container? (y/n): " portainer
    if [ "$portainer" == "y" ]
    then
        echo "User has chosen to deploy Portainer" >> $log
        mkdir -p install                               # creates the necessary folder if it's not allready present
        if [ ! -f install/deploy_portainer.sh ]        # checks if the script is not present  
        then
            wget -O "install/deploy_portainer.sh" https://raw.githubusercontent.com/Kotaro117/TheScript/main/install/deploy_portainer.sh && chmod +x install/deploy_portainer.sh
        fi
        install/./deploy_portainer.sh
    else
        echo "User has chosen not to deploy Portainer" >> $log
    fi
}


###############################
### Beginning of the script ###
###############################

mkdir -p logs # create log folder if not present
echo "" >> $log # add a new line to make it easier to read

echo -e "${YELLOW}running Version $VERSION of the script $TIME_STAMP ${NC}"
echo "$TIME_STAMP running Version $VERSION of the script" >> $log

echo "Scripts is executed by $USER" >> $log
groups | grep -q '\bsudo\b' && echo "User has sudo permissions" >> $log || echo "User does not have sudo permissions" >> $log

if [ ! -f $INSATALL_PATH/docker_groupAdd.sh ]
then
    wget -O "$INSATALL_PATH/docker_groupAdd.sh" https://raw.githubusercontent.com/Kotaro117/TheScript/main/install/docker_groupAdd.sh && chmod +x $INSATALL_PATH/docker_groupAdd.sh
fi

if command -v docker
then
    echo -e "${YELLOW} Docker is allready installed $TIME_STAMP ${NC}"
    echo "Docker is allready installed" >> $log
    deploy_portainer
    # Add user to the Docker group
    $INSATALL_PATH/./docker_groupAdd.sh
    exit 1
fi

# Check if the OS is Fedora
if [ -f /etc/fedora-release ]
then
    fedora_install
elif grep -q "Ubuntu" /etc/os-release # Check if the OS is Ubuntu
then
    ubuntu_install
fi

deploy_portainer

# Add user to the Docker group
$INSATALL_PATH/./docker_groupAdd.sh