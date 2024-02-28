#!/bin/bash

# V 0.9

# Install Proxmox guest agent
sudo apt-get install qemu-guest-agent -y

# Start the agent
sudo systemctl start qemu-guest-agent

# enable the service to autostart (permanently) if not auto started
sudo systemctl enable qemu-guest-agent