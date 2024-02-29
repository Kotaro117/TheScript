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

# Create the volume that Portainer Server will use to store its database
COMMAND="Creation of the Portainer volume"
if [ ! -d /var/lib/docker/volumes/portainer_data ]
then
    sudo docker volume create portainer_data
    exit_code
else
    echo -e "${YELLOW}Volume has not been created because it's allready there $TIME_STAMP ${NC}"
fi

# Download and install the Portainer Server container
COMMAND="Creation and installation of the Portainer Server container"
sudo docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest
exit_code
