#!/bin/bash


########################
### Variable section ###
########################

VERSION="0.4.1"
TIME_STAMP=$(date +"%d/%m/%Y %H:%M:%S")
# Define colour codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Colour
log=logs/install_flatpak.txt


########################
### Function section ###
########################

function exit_code() {
    if [ $? -eq 0 ]
    then
        echo -e "${GREEN}$COMMAND was successfully ${NC}"
        echo "$COMMAND was successful" >> $log
        INSTALLED=yes
    else
        echo -e "${RED}$COMMAND was not successful ${NC}"
        echo "ERROR $COMMAND was not successful" >> $log
        INSTALLED=ERROR
    fi
}

###############################
### Beginning of the script ###
###############################

mkdir -p logs # create log folder if not present
echo "" >> $log # add a new line to make it easier to read

echo -e "${YELLOW}Running Version $VERSION of the script $TIME_STAMP ${NC}"
echo "$TIME_STAMP Running Version $VERSION of the script" >> $log

echo -e "${YELLOW}This only works on Ubuntu 18.10 or higher ${NC}"
sleep 5

if [ -f /etc/os-release ] && grep -q "^ID=ubuntu" /etc/os-release
then
    echo "The OS is Ubuntu" >> $log
else
    echo -e "${RED}The OS is not Ubuntu ${NC}"
    echo "The OS is not Ubuntu" >>$log
    echo -e "${YELLOW}Check $log for any errors ${NC}"
    exit 1
fi

if command -v flatpak &> /dev/null
then
    echo -e "${GREEN}Flatpak is already installed ${NC}"
    echo "Flatpak is already installed" >> $log
    echo -e "${YELLOW}Check $log for any errors ${NC}"
else
    # Install Flatpak
    echo -e "${YELLOW}Installing flatpak ${NC}"
    echo "Installing flatpak" >> $log
    COMMAND="Install flatpak"
    sudo apt install -y flatpak 
    exit_code
fi

# Install the Software Flatpak plugin
if dpkg -l | grep -q "gnome-software-plugin-flatpak"
then 
    echo "gnome-software-plugin-flatpak is already installed" >> $log
else
    echo -e "${YELLOW}Installing Software Flatpak plugin ${NC}"
    echo "Installing Software Flatpak plugin" >> $log
    COMMAND="Install gnome-software-plugin-flatpak"
    sudo apt install -y gnome-software-plugin-flatpak
    exit_code
fi

# Add the Flathub repository
# Flathub is the best place to get Flatpak apps.
if flatpak remote-list | grep -q "flathub"
then
    echo -e "${YELLOW}Flatpak repository has already been added ${NC}"
    echo "Flatpak repository has already been added" >> $log
else
    echo -e "${YELLOW}Adding Flatpak repository ${NC}"
    echo "Adding Flatpak repository" >> $log
    COMMAND="Add Flathub repository"
    sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    exit_code
fi

# Restart
if [ "$INSTALLED" == "yes" ]
then 
    read -p "To complete setup, restart your system. Do you want to restart your System? (y/n): " do_restart
    if [ "$do_restart" == "y" ]
    then
        echo "User has chosen to restart" >> $log
        reboot
    else
        echo "User has chosen not to restart" >> $log
    fi
elif [ "$INSTALLED" == "ERROR" ]
then
    echo -e "${RED}An error during installation occurred, please check the log > $log ${NC}"
    echo "An error during installation occurred" >> $log
else
    echo "No restard needed" >> $log
fi