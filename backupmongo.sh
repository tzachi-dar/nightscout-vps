#!/bin/bash

echo
echo "Backing up the mongoDB database - tzachi-dar"
echo

while :
do
exec 3>&1
Filename=$(dialog --colors --ok-label "Submit" --form "       \Zr Developed by the xDrip team \Zn\n\n\n\
Enter a name for the backup file" 11 50 0 "file name" 1 1 "$filename" 1 14 25 0 2>&1 1>&3)
 response=$?
if [ $response = 255 ] || [ $response = 1 ]
then
clear
exit
fi

if [ -s $Filename ]
then
dialog --colors --msgbox "       \Zr Developed by the xDrip team \Zn\n\n\n\
A file with the same name exists.\n\
Choose a different filename." 9 50
clear
else
mongodump --gzip --archive=/tmp/database.gz
exec 3>&-
cd /tmp
cp /etc/nsconfig .
tar -cf ~/$Filename database.gz nsconfig

dialog --colors --msgbox "       \Zr Developed by the xDrip team \Zn\n\n\n\
Backup is complete.\n\
However, it is on the same virtual machine that your database and variables are on.  It's best to download the file to your computer for safekeeping.\n\
See the guide for how to download." 13 50
clear
exit
fi
done
 
