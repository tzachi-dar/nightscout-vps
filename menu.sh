#!/bin/bash

echo
echo "Bringing up the menu" - Navid200
echo

while :
do

clear
Choice=$(dialog --colors --nocancel --nook --menu "\
      \Zr Developed by the xDrip team \Zn\
  \n\n
Use the arrow keys to move the cursor.\n\
Press Enter to execute the highlighted option.\n\n" 24 50 14\
 "1" "Status"\
 "2" "Installation phase 1 - 9 minutes"\
 "3" "Installation phase 2 - 28 minutes"\
 "4" "Installation phase 3 - 10 minutes"\
 "5" "Edit variables"\
 "6" "Edit variables in a browser"\
 "7" "Copy data from another Nightscout"\
 "8" "Update scripts"\
 "9" "Backup MongoDB"\
 "10" "Restore MongoDB backup"\
 "11" "FreeDNS Setup"\
 "12" "Update/Customize Nightscout"\
 "13" "Reboot server (Nightscout)"\
 "14" "Exit to shell (terminal)"\
 3>&1 1>&2 2>&3)

case $Choice in

1)
/xDrip/scripts/Status.sh
;;

2)
sudo /xDrip/scripts/NS_Install.sh
;;

3)
rm -f /tmp/reboot_after_NSupdate
sudo /xDrip/scripts/update_nightscout.sh
;;

4)
sudo /xDrip/scripts/NS_Install3.sh
;;

5)
/xDrip/scripts/variables.sh
;;

6)
/xDrip/scripts/varserver.sh
;;

7)
sudo /xDrip/scripts/clone_nightscout.sh
;;

8)
clear
sudo /xDrip/scripts/update_scripts.sh
;;

9)
/xDrip/scripts/backupmongo.sh
;;

10)
/xDrip/scripts/restoremongo.sh
;;

11)
clear
sudo /xDrip/scripts/ConfigureFreedns.sh
;;

12)
cat > /tmp/reboot_after_NSupdate << EOF
Reboot after update is complete.
EOF
sudo /xDrip/scripts/update_nightscout.sh
;;

13)
dialog --colors --yesno "     \Zr Developed by the xDrip team \Zn\n\n\
Are you sure you want to reboot the server?\n
If you do, all unsaved open files will close without saving.\n"  10 50
response=$?
if [ $response = 255 ] || [ $response = 1 ]
then
clear
else
sudo reboot
fi
;;

14)
cd /tmp
clear
dialog --colors --msgbox "        \Zr Developed by the xDrip team \Zn\n\n\
You will now exit to the shell (terminal).  To return to the menu, enter menu in the terminal." 9 50
clear
exit
;;

esac

done
 
