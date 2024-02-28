#!/bin/bash

VERSION="2.4"
RELEASE_FILE="/etc/os-release"

echo "running Version $VERSION"

if grep -q "Arch" $RELEASE_FILE
then
    # The host is based on Arch, run the pacman update command
    sudo pacman -Syu
fi

if grep -q "Debian" $RELEASE_FILE || grep -q "Ubuntu" $RELEASE_FILE || grep -q "Pop" $RELEASE_FILE # "||"=or
then
    # The host is based on Ubuntu or Debian,
    # Run the apt version of the command
    sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y
fi