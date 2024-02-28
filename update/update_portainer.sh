#!/bin/bash

# V 1.0

# Stop Portainer
sudo docker stop portainer

# Remove Portainer container
sudo docker rm portainer

# Download the latest image of Portainer
sudo docker pull portainer/portainer-ce:latest

# Deploy hte updated version
sudo docker run -d -p 8000:8000 -p 9443:9443 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest