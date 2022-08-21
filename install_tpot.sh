#!/bin/bash
sudo apt update && sudo apt upgrade -y

# Docker installation
sudo apt-get install ca-certificates curl gnupg lsb-release -y

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin docker-compose -y

# T-Pot installation
sudo apt-get install git -y

# Clone T-Pot
git clone https://github.com/telekom-security/tpotce

# Get config file
wget https://raw.githubusercontent.com/rirofal/Azure-T-Pot-Bicep/main/tpot.conf

# Install T-Pot
sudo tpotce/iso/installer/install.sh --type=auto --conf=./tpot.conf
