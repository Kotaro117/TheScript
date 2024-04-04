#!/bin/bash

VERSION="2.7.2"
TIME_STAMP=$(date +"%d/%m/%Y %H:%M:%S")
# Define colour codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Colour
INSATALL_PATH="install"

function check_dependency() {
    command -v $1 >/dev/null 2>&1 || {
        echo "$1 is required but not installed. Would you like to install it?"
        read -p "Install $1? (y/n): " answer
        if [ "$answer" == "y" ] 
        then
            sudo apt-get install -y $1
        else
            echo "Aborting"
            exit 1
        fi
    }
}

# Check for dependencies (Whiptail)
check_dependency whiptail
if [ ! -f $INSATALL_PATH/docker_groupAdd.sh ]
then
    wget -O "$INSATALL_PATH/docker_groupAdd.sh" https://raw.githubusercontent.com/Kotaro117/TheScript/main/install/docker_groupAdd.sh && chmod +x $INSATALL_PATH/docker_groupAdd.sh
fi

if command -v docker
then
    echo -e "${YELLOW} Docker is allready installed $TIME_STAMP ${NC}"
    $INSATALL_PATH/./docker_groupAdd.sh 
else
    # Uninstall all conflicting packages
    for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg -y; done

    # Add Docker's official GPG key:
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl gnupg
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg

    # Add the repository to Apt sources:
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release
    echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update

    # Install the latest Docker packages
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # Verify that the Docker Engine installation is successful by running the hello-world image.
    sudo docker run hello-world

    # Add user to the docker group
    $INSATALL_PATH/./docker_groupAdd.sh 
fi