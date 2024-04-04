#!/bin/bash

VERSION="0.3.0"
TIME_STAMP=$(date +"%d/%m/%Y %H:%M:%S")
# Define colour codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Colour
log=update_ca-cert-store.txt

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

echo "Where is your CA certificate file stored? (eg. /folder/file.crt): "
    read CA_FILE
COMMAND="Copie of the CA certificate"
sudo cp $CA_FILE /usr/local/share/ca-certificates/
exit_code
COMMAND="Update of the CA certificate store"
sudo update-ca-certificates
exit_code