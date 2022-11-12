#!/bin/bash

echo
echo "Fetch the latest scripts from GitHub - Navid200"
echo

cd /tmp

if [ $Test -gt 0 ] # Are we testing?  This variable is defined in the bootstrap file.
then
sudo rm -rf cgm-remote-monitor
sudo git clone https://github.com/Navid200/cgm-remote-monitor.git # Test
cd cgm-remote-monitor
sudo git checkout Navid_2022_11_11_Test
else # If we are not testing
sudo rm -rf nightscout-vps
sudo git clone https://github.com/jamorham/nightscout-vps.git #  Main
cd nightscout-vps
sudo git checkout vps-1
fi

sudo git pull
sudo chmod 755 *.sh # Change premissions to allow execution by all.
sudo mv -f *.sh /xDrip/scripts # Overwrite the scripts in the scripts directory with the new ones.
cd ..
sudo rm -rf nightscout-vps 
sudo rm -rf cgm-remote-monitor

if [ ! -s /tmp/nodialog_update_scripts ]
then
dialog --colors --msgbox "    \Zr Developed by the xDrip team \Zn\n\n\
Updated scripts will be in effect in a new window." 8 43
clear
fi
 
