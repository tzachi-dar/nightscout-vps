#!/bin/sh
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin"

echo 
echo "Bootstrapping Nightscout installer - JamOrHam"
echo
cd /tmp
if [ ! -s installation.sh ]
then
sudo apt-get update
sudo apt-get -y install wget bash
wget https://raw.githubusercontent.com/jamorham/nightscout-vps/vps-1/installation.sh
if [ ! -s installation.sh ]
then
echo "UNABLE TO DOWNLOAD INSTALLATION SCRIPT! - cannot continue - please try again!"
exit 5
fi
fi


if [ "$SSH_TTY" = "" ]
then
echo "Must be run from ssh session"
exit 5
fi

echo
echo "Running installer"
echo
sudo < $SSH_TTY bash installation.sh
echo
echo "Finished running installer"
echo
