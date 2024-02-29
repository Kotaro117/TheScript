#!/bin/bash

VERSION="3.1"
TIME_STAMP=$(date +"%d/%m/%Y %H:%M:%S")
# Define colour codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Colour

function exit_code() {
    if [ $? -eq 0 ]
    then
        echo -e "${GREEN}User <$USER> has been added to the Docker group. Please log out and log back in for the changes to take effect. $TIME_STAMP ${NC}"
    else
        echo -e "${RED}User <$USER> has NOT been added to the Docker group. $TIME_STAMP ${NC}"
    fi
}

echo -e "${YELLOW}running Version $VERSION of the script $TIME_STAMP ${NC}"

if [ "$(groups | grep -c docker)" -eq 1 ]
then
    echo -e "${YELLOW}Your user <$USER> is allready a member of the docker group $TIME_STAMP ${NC}" 
else
    sudo usermod -aG docker $USER # Add current user to the docker group
    exit_code
fi
