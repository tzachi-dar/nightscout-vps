#!/bin/bash

echo
echo "Bringing up the menu" - Navid200
echo

while :
do

Choice=$(dialog --colors --nocancel --nook --menu "\
      \Zr Developed by the xDrip team \Zn\
  \n\n
Use the arrow keys to move the cursor.\n\
Press Enter to execute the highlighted option.\n\n" 22 50 13\
 "1" "Status"\
 "2" "Nightscout install phase 1 - 9 minutes"\
 "3" "Nightscout install phase 2 - 28 minutes"\
 "4" "Nightscout install phase 3 - 10 minutes"\
 "5" "Edit Nightscout Variables"\
 "6" "Copy data from another Nightscout"\
 "7" "Update scripts"\
 "8" "Backup MongoDB"\
 "9" "Restore MongoDB backup"\
 "10" "FreeDNS Setup"\
 "11" "Update/Customize Nightscout"\
 "12" "Reboot server (Nightscout)"\
 "13" "Exit to shell (terminal)"\
 3>&1 1>&2 2>&3)

case $Choice in

1)
/xDrip/scripts/Status.sh
;;

2)
sudo /xDrip/scripts/NS_Install.sh
;;

3)
sudo /xDrip/scripts/update_nightscout.sh
;;

4)
sudo /xDrip/scripts/NS_Install3.sh
;;

5)
/xDrip/scripts/variables.sh
;;

6)
sudo /xDrip/scripts/clone_nightscout.sh
;;

7)
/xDrip/scripts/update_scripts.sh
;;

8)
/xDrip/scripts/backupmongo.sh
;;

9)
/xDrip/scripts/restoremongo.sh
;;

10)
clear
sudo /xDrip/scripts/ConfigureFreedns.sh
;;

11)
sudo /xDrip/scripts/update_nightscout.sh
;;

12)
dialog --yesno "Are you sure you want to reboot the server?\n
If you do, all unsaved open files will close without saving.\n"  8 50
response=$?
if [ $response = 255 ] || [ $response = 1 ]
then
clear
else
sudo reboot
fi
;;

13)
cd /tmp
clear
dialog --msgbox "You will now exit to the shell (terminal).\n\
To return to the menu, enter menu in the terminal." 7 54
clear
exit
;;

esac

done
 
