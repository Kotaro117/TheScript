#!/bin/bash


########################
### Variable section ###
########################

VERSION="2.4"
TIME_STAMP=$(date +"%d/%m/%Y %H:%M:%S")
# Define colour codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Colour
log=logs/deploy_portainer.txt


########################
### Function section ###
########################

function exit_code() {
    if [ $? -eq 0 ]
    then
        echo -e "${GREEN}$COMMAND was successfully $TIME_STAMP ${NC}"
        echo "$TIME_STAMP $COMMAND was successful" >> $log
    else
        echo -e "${RED}$COMMAND was not successful $TIME_STAMP ${NC}"
        echo "$TIME_STAMP ERROR $COMMAND was not successful" >> $log
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

# Create the volume that Portainer Server will use to store its database
COMMAND="Creation of the Portainer volume"
if [ ! -d /var/lib/docker/volumes/portainer_data ]
then
    sudo docker volume create portainer_data
    exit_code
else
    echo -e "${YELLOW}Volume has not been created because it's allready there $TIME_STAMP ${NC}"
    echo "Volume has not been created because it's allready there" >> $log
fi

# Download and install the Portainer Server container
COMMAND="Creation and installation of the Portainer Server container"
sudo docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest
exit_code
