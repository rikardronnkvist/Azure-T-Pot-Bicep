#!/bin/bash
sudo apt-get update && sudo apt-get upgrade --yes

# Docker installation
sudo apt-get install ca-certificates curl gnupg lsb-release --yes

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin docker-compose --yes

# T-Pot installation
sudo apt-get install git pip conntrack --yes
sudo pip3 install yq --no-input 

git clone https://github.com/telekom-security/tpotce

while getopts f:u:p: flag
do
    case "${flag}" in
        f) flavor=${OPTARG};;
        u) webuser=${OPTARG};;
        p) webpass=${OPTARG};;
    esac
done
echo "myCONF_TPOT_FLAVOR='$flavor'" > ./tpot.conf
echo "myCONF_WEB_USER='$webuser'" >> ./tpot.conf
echo "myCONF_WEB_PW='$webpass'" >> ./tpot.conf

sudo tpotce/iso/installer/install.sh --type=auto --conf=./tpot.conf
