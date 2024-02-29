#!/bin/bash

# Define colour codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Colour


VERSION="2.7.5"
RELEASE_FILE="/etc/os-release"

function exit_code() {
    if [ $? -eq 0 ]
    then
        echo -e "${GREEN}Update was successful ${NC}"
    else
        echo -e "${RED}Update was not successful ${NC}"
    fi
}

echo -e "${YELLOW}running Version $VERSION ${NC}"

if grep -q "Arch" $RELEASE_FILE
then
    # The host is based on Arch, run the pacman update command
    sudo pacman -Syu
    exit_code                                                               # Checks if the update was successful
elif
    echo -e "${YELLOW}Host is not based on Arch ${NC}"
    grep -q "Debian" $RELEASE_FILE || grep -q "Ubuntu" $RELEASE_FILE || grep -q "Pop" $RELEASE_FILE # "||"=or
then
    # The host is based on Debian, Ubuntu or Pop
    # Run the apt version of the command
    sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y
    exit_code                                                               # Checks if the update was successful
else
    echo -e "${YELLOW}Host is not based on Debian ${NC}"
fi
