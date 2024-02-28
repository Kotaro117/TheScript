#!/bin/bash

# V 0.1

VERSION="0.7.24"
UPDATE_URL="http://scriptsrv01.pama.home/linux/update/"
INSTALL_URL="http://scriptsrv01.pama.home/linux/install/"
SCRIPT_URL="http://scriptsrv01.pama.home/linux/scripts.sh"
INSTALL_PATH="install"
UPDATE_PATH="update"
BACKUP_PATH="backup"


    local current_version="Version_$VERSION"
    local latest_version=$(wget -qO- $SCRIPT_URL | grep -oP 'version="\K[^"]+')