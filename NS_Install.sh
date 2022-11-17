#!/bin/bash

echo
echo "JamOrHam Nightscout Installer - Designed for Google Compute Minimal Ubuntu 20 micro instance"
echo


if [ "`id -u`" != "0" ]
then
echo "Script needs root - use sudo bash NS_Install.sh"
echo "Cannot continue.."
exit 5
fi

Test=0
Test=1 ################ This line must be commented out before submitting a PR.  ##########################

clear
dialog --colors --msgbox "      \Zr Developed by the xDrip team \Zn\n\n\
Some required packages will be installed now.  It will take about 15 minutes to complete.  This terminal needs to be kept open.  Press enter to proceed.\n\n\
If this is not a good time, you can press escape now to cancel." 13 50
if [ $? = 255 ]
then
clear
exit
fi
clear

if [ ! -s /var/SWAP ]
then
echo "Creating swap file"
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

sudo apt-get install -y  git python gcc g++ make

echo "Installing Node js"

sudo apt-get install -y nodejs npm
sudo apt -y autoremove

cd /srv

echo "Installing Nightscout"

if [ $Test -lt 1 ] # We are not testing.
then

sudo git clone https://github.com/jamorham/nightscout-vps.git
cd nightscout-vps
sudo git checkout vps-1
else # We are testing.

sudo git clone https://github.com/Navid200/cgm-remote-monitor.git
cd cgm-remote-monitor
sudo git checkout Navid_2022_11_16_Test
fi
sudo git pull

sudo npm install
sudo npm run generate-keys

for loop in 1 2 3 4 5 6 7 8 9
do
read -t 0.1 dummy
done
 
