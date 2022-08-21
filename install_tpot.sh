#!/bin/bash
sudo apt update && sudo apt upgrade -y
sudo apt install git -y

# Clone T-Pot
git clone https://github.com/telekom-security/tpotce

# Get config file
wget https://raw.githubusercontent.com/rirofal/Azure-T-Pot-Bicep/main/tpot.conf

# Install T-Pot
sudo tpotce/iso/installer/install.sh --type=auto --conf=./tpot.conf
