#!/bin/bash

dialog --colors --msgbox "     \Zr Developed the xDrip team \Zn\n\n\
Copy the URL shown on the following page.  Paste it into a web browser.  You will have 15 minutes to edit your variables on that browser." 10 50
clear

sudo /xDrip/ConfigServer/run_server_linux.sh
sleep 60
 
