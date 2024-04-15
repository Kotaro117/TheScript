#!/bin/bash


########################
### Variable section ###
########################

VERSION="2.9.0"
RELEASE_FILE="/etc/os-release"
TIME_STAMP=$(date +"%d/%m/%Y %H:%M:%S")
# Define colour codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Colour
log=log/update_system.txt


########################
### Function section ###
########################

function exit_code() {
    if [ $? -eq 0 ]
    then
        echo -e "${GREEN}Update of the $COMMAND was successful $TIME_STAMP ${NC}"
        echo "Update of the $COMMAND was successful" >> $log
    else
        echo -e "${RED}Update of the $COMMAND was not successful $TIME_STAMP ${NC}"
        echo "ERROR Update of the $COMMAND was not successful" >> $log
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

if grep -q "Arch" $RELEASE_FILE
then
    # The host is based on Arch, run the pacman update command
    echo "The host is based on Arch" >> $log  
    COMMAND="Arch system"      
    sudo pacman -Syu
    exit_code                                                               # Checks if the update was successful
elif
    echo "The host is not based on Arch" >> $log
    grep -q "Debian" $RELEASE_FILE || grep -q "Ubuntu" $RELEASE_FILE || grep -q "Pop" $RELEASE_FILE     # "||"=or
then
    # The host is based on Debian, Ubuntu or Pop
    # Run the apt version of the command
    echo "The host is based on Debian" >> $log
    COMMAND="Debian system"
    sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y
    exit_code                                                               # Checks if the update was successful
else
    echo "The host is not based on Debian" >> $log
fi

# Check if the OS is Fedora
if [ -f /etc/fedora-release ]
then
    # OS is Fedora, proceed to update
    echo "The host is based on Fedroa" >> $log
    COMMAND="Fedora system"      
    sudo dnf upgrade
    exit_code
else
    # OS is not Fedora, print an error message
    echo "The host is not based on Fedroa" >> $log
fi

# Check if the 'snap' command is available
if command -v snap &> /dev/null
then
    echo "Snap is installed" >> $log
    # 'snap' command is available, proceed to update Snap packages
    COMMAND="Snap packages"
    sudo snap refresh
    exit_code
else
    echo "Snap is not installed" >> $log
fi

# Check if the 'flatpak' command is available
if command -v flatpak &> /dev/null
then
    echo "Flatpak is installed" >> $log
    # 'flatpak' command is available, proceed to update Flatpak packages
    COMMAND="Flatpak packages"
    sudo flatpak update
    exit_code
else
    echo "Flatpak is not installed" >> $log
fi




