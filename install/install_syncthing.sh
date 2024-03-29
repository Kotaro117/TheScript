#!/bin/bash

VERSION="2.1"
TIME_STAMP=$(date +"%d/%m/%Y %H:%M:%S")
# Define colour codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Colour


function exit_code() {
    if [ $? -eq 0 ]
    then
        echo -e "${GREEN}$COMMAND was successful $TIME_STAMP ${NC}"
    else
        echo -e "${RED}$COMMAND was not successful $TIME_STAMP ${NC}"
    fi
}

function check_dependency() {                                                   # Check for dependencies
    command -v $1 >/dev/null 2>&1 || {
        echo "$1 is required but not installed. Would you like to install it?"
        read -p "Install $1? (y/n): " answer
        if [ "$answer" == "y" ] 
        then
            sudo apt-get update && sudo apt-get install -y $1
        else
            echo "Aborting"
            exit 1
        fi
    }
}

echo -e "${YELLOW}running Version $VERSION of the script $TIME_STAMP ${NC}"

check_dependency curl

# Add the release PGP keys:
COMMAND="Adding of the relase PGP keys"
sudo mkdir -p /etc/apt/keyrings
sudo curl -L -o /etc/apt/keyrings/syncthing-archive-keyring.gpg https://syncthing.net/release-key.gpg
exit_code

# Add the "stable" channel to your APT sources:
COMMAND="Adding the stable channel to the APT sources"
echo "deb [signed-by=/etc/apt/keyrings/syncthing-archive-keyring.gpg] https://apt.syncthing.net/ syncthing stable" | sudo tee /etc/apt/sources.list.d/syncthing.list
exit_code

# Update and install syncthing:
COMMAND="Installing Syncthing"
sudo apt-get update
sudo apt-get -y install syncthing
exit_code