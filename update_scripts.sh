#!/bin/bash

echo
echo "Fetch the latest scripts from GitHub - Navid200"
echo

. /etc/git-parameters.sh

cd /tmp

if [ -s ./"$GIT_REPOSITRY" ] # Main
then
sudo rm -r "$GIT_REPOSITRY" # If the directory already exists in the tmp directory, delete it.  Main
fi

sudo git clone https://github.com/"$GIT_USER"/"$GIT_REPOSITRY".git # Clone the install repository.  Main
cd "$GIT_REPOSITRY" # Main
sudo git checkout "$GIT_BRANCH" # Main
sudo git pull
sudo chmod 755 *.sh # Change premissions to allow execution by all.
sudo mv -f *.sh /xDrip/scripts # Overwrite the scripts in the scripts directory with the new ones.
cd ..
sudo rm -r "$GIT_REPOSITRY" # Delete the temporary pull directory. # Main

if [ ! -s /tmp/nodialog_update_scripts ]
then
dialog --colors --msgbox "    \Zr Developed by the xDrip team \Zn\n\n\
Updated scripts will be in effect in a new window." 8 43
clear
fi
 
