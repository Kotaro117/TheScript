#!/bin/bash

VERSION="0.2"
TIME_STAMP=$(date +"%d/%m/%Y %H:%M:%S")
# Define colour codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Colour

function exit_code() {
    if [ $? -eq 0 ]
    then
        echo -e "${GREEN}$COMMAND was successfully $TIME_STAMP ${NC}"
    else
        echo -e "${RED}$COMMAND was not successful $TIME_STAMP ${NC}"
    fi
}

echo "Where is your CA certificate file stored? (eg. /folder/file.crt): "
    read CA_FILE
COMMAND="Copie of the CA certificate"
sudo cp $CA_FILE /usr/local/share/ca-certificates/
exit_code
COMMAND="Update of the CA certificate store"
sudo update-ca-certificates
exit_code