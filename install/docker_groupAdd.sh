#!/bin/bash

VERSION="V 2.2"
TITLE="Docker permission $VERSION"

# Check for dependencies (Whiptail)
command -v whiptail >/dev/null 2>&1 || { 
    echo >&2 "whiptail is required but not installed. Would you like to install it?";
    read -p "Install whiptail? (y/n): " answer
        if [ "$answer" == "y" ]; then
        sudo apt-get update
        sudo apt-get install -y whiptail
    else
        echo "Aborting."
        exit 1
    fi
}

if [ "$(groups | grep -c docker)" -eq 1 ]
then
    whiptail --title "$TITLE" --msgbox "Your user <$USER> is allready a member of the docker group" 8 60
else
    whiptail --title "$TITLE" --yesno "Do you want to add your user <$USER> to the Docker group?" 8 60
            if [ $? -eq 0 ]; then
                sudo usermod -aG docker $USER # Add current user to the docker group
                whiptail --title "$TITLE" --msgbox "User has been added to the Docker group. Please log out and log back in for the changes to take effect." 8 60
            else
                whiptail --title "$TITLE" --msgbox "User has not been added to the Docker group" 8 60
            fi
fi