#!/bin/bash

VERSION="0.7.8"
TIME_STAMP=$(date +"%d/%m/%Y %H:%M:%S")
# Define colour codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Colour

echo -e "${YELLOW}running Version $VERSION of the script $TIME_STAMP ${NC}"

# Check if cifs-utils is installed
if ! command -v mount.cifs &> /dev/null
then
    echo -e "${YELLOW}cifs-utils is not installed. $TIME_STAMP ${NC}"
    read -p "Do you want to install it? (y/n): " install_cifs
    if [ "$install_cifs" == "y" ]
    then
        sudo apt-get update
        sudo apt-get install -y cifs-utils
    else
        echo -e "${RED}Aborting. cifs-utils is required to mount SMB shares. $TIME_STAMP ${NC}"
        exit 1
    fi
fi

# Prompt user for SMB share details
read -p "Enter the SMB host (e.g. 192.168.0.1): " smb_host
read -p "Enter the SMB share name (e.g. install): " smb_share
read -p "Enter your username: " smb_user
read -s -p "Enter your password: " smb_password
echo    # Add a newline after the password prompt

# Specify the mount point
read -p "Where do you want to mount the share?: " mount_point

# Create a credentials file
credentials_file="/root/.smbcredentials_${smb_user}_${smb_host}_${smb_share}"
sudo touch $credentials_file
echo "username=$smb_user" | sudo tee "$credentials_file" > /dev/null
echo "password=$smb_password" | sudo tee -a "$credentials_file" > /dev/null
sudo chown root:root "$credentials_file"                  # change file permission to root so no one can see the password
sudo chmod 600 "$credentials_file"                        # change file permission to root so no one can see the password


# Check if the current user has permission to create a folder at the mount point
if [ ! -w "$mount_point" ]
then
    echo -e "${RED}You do not have write permission to $mount_point. $TIME_STAMP ${NC}"
    echo -e "${YELLOW}Running the mount command with sudo. $TIME_STAMP ${NC}"
    sudo mkdir -p "$mount_point"
else
    echo -e "${YELLOW}You have write permission to $mount_point. $TIME_STAMP ${NC}"
fi

# Mount the SMB share
sudo mount -t cifs //"$smb_host"/"$smb_share" "$mount_point" -o credentials="$credentials_file",vers=3.0

# Check if the mount was successful
if [ $? -eq 0 ]
then
    echo -e "${GREEN}SMB share mounted successfully at $mount_point $TIME_STAMP ${NC}"
else
    echo -e "${RED}Failed to mount SMB share $TIME_STAMP ${NC}"
fi

# Prompt user if the mount should be permanent
read -p "Do you want to make this mount permanent? (y/n): " permanent_mount
if [ "$permanent_mount" == "y" ]
then
    # Add the mount to /etc/fstab for permanent mounting
    echo "//${smb_host}/${smb_share} ${mount_point} cifs credentials="$credentials_file",vers=3.0,gid=1000,uid=1000 0 0" | sudo tee -a /etc/fstab
    echo -e "${GREEN}Mount added to /etc/fstab for permanent mounting. $TIME_STAMP ${NC}"
fi

# reload systemd
sudo systemctl daemon-reload

# unmound and mount again to be able to write inside
sudo umount $mount_point
sudo mount $mount_point