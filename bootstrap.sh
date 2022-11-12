#!/bin/sh
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin"

Test=0
# Uncomment the following line for testing.
Test=1 ###################################### This line must be commented out before submitting a PR.  ##########################################
# curl https://raw.githubusercontent.com/Navid200/cgm-remote-monitor/Navid_2022_11_11_Test/bootstrap.sh | bash  <---  Only tested this way

echo 
echo "Bootstrapping the menu - Navid200"
echo

sudo apt-get update
sudo apt-get install dialog
ubversion="$(cat /etc/issue | awk '{print $2}')"
if [[ ! "$ubversion" = "20.04"* ]]
then
clear
dialog --colors --msgbox "       \Zr Developed by the xDrip team \Zn\n\n\
The Ubuntu version on the virtual machine is incorrect.  You need to delete the virtual machine and create a new one.  Please refer to the guide for the details." 10 50
exit
fi

sudo apt-get -y install wget bash
sudo apt-get install -y  git python gcc g++ make
sudo apt-get -y install netcat

cd /
if [ ! -s xDrip ] # Create the xDrip directory if it does not exist.
then
sudo mkdir xDrip
fi
cd xDrip
if [ ! -s scripts ]
then
sudo mkdir scripts
fi

cd /tmp
if [ ./update_scripts.sh ]
then
sudo rm update_scripts.sh
fi

if [ $Test -gt 0 ]
then
wget https://raw.githubusercontent.com/Navid200/cgm-remote-monitor/Navid_2022_11_11_Test/update_scripts.sh # Test
match='Test=0'
insert='Test=1'
file='update_scripts.sh'
sed -i "s/$match/$match\n$insert/" $file
else
wget https://raw.githubusercontent.com/jamorham/nightscout-vps/vps-1/update_scripts.sh # Main
fi

if [ ! -s update_scripts.sh ]
then
echo "UNABLE TO DOWNLOAD update_scripts SCRIPT! - cannot continue - please try again!"
exit 5
fi

sudo chmod 755 update_scripts.sh
sudo mv -f update_scripts.sh /xDrip/scripts

# Updating the scripts
cat > /tmp/nodialog_update_scripts << EOF
Don't show dialog

EOF

/xDrip/scripts/update_scripts.sh

# So that the menu comes up as soon as the user logs in (opens a terminal)
cd /tmp
cat > /tmp/start_menu.sh << EOF
#!/bin/sh
sleep 1
/xDrip/scripts/menu.sh

EOF
sudo chown root:root start_menu.sh
sudo chmod 755 start_menu.sh
sudo mv -f start_menu.sh /etc/profile.d

if [ "$(grep /xDrip/scripts/menu.sh ~/.bash_aliases)" = "" ] # If there is no alias to menu.sh not even commented out
then
cat >> ~/.bash_aliases << EOF
alias menu="/xDrip/scripts/menu.sh"
EOF
fi

clear
dialog --colors --msgbox "     \Zr Developed by the xDrip team \Zn\n\n\
If any item is shown in red on the status page (shown next), it represents an incorrect parameter that could result in malfunction or cost.  \
Please take a note, delete the virtual machine, and create a new one.   For more detail, please refer to the guide." 12 50

# Bring up the status page
/xDrip/scripts/Status.sh
dialog --colors --msgbox "     \Zr Developed by the xDrip team \Zn\n\n\
Press enter to restart the server.  This will result in an expected error message.  Wait 30 seconds before clicking on retry to reconnect." 10 50
sudo reboot
 
