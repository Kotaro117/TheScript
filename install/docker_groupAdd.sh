#!/bin/bash


########################
### Variable section ###
########################

VERSION="3.4.1"
TIME_STAMP=$(date +"%d/%m/%Y %H:%M:%S")
# Define colour codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Colour
log=logs/docker_groupAdd.txt


########################
### Function section ###
########################

function exit_code() {
    if [ $? -eq 0 ]
    then
        echo -e "${GREEN}User <$USER> has been added to the Docker group. Please log out and log back in for the changes to take effect ${NC}"
        echo "User <$USER> has been added to the Docker group. Please log out and log back in for the changes to take effect" >> $log
    else
        echo -e "${RED}User <$USER> has NOT been added to the Docker group. ${NC}"
        echo "User <$USER> has NOT been added to the Docker group." >> $log
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

# Check whether Docker is installed
if ! command -v docker &> /dev/null
then
    echo -e "${RED}Docker is not installed. Installed docker and re-execute this script ${NC}"
    echo "Docker is not installed. Installed docker and re-execute this script" >> $log
    exit 1
fi

if [ "$(groups | grep -c docker)" -eq 1 ]
then
    echo -e "${YELLOW}Your user <$USER> is already a member of the docker group ${NC}"
    echo "Your user <$USER> is already a member of the docker group" >> $log
else
    sudo usermod -aG docker $USER # Add current user to the docker group
    exit_code
fi
