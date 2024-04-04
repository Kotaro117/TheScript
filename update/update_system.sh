#!/bin/bash

VERSION="2.8.0"
RELEASE_FILE="/etc/os-release"
TIME_STAMP=$(date +"%d/%m/%Y %H:%M:%S")
# Define colour codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Colour
log=update_system.txt

mkdir -p logs # create log folder if not present
echo "" >> logs/$log # add a new line to make it easier to read

function exit_code() {
    if [ $? -eq 0 ]
    then
        echo -e "${GREEN}Update was successful $TIME_STAMP ${NC}"; echo "$TIME_STAMP Update was successful" >> logs/$log
    else
        echo -e "${RED}Update was not successful $TIME_STAMP ${NC}"; echo "$TIME_STAMP ERROR Update was not successful" >> logs/$log
    fi
}

echo -e "${YELLOW}running Version $VERSION of the script $TIME_STAMP ${NC}"; echo "$TIME_STAMP running Version $VERSION of the script" >> logs/$log

if grep -q "Arch" $RELEASE_FILE
then
    # The host is based on Arch, run the pacman update command
    echo -e "${YELLOW}The host is based on Arch $TIME_STAMP ${NC}"; echo "$TIME_STAMP The host is based on Arch" >> logs/$log        
    sudo pacman -Syu
    exit_code                                                               # Checks if the update was successful
elif
    echo -e "${YELLOW}The host is not based on Arch $TIME_STAMP ${NC}"; echo "$TIME_STAMP The host is not based on Arch" >> logs/$log
    grep -q "Debian" $RELEASE_FILE || grep -q "Ubuntu" $RELEASE_FILE || grep -q "Pop" $RELEASE_FILE # "||"=or
then
    # The host is based on Debian, Ubuntu or Pop
    # Run the apt version of the command
    echo -e "${YELLOW}The host is based on Debian $TIME_STAMP ${NC}"; echo "$TIME_STAMP The host is based on Debian" >> logs/$log
    sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y
    exit_code                                                               # Checks if the update was successful
else
    echo -e "${YELLOW}The host is not based on Debian $TIME_STAMP ${NC}"; echo "$TIME_STAMP The host is not based on Debian" >> logs/$log
fi
