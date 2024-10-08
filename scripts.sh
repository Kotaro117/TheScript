#!/bin/bash


########################
### Variable section ###
########################

VERSION="0.14.2"
SCRIPT_URL="https://raw.githubusercontent.com/Kotaro117/TheScript/main/scripts.sh"
TIME_STAMP=$(date +"%d/%m/%Y %H:%M:%S")
# Define colour codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Colour
log=logs/scripts.txt


########################
### Function section ###
########################

function update_script_new() {
    if [ "$(curl -s https://raw.githubusercontent.com/Kotaro117/TheScript/main/scripts.sh | grep -oP 'VERSION="\K[^"]+')" != "$VERSION" ]
    then
        echo -e "${YELLOW}No update of this script needed you're running Version $VERSION $TIME_STAMP ${NC}"
        echo "No update of this script needed, running Version $VERSION" >> $log
    else
        echo "an update was found" >> $log
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
        else                                                                               # "no" has been chosen
            echo -e "${YELLOW}User has chosen not to update the script $TIME_STAMP ${NC}"
            whiptail --title "Script update" --msgbox "Script has not been updated, you are still on Version $VERSION" 10 60
        fi
    fi
}

function update_script_old() {
    wget -O scripts.sh.update $SCRIPT_URL                                       # download the script again
    if [ $? -eq 0 ]                                                             # check if download was successful
    then
        echo "Script has been downloaded from GitHub. Checking for new version" >> $log
        if grep -q "VERSION=\"$VERSION\"" scripts.sh.update                     # check if the version number is the same
        then                                                                    # Version number is the same
            rm scripts.sh.update                                                # deletes the downloaded version again
            echo "No update needed" >> $log
            echo -e "${YELLOW}No update of this script needed you're running Version $VERSION $TIME_STAMP ${NC}"                                             
        else                                                                    # Version is different
            echo "An update has been found" >> $log
            whiptail --title "Script update" --yesno "An update has been found, you are on Version $VERSION. Do you want to update this script?" 10 60
            if [ $? -eq 0 ]                                                     # "yes" has been chosen
            then
                chmod +x scripts.sh.update                                      # make the script executeable
                echo "Updating the script" >> $log
                rm scripts.sh                                                   # remove the old script
                mv scripts.sh.update scripts.sh                                 # rename the new script
                whiptail --title "Script update" --msgbox "Script has been updated successfully" 10 60
                echo "Script has been updated successfully" >> $log
                exec ./scripts.sh                                               # exits current scripts and run updated version
            else                                                                # "no" has been chosen
                echo "User has chosen not to update the script" >> $log
                rm scripts.sh.update
                whiptail --title "Script update" --msgbox "Script has not been updated, you are still on Version $VERSION" 10 60
            fi
        fi
    else                                                                        # Download was not successful
        echo "ERROR download was not successful" >> $log
        echo -e "${RED}Error downloading the update $TIME_STAMP ${NC}" 
    fi
}

function download() {
    mkdir -p $SCRIPT_TYPE                   # creates the necessary folder if it's not already present
    if [ ! -f $SCRIPT_TYPE/$SCRIPT ]        # checks if the script is not present  
    then
        wget -O "$SCRIPT_TYPE/$SCRIPT" https://raw.githubusercontent.com/Kotaro117/TheScript/main/$SCRIPT_TYPE/$SCRIPT && chmod +x $SCRIPT_TYPE/$SCRIPT
        echo "$SCRIPT has been downloaded" >> $log
    else
        echo "$SCRIPT is already present" >> $log
    fi
    $SCRIPT_TYPE/./$SCRIPT
}

function advancedMenu() {

    ADVSEL=$(whiptail --title "Menu Version $VERSION" --fb --menu "Select an option" 20 80 11 \
        "1" "Update your system" \
        "2" "Update CA certificate store" \
        "3" "Install Proxmox guest agent (Debian/Redhat based)" \
        "4" "Install Docker" \
        "5" "Deploy Portainer" \
        "6" "Update Portainer" \
        "7" "Setup Webmin repos and install it (Debian)" \
        "8" "Mount a SMB drive" \
        "9" "Delete this script" \
        "10" "Update this script" \
        "11" "Install flatpak (Ubuntu)" 3>&1 1>&2 2>&3)

    case $ADVSEL in
        1)
            echo -e "${YELLOW}Updating system $TIME_STAMP ${NC}"
            echo "System update has been chosen" >> $log
            SCRIPT=update_system.sh
            SCRIPT_TYPE="update"
            download
            whiptail --title "System update" --msgbox "System updated successfully" 8 45
            ;;
        2)
            echo -e "${YELLOW}Updating CA certificate store $TIME_STAMP ${NC}"
            echo "Update CA store has been chosen" >> $log
            SCRIPT=update_ca-cert-store.sh
            SCRIPT_TYPE="update"
            download
            whiptail --title "CA store update" --msgbox "CA certificate store has been updated successfully" 8 50
            ;;
        3)
            echo -e "${YELLOW}Installing Proxmox guest agent and enabling autostart $TIME_STAMP ${NC}"
            echo "Install Proxmox guest agent has been chosen" >> $log
            SCRIPT=install_proxmoxGuestAgent.sh
            SCRIPT_TYPE="install"
            download
            whiptail --title "Proxmox guest agent" --msgbox "Proxmox guest agent installed and enabled" 8 50
            ;;
        4)
            echo -e "${YELLOW}Installing Docker $TIME_STAMP ${NC}"
            echo "Install Docker has been chosen" >> $log
            SCRIPT=install_docker.sh
            SCRIPT_TYPE="install"
            download
            whiptail --title "Docker install" --msgbox "Docker installed successfully" 8 40
            ;;
        5)
            echo -e "${YELLOW}Deploying Portainer $TIME_STAMP ${NC}"
            echo "Deploy Portainer has been chosen" >> $log
            SCRIPT=deploy_portainer.sh
            SCRIPT_TYPE="install"
            download
            whiptail --title "Portainer deployment" --msgbox "Portainer deployed successfully" 8 45
            ;;
        6)
            echo -e "${YELLOW}Updating Portainer $TIME_STAMP ${NC}"
            echo "Update Portainer has been chosen" >> $log
            SCRIPT=update_portainer.sh
            SCRIPT_TYPE="update"
            download
            whiptail --title "Portainer update" --msgbox "Portainer updated successfully" 8 40
            ;;
        7)
            echo -e "${YELLOW}Installing Webmin $TIME_STAMP ${NC}"
            echo "Install Webmin has been chosen" >> $log
            SCRIPT=install_webmin.sh
            SCRIPT_TYPE="install"
            download
            whiptail --title "Webmin install" --msgbox "Webmin installed successfully" 8 35
            ;;
        8)  
            echo -e "${YELLOW}Mounting smb drive $TIME_STAMP ${NC}"
            echo "Mounting smb drive has been chosen" >> $log
            SCRIPT=mountSMB.sh
            SCRIPT_TYPE="update"
            download
            whiptail --title "Mounting drive" --msgbox "Drive mounted successfull" 8 40
            ;;
        9)  
            whiptail --title "Delete Script" --yesno "Are you sure you want to delete everything?" 10 60
            echo "Delete script has been chosen" >> $log
            if [ $? -eq 0 ]
            then
                echo -e "${RED}Deleting everything $TIME_STAMP ${NC}"
                echo "yes has been chosen" >> $log
                rm -R update/ install/ scripts.sh
                echo -e "${GREEN}All files have been deleted $TIME_STAMP ${NC}"
                echo "All files have been deleted" >> $log
            else
                whiptail --title "Delete Script" --msgbox "Script has not been deleted" 8 35
                echo -e "${YELLOW}Deletion canceled $TIME_STAMP ${NC}"
                echo "Deletion canceled" >> $log
                ./scripts.sh
            fi
            ;;
        10)  
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
        11)
            echo -e "${YELLOW}Installing flatpak $TIME_STAMP ${NC}"
            echo "Install flatpak has been chosen" >> $log
            SCRIPT=install_flatpak.sh
            SCRIPT_TYPE="install"
            download
            whiptail --title "flatpak" --msgbox "flatpak installed" 8 50
            ;;
        *)
            echo "Invalid choice"
            ;;
    esac
}

function check_package-manager() {
    # Check for apt
    if command -v apt >/dev/null 2>&1
    then
        echo "apt package manager is available" >> $log
        package_manager=apt
    # If apt is not present, check for dnf
    else
        if command -v dnf >/dev/null 2>&1
        then
            echo "dnf package manager is available" >> $log
            package_manager=dnf
        else
            echo "Neither apt nor dnf package manager is available" >> $log
        fi
    fi
}

function check_dependency_whiptail() {
    if whiptail --version >/dev/null 2>&1
    then
        echo "whiptail is installed" >> $log
    else
        echo "whiptail is not installed" >> $log
        echo -e "${RED}Whiptail is required but not installed. Would you like to install it? $TIME_STAMP ${NC}"
        read -p "Install Whiptail? (y/n): " answer
        if [ "$answer" == "y" ] 
        then
            if [ "$package_manager" == "dnf" ]
            then
                sudo $package_manager install -y newt
                echo "User has chosen to install Whiptail" >> $log
            else
                sudo $package_manager install -y whiptail
                echo "User has chosen to install Whiptail" >> $log
            fi
        else
            echo -e "${RED}Aborting, you haven chosen not to install Whiptail $TIME_STAMP ${NC}"
            echo "User has chosen not to install Whiptail" >> $log
            exit 1
        fi
    fi
}

function check_dependency() {                                                       # Check for dependencies
    command -v $1 >/dev/null 2>&1 || {
        echo -e "${RED}$1 is required but not installed. Would you like to install it? $TIME_STAMP ${NC}"
        read -p "Install $1? (y/n): " answer
        if [ "$answer" == "y" ] 
        then
            if [ "$package_manager" == "apt"]
            then 
                sudo apt update
            fi
            sudo $package_manager install -y $1
        else
            echo "Aborting"
            exit 1
        fi
    }
}

function check_sudo_apt() {                                                         # Check for sudo (if used inside a docker container)
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


###############################
### Beginning of the script ###
###############################

mkdir -p logs # create log folder if not present
echo "" >> $log # add a new line to make it easier to read

echo -e "${YELLOW}running Version $VERSION of the script $TIME_STAMP ${NC}"
echo "$TIME_STAMP Running Version $VERSION of the script" >> $log

echo "Scripts is executed by $USER" >> $log
groups | grep -q '\bsudo\b' && echo "User has sudo permissions" >> $log || echo "User does not have sudo permissions" >> $log


check_package-manager                                                           # Checks whether apt or dnf is installed
check_sudo                                                                      # needed if the script is running inside a Docker container
#check_dependency curl                                                          # only needed when the new update function works
check_dependency wget                                                           # needed to download the scripts from GitHub
check_dependency_whiptail                                                       # needed for the script GUI
advancedMenu
