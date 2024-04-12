#!/bin/bash

VERSION="0.2.0"
TIME_STAMP=$(date +"%d/%m/%Y %H:%M:%S")
# Define colour codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Colour
log=logs/install_yaru.txt


###############################
### BEGINNING OF THE SCRIPT ###
###############################

mkdir -p logs # create log folder if not present
echo "" >> $log # add a new line to make it easier to read
echo -e "${YELLOW}running Version $VERSION of the script $TIME_STAMP ${NC}"
echo "$TIME_STAMP running Version $VERSION of the script" >> $log

sudo apt install -y yaru-theme-gnome-shell yaru-theme-gtk yaru-theme-icon yaru-theme-sound gnome-tweaks

read -p "Do you want to install Ubuntu session too? (y/n): " answer
if [ "$answer" == "y" ]
then
    echo "User has chosen to install ubuntu-session" >> $log
    sudo apt install -y ubuntu-session
    echo -e "${YELLOW}In order to use ubuntu session log out, click on the cog and choose ubuntu ${NC}"
    read -p "Do you want to log out? (y/n): " log_out
    if [ "$log_out" == "y" ]
    then
        echo "User has chosen to log out" >> $log
        gnome-session-quit --logout --no-prompt
    else
        echo "User has chosen not to log out" >> $log
    fi
else
    echo "User has chosen not to install ubuntu-session" >> $log
fi
