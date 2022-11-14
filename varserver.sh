#!/bin/bash

dialog --colors --msgbox "     \Zr Developed the xDrip team \Zn\n\n\
You can use this utility if you use FreeDNS.  Copy the URL shown on the following page.  \
Paste it into a web browser.  You will have 15 minutes to edit your variables on that browser." 10 50

sudo /xDrip/ConfigServer/run_server_linux.sh
