#!/bin/bash


########################
### Variable section ###
########################

VERSION="1.3.4"
PACKAGE_NAME="qemu-guest-agent"
TIME_STAMP=$(date +"%d/%m/%Y %H:%M:%S")
# Define colour codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Colour
log=logs/install_proxmoxGuestAgent.txt


########################
### Function section ###
########################

function exit_code() {
    if [ $? -eq 0 ]
    then
        echo -e "${GREEN}$COMMAND was successfully ${NC}"
        echo "$COMMAND was successful" >> $log
    else
        echo -e "${RED}$COMMAND was not successful ${NC}"
        echo "$COMMAND was not successful" >> $log
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

# Install Proxmox guest agent
COMMAND="Installation of the Proxmox guest agent"
if  dpkg -s "$PACKAGE_NAME" &> /dev/null || yum list installed | grep -q "$PACKAGE_NAME" &> /dev/null             # Checks if the guest agent is installed 
then
    echo -e "${YELLOW}$PACKAGE_NAME is already installed ${NC}"
    echo "$PACKAGE_NAME is already installed" >> $log
else
    if command -v apt &> /dev/null
    then
        echo "apt as a package manager is installed" >> $log
        sudo apt-get install -y $PACKAGE_NAME
        exit_code
    elif command -v yum &> /dev/null
    then
        echo "yum as a package manager is installed" >> $log
        sudo yum install -y qemu-guest-agent
        exit_code
    fi
fi

# Start the agent
COMMAND="Starting of the agent"
sudo systemctl start $PACKAGE_NAME
exit_code

# enable the service to autostart (permanently) if not auto started
COMMAND="Enabling of the service"
sudo systemctl enable $PACKAGE_NAME
exit_code
