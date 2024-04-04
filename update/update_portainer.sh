#!/bin/bash

VERSION="2.1.0"
TIME_STAMP=$(date +"%d/%m/%Y %H:%M:%S")
# Define colour codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Colour
log=update_portainer.txt

mkdir -p logs # create log folder if not present
echo "" >> logs/$log # add a new line to make it easier to read

function exit_code() {
    if [ $? -eq 0 ]
    then
        echo -e "${GREEN}$COMMAND was successfully $TIME_STAMP ${NC}"; echo "$TIME_STAMP $COMMAND was successful" >> logs/$log
    else
        echo -e "${RED}$COMMAND was not successful $TIME_STAMP ${NC}"; echo "$TIME_STAMP $COMMAND was not successful" >> logs/$log
    fi
}

echo -e "${YELLOW}running Version $VERSION of the script $TIME_STAMP ${NC}"; echo "$TIME_STAMP running Version $VERSION of the script" >> logs/$log

# Stop Portainer
COMMAND="Stopping of Portainer"
sudo docker stop portainer
exit_code

# Remove Portainer container
COMMAND="Removing of the Portainer container"
sudo docker rm portainer
exit_code

# Download the latest image of Portainer
COMMAND="Download of the latest image of Portainer"
sudo docker pull portainer/portainer-ce:latest
exit_code

# Deploy updated version of Portainer
COMMAND="Deploying of the updated version of Portainer"
sudo docker run -d -p 8000:8000 -p 9443:9443 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest
exit_code
