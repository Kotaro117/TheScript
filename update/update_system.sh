#!/bin/bash

VERSION="2.6"
RELEASE_FILE="/etc/os-release"

function exit_code() {
    if [ $? -eq 0 ]
    then
        echo "Update was successful"
    else
        echo "Update was not successful"
    fi
}

echo "running Version $VERSION"

if grep -q "Arch" $RELEASE_FILE
then
    # The host is based on Arch, run the pacman update command
    sudo pacman -Syu
    exit_code
else
    echo "Host is not based on Arch"
fi

if grep -q "Debian" $RELEASE_FILE || grep -q "Ubuntu" $RELEASE_FILE || grep -q "Pop" $RELEASE_FILE # "||"=or
then
    # The host is based on Debian, Ubuntu or Pop
    # Run the apt version of the command
    sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y
    exit_code
else
    echo "Host is not based on Debian"
fi
