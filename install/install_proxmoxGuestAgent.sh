#!/bin/bash

VERSION="0.10"
PACKAGE_NAME="qemu-guest-agent"
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

echo -e "${YELLOW}running Version $VERSION of the script $TIME_STAMP ${NC}"

# Install Proxmox guest agent
COMMAND="Installatiom of the Proxmox guest agent"
if  dpkg -s "$PACKAGE_NAME" | grep "Status: install ok installed"
then
    echo -e "${YELLOW}$PACKAGE_NAME is allready installed $TIME_STAMP ${NC}"
else
    sudo apt-get install -y $PACKAGE_NAME
    exit_code
fi


# Start the agent
COMMAND="Starting of the agent"
sudo systemctl start $PACKAGE_NAME
exit_code

# enable the service to autostart (permanently) if not auto started
COMMAND="Enabling of the service"
sudo systemctl enable $PACKAGE_NAME
exit_code
