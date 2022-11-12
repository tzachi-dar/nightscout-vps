#!/bin/bash

echo
echo "JamOrHam Nightscout Installer - Designed for Google Compute Minimal Ubuntu 20 micro instance"
echo


if [ "`id -u`" != "0" ]
then
echo "Script needs root - execute bootstrap.sh or use sudo bash installation.sh"
echo "Cannot continue.."
exit 5
fi

clear
dialog --colors --msgbox "      \Zr Developed by the xDrip team \Zn\n\n\n\
Some required packages will be installed now.  It will take about 9 minutes.  This terminal needs to be kept open.\n\
If this is not a good time, you can press escape to cancel." 14 50
if [ $? = 255 ]
then
clear
exit
fi
clear

if [ ! -s /var/SWAP ]
then
echo "Creating swap partition"
dd if=/dev/zero of=/var/SWAP bs=1M count=2000
chmod 600 /var/SWAP
mkswap /var/SWAP
fi
swapon 2>/dev/null /var/SWAP

echo "Installing system basics"
sudo apt-get update
sudo apt-get -y install wget gnupg libcurl4 openssl liblzma5
sudo apt-get -y install dirmngr apt-transport-https lsb-release ca-certificates
sudo apt-get -y install vis
sudo apt-get -y install nano
sudo apt-get -y install screen
sudo apt-get -y install net-tools
sudo apt-get -y install build-essential
sudo apt-get -y install mongodb-server
sudo apt-get -y install jq

# Create mongo user and admin.
echo -e "use Nightscout\ndb.createUser({user: \"username\", pwd: \"password\", roles:[\"readWrite\"]})\nquit()" | mongo
echo -e "use admin\ndb.createUser({ user: \"mongoadmin\" , pwd: \"mongoadmin\", roles: [\"userAdminAnyDatabase\", \"dbAdminAnyDatabase\", \"readWriteAnyDatabase\"]})\nquit()" | mongo

echo "Installing Node js"

sudo apt-get install -y nodejs npm
sudo apt -y autoremove
 
