#!/bin/bash


########################
### Variable section ###
########################

VERSION="2.5.1"
TIME_STAMP=$(date +"%d/%m/%Y %H:%M:%S")
# Define colour codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Colour
log=logs/install_webmin.txt


########################
### Function section ###
########################

function exit_code() {
    if [ $? -eq 0 ]
    then
        echo -e "${GREEN}$COMMAND was successfully $TIME_STAMP ${NC}"
        echo "$COMMAND was successful" >> $log
    else
        echo -e "${RED}$COMMAND was not successful $TIME_STAMP ${NC}"
        echo "$COMMAND was not successful" >> $log
    fi
}

function check_dependency() {                                                   # Check for dependencies
    command -v $1 >/dev/null 2>&1 || {
        echo -e "${RED}$1 is required but not installed. Would you like to install it $TIME_STAMP ${NC}?"
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

function check_sudo() {                                                         # Check for sudo (if used inside a docker container)
    command -v sudo >/dev/null 2>&1 || {
        echo -e "${RED}sudo is required but not installed. Would you like to install it? $TIME_STAMP ${NC}"
        read -p "Install sudo? (y/n): " answer
        if [ "$answer" == "y" ] 
        then
            apt-get update && apt-get install -y sudo
        else
            echo "Aborting"
            exit 1
        fi
    }
}


###############################
### Beginning of the script ###
###############################

mkdir -p logs # create log folder if not present
echo "" >> $log # add a new line to make it easier to read

echo -e "${YELLOW}running Version $VERSION of the script $TIME_STAMP ${NC}"
echo "$TIME_STAMP running Version $VERSION of the script" >> $log

echo "Script is executed by $USER" >> $log
groups | grep -q '\bsudo\b' && echo "User has sudo permissions" >> $log || echo "User does not have sudo permissions" >> $log

# Install dependency packages
check_sudo
check_dependency curl

sudo apt-get update

# Configure repositories
curl -o setup-repos.sh https://raw.githubusercontent.com/webmin/webmin/master/setup-repos.sh 
chmod +x setup-repos.sh
echo "y" | sudo sh setup-repos.sh
rm setup-repos.sh

# Install Webmin
COMMAND="Installation of Webmin"
sudo apt-get install -y webmin --install-recommends
exit_code