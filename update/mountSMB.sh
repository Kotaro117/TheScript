#!/bin/bash

VERSION="0.10.1"
TIME_STAMP=$(date +"%d/%m/%Y %H:%M:%S")
# Define colour codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Colour
log=logs/mountSMB.txt

function check_mount() {
    if [ $? -eq 0 ]
    then
        echo -e "${GREEN}SMB share mounted successfully at $mount_point $TIME_STAMP ${NC}"
        echo "SMB share mounted successfully at $mount_point" >> $log
    else
        echo -e "${RED}Failed to mount SMB share. Check your user credentials $credentials_file $TIME_STAMP ${NC}"
        echo "ERROR Failed to mount SMB share. Check your user credentials $credentials_file" >> $log
    fi
}

###############################
### BEGINNING OF THE SCRIPT ###
###############################

mkdir -p logs # create log folder if not present
echo "" >> $log # add a new line to make it easier to read
echo -e "${YELLOW}running Version $VERSION of the script $TIME_STAMP ${NC}"
echo "$TIME_STAMP running Version $VERSION of the script" >> $log

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
        echo -e "${RED}Aborting, cifs-utils is required to mount SMB shares. $TIME_STAMP ${NC}"
        echo "ERROR cifs-utils is required to mount SMB shares." >> $log
        exit 1
    fi
fi

# Prompt user for SMB share details
read -p "Enter the SMB host (e.g. 192.168.0.1): " smb_host
read -p "Enter the SMB share name (e.g. install): " smb_share
read -p "Where do you want to mount the share? It needs to be the full system path: " mount_point # Specify the mount point

if sudo test -f /root/.smbcredentials
then
    # Read the contents of the file
    file_contents=$(sudo cat "/root/.smbcredentials")

    # Convert the contents into an array, splitting by newline
    IFS=$'\n' read -r -d '' -a options <<< "$file_contents"

    # Add an option to choose nothing
    options+=("Choose nothing")
    
    # Prompt the user to select an option
    echo "Do you want to use on the system stored credentials?: "
    select opt in "${options[@]}"; do
        # Check if a valid option was selected
        if [[ -n $opt ]]
        then
            if [[ $opt == "Choose nothing" ]]
            then
                echo "You chose to select nothing."
                credentials_file="/root/.smbcredentials_${smb_user}-${smb_host}"
                # Prompt user for SMB share details
                read -p "Enter your SMB username: " smb_user
                read -s -p "Enter your SMB password: " smb_password
                echo    # Add a newline after the password prompt
                echo "${smb_user}-${smb_host}" | sudo tee -a /root/.smbcredentials

                # Create a credentials file
                credentials_file="/root/.smbcredentials_${smb_user}-${smb_host}"
                sudo touch $credentials_file
                echo "username=$smb_user" | sudo tee "$credentials_file" > /dev/null
                echo "password=$smb_password" | sudo tee -a "$credentials_file" > /dev/null
                sudo chown root:root "$credentials_file"                  # change file permission to root so no one can see the password 
            else
                echo "You selected: $opt"
                credentials_file="/root/.smbcredentials_${opt}"
            fi
            break
        else
            echo "Invalid option. Please try again."
        fi
    done
else
    credentials_file="/root/.smbcredentials_${smb_user}-${smb_host}"
    # Prompt user for SMB share details
    read -p "Enter your SMB username: " smb_user
    read -s -p "Enter your SMB password: " smb_password
    echo    # Add a newline after the password prompt
    echo "${smb_user}-${smb_host}" | sudo tee -a /root/.smbcredentials

    # Create a credentials file
    credentials_file="/root/.smbcredentials_${smb_user}-${smb_host}"
    sudo touch $credentials_file
    echo "username=$smb_user" | sudo tee "$credentials_file" > /dev/null
    echo "password=$smb_password" | sudo tee -a "$credentials_file" > /dev/null
    sudo chown root:root "$credentials_file"                  # change file permission to root so no one can see the password 
fi

echo "smb_share is smb://$smb_host/$smb_share"  >> $log

# creates the mount point if not allready present
sudo mkdir -p "$mount_point"

# Prompt user if the mount should be permanent
read -p "Do you want to make this mount permanent? (y/n): " permanent_mount
if [ "$permanent_mount" == "y" ]
then
    # Add the mount to /etc/fstab for permanent mounting
    echo "//${smb_host}/${smb_share} ${mount_point} cifs credentials="$credentials_file",vers=3.0,uid=$(id -u),gid=$(id -g) 0 0" | sudo tee -a /etc/fstab
    echo -e "${GREEN}Mount added to /etc/fstab for permanent mounting. $TIME_STAMP ${NC}"
    echo "Mount added to /etc/fstab for permanent mounting" >> $log
    sudo mount $mount_point
    check_mount
else
    sudo mount -t cifs //"$smb_host"/"$smb_share" "$mount_point" -o credentials="$credentials_file",uid=$(id -u),gid=$(id -g),vers=3.0
    check_mount
fi

# reload systemd
sudo systemctl daemon-reload