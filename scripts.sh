#!/bin/bash

VERSION="0.9.2.2"
UPDATE_URL="http://scriptsrv01.pama.home/linux/update/"
INSTALL_URL="http://scriptsrv01.pama.home/linux/install/"
SCRIPT_URL="https://raw.githubusercontent.com/Kotaro117/TheScript/main/scripts.sh"
INSTALL_PATH="install"
UPDATE_PATH="update"
BACKUP_PATH="backup"

function update_script() {

    wget -O scripts.sh.update $SCRIPT_URL && chmod +x scripts.sh.update         # download the script again and makes it executable
    if [ $? -eq 0 ]                                                             # checks if download was successful
    then
        if grep -q "VERSION=\"$VERSION\"" scripts.sh.update                     # checks if the version number is the same
        then                                                                    # Version number is the same
            rm scripts.sh.update                                                # deletes the downloaded version again
            echo "No update needed"                                             
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
                rm scripts.sh.update
                whiptail --title "Script update" --msgbox "Script has not been updated, you are still on Version $VERSION" 10 60
            fi
        fi
    else                                                                        # Download was not successful
        echo "Error downloading the update"                                     
    fi
}

update_script

# Check for dependencies
command -v whiptail >/dev/null 2>&1 || { 
    echo >&2 "whiptail is required but not installed. Would you like to install it?";
    read -p "Install whiptail? (y/n): " answer
        if [ "$answer" == "y" ]; then
        sudo apt-get update
        sudo apt-get install -y whiptail
    else
        echo "Aborting."
        exit 1
    fi
} # checks for whiptail
command -v wget >/dev/null 2>&1 || { 
    if whiptail --title "Install wget?" --yesno "wget is required but not installed. Would you like to install it?" 10 60; then
        sudo apt-get update
        sudo apt-get install -y wget
    else
        echo "Aborting.";
        exit 1;
    fi
} # checks for wget

# Backup old scripts, download new scripts and make them executable
if [ ! -d $BACKUP_PATH ]                        # Checks if backup folder does not exist
then 
    mkdir $BACKUP_PATH                          # Creates backup folder if it's not there
fi

if [ ! -d $BACKUP_PATH/$VERSION ]               # Checks if backup/version folder does not exist
then
    mkdir $BACKUP_PATH/$VERSION                 # Creates backup/Version folder if it's not there
    cp scripts.sh $BACKUP_PATH/$VERSION     
fi

if [ ! -d $UPDATE_PATH ] && [ ! -d $BINSTALL_PATH ]
then
    whiptail --title "Folder missing" --msgbox "Update and install folders aren't present. Please consider to redownload the script" 8 60
    exit
fi

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
            $UPDATE_PATH/./update_system.sh
            whiptail --title "System update" --msgbox "System updated successfully" 8 45
            ;;
        2)
            echo "Installing Proxmox guest agent (Debian) and enabling autostart"
            $INSTALL_PATH/./install_proxmoxGuestAgent.sh
            whiptail --title "Proxmox guest agent" --msgbox "Proxmox guest agent installed and enabled" 8 50
            ;;
        3)
            echo "Installing Docker"
            $INSTALL_PATH/./install_docker.sh
            whiptail --title "Docker install" --msgbox "Docker installed successfully" 8 40
            ;;
        4)
            echo "Deploying Portainer"
            $INSTALL_PATH/./deploy_portainer.sh
            whiptail --title "Portainer deployment" --msgbox "Portainer deployed successfully" 8 45
            ;;
        5)
            echo "Updating Portainer"
            $UPDATE_PATH/./update_portainer.sh
            whiptail --title "Portainer update" --msgbox "Portainer updated successfully" 8 40
            ;;
        6)
            echo "Installing Webmin"
            $INSTALL_PATH/./install_webmin.sh
            whiptail --title "Webmin install" --msgbox "Webmin installed successfully" 8 35
            ;;
        7)  
            echo "Installing Syncthing"
            $INSTALL_PATH/./install_syncthing.sh
            whiptail --title "Syncthing install" --msgbox "Syncthing installed successfully" 8 40
            ;;
        8)  
            echo "Are you sure you want to delete everything?"
            whiptail --title "Delete Script" --yesno "Are you sure you want to delete everything?" 10 60
            if [ $? -eq 0 ]; then
                echo "Deleting everything"
                mv $UPDATE_PATH $INSTALL_PATH scripts.sh scripts.sh.OLD $BACKUP_PATH/$version/ # Backup before deletion
            else
                whiptail --title "Delete Script" --msgbox "Script has not been deleted" 8 35
                echo "Deletion canceled"
                ./scripts.sh
            fi
            ;;
        9)  
            echo "Do you want to update this script?"
            whiptail --title "Script update" --yesno "Do you want to update this script?" 9 60
            if [ $? -eq 0 ]
            then
                update_script
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

# Deletes all scrips at the end
# rm -R update install
