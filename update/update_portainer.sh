#!/bin/bash

VERSION="1.1"
RELEASE_FILE="/etc/os-release"
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

# Stop Portainer
COMMAND="stop Portainer"
sudo docker stop portainer
exit_code

# Remove Portainer container
COMMAND="remove Portainer container"
sudo docker rm portainer
exit_code

# Download the latest image of Portainer
COMMAND="Download the latest image of Portainer"
sudo docker pull portainer/portainer-ce:latest
exit_code

# Deploy updated version of Portainer
COMMAND="Deploy updated version of Portainer"
sudo docker run -d -p 8000:8000 -p 9443:9443 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest
exit_code
