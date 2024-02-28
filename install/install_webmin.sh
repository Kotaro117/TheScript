#!/bin/bash

# V 1.0

sudo apt update

# Install dependency packages
sudo apt install -y curl

# Configure repositories
curl -o setup-repos.sh https://raw.githubusercontent.com/webmin/webmin/master/setup-repos.sh 
chmod +x setup-repos.sh
sudo sh setup-repos.sh
rm setup-repos.sh

# Install Webmin
sudo apt-get install -y webmin --install-recommends