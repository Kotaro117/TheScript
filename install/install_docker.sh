#!/bin/bash

# V 2.6

INSATALL_PATH="install"

# Check for dependencies (Whiptail)
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
}

if command -v docker
then
    whiptail --title "Install Docker" --msgbox "Docker is allready installed" 8 60
    $INSATALL_PATH/./docker_groupAdd.sh 
else
    # Uninstall all conflicting packages
    for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg -y; done

    # Add Docker's official GPG key:
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl gnupg
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg

    # Add the repository to Apt sources:
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release
    echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update

    # Install the latest Docker packages
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

     Verify that the Docker Engine installation is successful by running the hello-world image.
    sudo docker run hello-world

    # Add user to the docker group
    $INSATALL_PATH/./docker_groupAdd.sh 
fi