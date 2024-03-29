#!/bin/bash

VERSION="0.9.14"
SCRIPT_URL="https://raw.githubusercontent.com/Kotaro117/TheScript/main/scripts.sh"
TIME_STAMP=$(date +"%d/%m/%Y %H:%M:%S")
# Define colour codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Colour


function update_script_new() {
    if [ "$(curl -s https://raw.githubusercontent.com/Kotaro117/TheScript/main/scripts.sh | grep -oP 'VERSION="\K[^"]+')" != "$VERSION" ]
    then
        echo -e "${YELLOW}No update of this script needed you're running Version $VERSION $TIME_STAMP ${NC}"
    else
        whiptail --title "Script update" --yesno "An update was found, you are on Version $VERSION. Do you want to update this script?" 10 60
        if [ $? -eq 0 ]
        then
            wget -O scripts.sh.update $SCRIPT_URL                                       # downloads the script
            if [ $? -eq 0 ]                                                             # checks if download was successful
            then
                chmod +x scripts.sh.update
                echo -e "${YELLOW}Updating $TIME_STAMP ${NC}"
                rm scripts.sh
                mv scripts.sh.update scripts.sh
                whiptail --title "Script update" --msgbox "Script has been updated successfully" 10 60
                exec ./scripts.sh                                                       # exits current scripts and run updated version
            else
                echo -e "${RED}Error downloading the update $TIME_STAMP ${NC}"                                    
            fi                                                      
        else                                                                               # "no" has been choosen
            echo -e "${YELLOW}User has choosen not to update the script $TIME_STAMP ${NC}"
            whiptail --title "Script update" --msgbox "Script has not been updated, you are still on Version $VERSION" 10 60
        fi
    fi
}

function update_script_old() {
    wget -O scripts.sh.update $SCRIPT_URL                                       # download the script again
    if [ $? -eq 0 ]                                                             # check if download was successful
    then
        if grep -q "VERSION=\"$VERSION\"" scripts.sh.update                     # check if the version number is the same
        then                                                                    # Version number is the same
            rm scripts.sh.update                                                # deletes the downloaded version again
            echo -e "${YELLOW}No update of this script needed you're running Version $VERSION $TIME_STAMP ${NC}"                                             
        else                                                                    # Version is different
            whiptail --title "Script update" --yesno "An update was found, you are on Version $VERSION. Do you want to update this script?" 10 60
            if [ $? -eq 0 ]                                                     # "yes" has been choosen
            then
                chmod +x scripts.sh.update                                      # make the script executeable
                echo -e "${YELLOW}Updating $TIME_STAMP ${NC}"
                rm scripts.sh                                                   # remove the old script
                mv scripts.sh.update scripts.sh                                 # rename the new script
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

function download() {
    mkdir -p $SCRIPT_TYPE                   # creates the necessary folder if it's not allready present
    if [ ! -f $SCRIPT_TYPE/$SCRIPT ]        # checks if the update script is not present  
    then
        wget -O "$SCRIPT_TYPE/$SCRIPT" https://raw.githubusercontent.com/Kotaro117/TheScript/main/$SCRIPT_TYPE/$SCRIPT && chmod +x $SCRIPT_TYPE/$SCRIPT
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
        "7" "Mount a SMB drive" \
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
            echo -e "${YELLOW}Installing Docker $TIME_STAMP ${NC}"
            SCRIPT=install_docker.sh
            SCRIPT_TYPE="install"
            if command -v docker
            then
                whiptail --title "Install Docker" --msgbox "Docker is allready installed" 8 60
                echo -e "${YELLOW} Docker is allready installed $TIME_STAMP ${NC}"
                $SCRIPT_TYPE/./docker_groupAdd.sh
            else
                download
                whiptail --title "Docker install" --msgbox "Docker installed successfully" 8 40
            fi
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
            echo "Mounting smb drive"
            SCRIPT=mountSMB.sh
            SCRIPT_TYPE="update"
            download
            whiptail --title "Mounting drive" --msgbox "Drive mounted successfull" 8 40
            ;;
        8)  
            whiptail --title "Delete Script" --yesno "Are you sure you want to delete everything?" 10 60
            if [ $? -eq 0 ]
            then
                echo -e "${RED}Deleting everything $TIME_STAMP ${NC}"
                rm -R update/ install/ scripts.sh
                echo -e "${GREEN}All files have been deleted $TIME_STAMP ${NC}"
            else
                whiptail --title "Delete Script" --msgbox "Script has not been deleted" 8 35
                echo -e "${YELLOW}Deletion canceled $TIME_STAMP ${NC}"
                ./scripts.sh
            fi
            ;;
        9)  
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

function check_dependency() {                                                   # Check for dependencies
    command -v $1 >/dev/null 2>&1 || {
        echo -e "${RED}$1 is required but not installed. Would you like to install it? $TIME_STAMP ${NC}"
        read -p "Install $1? (y/n): " answer
        if [ "$answer" == "y" ] 
        then
            sudo apt-get update && sudo apt-get install -y $1
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

check_sudo                                                                      # needed if the script is running inside a Docker container
#check_dependency curl                                                          # only needed when the new update function works
check_dependency wget                                                           # needed to download the scripts from GitHub
update_script_old
check_dependency whiptail                                                       # needed fot the script GUI
advancedMenu
