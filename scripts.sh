#!/bin/bash

VERSION="0.9.3"
SCRIPT_URL="https://raw.githubusercontent.com/Kotaro117/TheScript/main/scripts.sh"
INSTALL_PATH="install"
UPDATE_PATH="update"
BACKUP_PATH="backup"
TIME_STAMP=$(date +"%d/%m/%Y %H:%M:%S")
# Define colour codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Colour

function update_script() {
    wget -O scripts.sh.update $SCRIPT_URL && chmod +x scripts.sh.update         # download the script again and makes it executable
    if [ $? -eq 0 ]                                                             # checks if download was successful
    then
        if grep -q "VERSION=\"$VERSION\"" scripts.sh.update                     # checks if the version number is the same
        then                                                                    # Version number is the same
            rm scripts.sh.update                                                # deletes the downloaded version again
            echo -e "${YELLOW}No update needed $TIME_STAMP ${NC}"                                             
        else                                                                    # Version is different
            whiptail --title "Script update" --yesno "An update was found, you are on Version $VERSION. Do you want to update this script?" 10 60
            if [ $? -eq 0 ]                                                     # "yes" has been choosen
            then
                echo "Updating"
                rm scripts.sh
                mv scripts.sh.update scripts.sh
                whiptail --title "Script update" --msgbox "Script has been updated successfully" 10 60
                exec ./scripts.sh                                               # exits current scripts and run updated version
            else                                                                # "no" has been choosen
                echo -e "${YELLOW}User has choosen not to update the script $TIME_STAMP ${NC}"
                rm scripts.sh.update
                whiptail --title "Script update" --msgbox "Script has not been updated, you are still on Version $VERSION" 10 60
            fi
        fi
    else                                                                        # Download was not successful
        echo -e "${RED}Error downloading the update $TIME_STAMP ${NC}"                                    
    fi
}

update_script

# Check for dependencies
command -v whiptail >/dev/null 2>&1 || {    # checks for whiptail
    echo >&2 "whiptail is required but not installed. Would you like to install it?";
    read -p "Install whiptail? (y/n): " answer
        if [ "$answer" == "y" ]; then
        sudo apt-get update
        sudo apt-get install -y whiptail
    else
        echo "Aborting."
        exit 1
    fi
} 
command -v wget >/dev/null 2>&1 || {        # checks for wget
    if whiptail --title "Install wget?" --yesno "wget is required but not installed. Would you like to install it?" 10 60
    then
        sudo apt-get update
        sudo apt-get install -y wget
    else
        echo "Aborting.";
        exit 1;
    fi
} 

function download() {
    if [ ! -d $SCRIPT_TYPE ]
    then
        echo -e "${YELLOW}Folder $SCRIPT_TYPE it not present $TIME_STAMP ${NC}"      
        mkdir $SCRIPT_TYPE
        echo -e "${YELLOW}Folder $SCRIPT_TYPE has been created $TIME_STAMP ${NC}"
    fi
    
    if [ ! -f $SCRIPT_TYPE/$SCRIPT ]        # checks if update script is not present  
    then
        wget -O "$SCRIPT_TYPE/$SCRIPT" https://raw.githubusercontent.com/Kotaro117/TheScript/main/$SCRIPT_TYPE/$SCRIPT
        chmod +x $SCRIPT_TYPE/$SCRIPT
    fi
    $SCRIPT_TYPE/./$SCRIPT
}

function advancedMenu() {

    ADVSEL=$(whiptail --title "Menu Version $VERSION" --fb --menu "Select an option" 18 80 9 \
        "1" "Update your system" \
        "2" "Install Proxmox guest agent (Debian), run it, and enable autostart" \
        "3" "Install Docker (Ubuntu)" \
        "4" "Deploy Portainer" \
        "5" "Update Portainer" \
        "6" "Setup Webmin repos and install it (Debian)" \
        "7" "Install Syncthing (BETA)" \
        "8" "Delete this script" \
        "9" "Update this script" 3>&1 1>&2 2>&3)

    case $ADVSEL in
        1)
            echo "Updating system"
            SCRIPT=update_system.sh
            SCRIPT_TYPE="update"
            download
            whiptail --title "System update" --msgbox "System updated successfully" 8 45
            ;;
        2)
            echo "Installing Proxmox guest agent (Debian) and enabling autostart"
            SCRIPT=install_proxmoxGuestAgent.sh
            SCRIPT_TYPE="install"
            download
            whiptail --title "Proxmox guest agent" --msgbox "Proxmox guest agent installed and enabled" 8 50
            ;;
        3)
            echo "Installing Docker"
            SCRIPT=install_docker.sh
            SCRIPT_TYPE="install"
            download
            whiptail --title "Docker install" --msgbox "Docker installed successfully" 8 40
            ;;
        4)
            echo "Deploying Portainer"
            SCRIPT=deploy_portainer.sh
            SCRIPT_TYPE="install"
            download
            whiptail --title "Portainer deployment" --msgbox "Portainer deployed successfully" 8 45
            ;;
        5)
            echo "Updating Portainer"
            SCRIPT=update_portainer.sh
            SCRIPT_TYPE="install"
            download
            whiptail --title "Portainer update" --msgbox "Portainer updated successfully" 8 40
            ;;
        6)
            echo "Installing Webmin"
            SCRIPT=install_webmin.sh
            SCRIPT_TYPE="install"
            download
            whiptail --title "Webmin install" --msgbox "Webmin installed successfully" 8 35
            ;;
        7)  
            echo "Installing Syncthing"
            SCRIPT=install_syncthing.sh
            SCRIPT_TYPE="install"
            download
            whiptail --title "Syncthing install" --msgbox "Syncthing installed successfully" 8 40
            ;;
        8)  
            echo "Are you sure you want to delete everything?"
            whiptail --title "Delete Script" --yesno "Are you sure you want to delete everything?" 10 60
            if [ $? -eq 0 ]
            then
                echo -e "${RED}Deleting everything $TIME_STAMP ${NC}"
            else
                whiptail --title "Delete Script" --msgbox "Script has not been deleted" 8 35
                echo -e "${YELLOW}Deletion canceled $TIME_STAMP ${NC}"
                ./scripts.sh
            fi
            ;;
        9)  
            echo "Do you want to update this script?"
            whiptail --title "Script update" --yesno "Do you want to update this script?" 9 60
            if [ $? -eq 0 ]
            then
                update_script
                exec ./scripts.sh
            else
                whiptail --title "Script update" --msgbox "Script has not been updated" 9 60
                ./scripts.sh
            fi
            ;;
        *)
            echo "Invalid choice"
            ;;
    esac
}

advancedMenu
