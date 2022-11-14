#!/bin/bash

dialog --colors --msgbox "     \Zr Developed the xDrip team \Zn\n\n\
You can use this utility only if you use FreeDNS.\n\n\
Copy the URL shown on the following page.  Paste it into a web browser.  You will have 15 minutes to edit your variables on that browser." 11 50

sudo /xDrip/ConfigServer/run_server_linux.sh
 
