#!/bin/bash


########################
### Variable section ###
########################

VERSION="2.10.0"
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
else
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
fi

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

# Add user to the Docker group
$INSATALL_PATH/./docker_groupAdd.sh