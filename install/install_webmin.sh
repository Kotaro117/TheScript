#!/bin/bash

VERSION="2"
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

sudo apt update

# Install dependency packages
sudo apt install -y curl
if  [ $? -ne 0 ]
then
    echo -e "${RED}Installation of curl was not successful $TIME_STAMP ${NC}"
fi

# Configure repositories
curl -o setup-repos.sh https://raw.githubusercontent.com/webmin/webmin/master/setup-repos.sh 
chmod +x setup-repos.sh
sudo sh setup-repos.sh
rm setup-repos.sh

# Install Webmin
COMMAND="Installation of Webmin"
sudo apt-get install -y webmin --install-recommends
exit_code