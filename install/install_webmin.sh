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

function check_dependency() {                                                   # Check for dependencies
    command -v $1 >/dev/null 2>&1 || {
        echo "$1 is required but not installed. Would you like to install it?"
        read -p "Install $1? (y/n): " answer
        if [ "$answer" == "y" ] 
        then
            sudo apt-get install -y $1
        else
            echo "Aborting"
            exit 1
        fi
    }
}

echo -e "${YELLOW}running Version $VERSION of the script $TIME_STAMP ${NC}"

sudo apt-get update

# Install dependency packages
check_dependency curl

# Configure repositories
curl -o setup-repos.sh https://raw.githubusercontent.com/webmin/webmin/master/setup-repos.sh 
chmod +x setup-repos.sh
sudo sh setup-repos.sh
rm setup-repos.sh

# Install Webmin
COMMAND="Installation of Webmin"
sudo apt-get install -y webmin --install-recommends
exit_code