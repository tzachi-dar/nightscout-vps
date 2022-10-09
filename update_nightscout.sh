#!/bin/bash

echo
echo "Install Nightscout again, from the official repository or from a fork"
echo


if [ "`id -u`" != "0" ]
then
echo "Script needs root - execute bootstrap.sh or use sudo bash installation.sh"
echo "Cannot continue.."
exit 5
fi

if [ ! -s /var/SWAP ]
then
echo "Creating swap file"
dd if=/dev/zero of=/var/SWAP bs=1M count=2000
chmod 600 /var/SWAP
mkswap /var/SWAP
fi
swapon 2>/dev/null /var/SWAP

echo "Installing system basics"
sudo apt-get update
sudo apt-get -y install dialog

echo -e "use Nightscout\ndb.createUser({user: \"username\", pwd: \"password\", roles:[\"readWrite\"]})\nquit()" | mongo

cd /srv
# Setting the defaults
user="nightscout"
repo="cgm-remote-monitor"
brnch="master"

clear #  Clear the screen before placing the next dialog one.
dialog --yesno "You can reeinstall Nightscout.\n\n
Choose Yes to install the latest version of official Nightscout.\n\n
Choose No to install from a fork you can specify (advanced).\n\n
Or, press escape to cancel." 14 50
ans=$?
if [ $ans = 255 ] # Exit if escape is pressed.
then
clear # Clear the screen before exiting.
exit 5
elif [ $ans = 1 ] # We need Github details
then
# So, let's clear these first.
user=""
repo=""
brnch=""

# open fd
exec 3>&1

# Now, let's ask for the details of the fork
# Store data to $VALUES variable
clear # Clear the screen before placing the next dialog on.
VALUES=$(dialog --ok-label "Submit" --form "Enter the GitHub details for the Nightscout version you want to install.\n" 12 50 0 "User ID:" 1 1 "$user" 1 14 25 0 "Repository:" 2 1 "$repo" 2 14 25 0 "Branch:" 3 1 "$brnch" 3 14 25 0 2>&1 1>&3)
ans2=$?
if [ $ans2 = 255 ] || [ $ans2 = 1 ] # Exit if escaped or cancelled
then
clear # Clear the screen before existing.
exit 5
fi

# close fd
exec 3>&-

# display values just entered
#echo "$VALUES"
user=$(echo "$VALUES" | sed -n 1p)
repo=$(echo "$VALUES" | sed -n 2p)
brnch=$(echo "$VALUES" | sed -n 3p)
fi
clear  # Clear the last dialog

if [ -s ./$repo ] # Delete the repository directory if it exists.
then
sudo rm -r $repo
fi

combined="https://github.com/$user/$repo.git" # This is the path to the repository we are installing from
sudo git clone $combined

# Kill Nightscout
sudo pkill -f SCREEN
cd $repo
sudo git checkout $brnch
sudo git pull

sudo npm install
sudo npm run postinstall
sudo npm run generate-keys

for loop in 1 2 3 4 5 6 7 8 9
do
read -t 0.1 dummy
done

if [ ! -s /usr/local/etc/no-ip2.conf ]
then
cd /usr/src
sudo tar -xzf /srv/nightscout-vps/helper/noip-duc-linux.tar.gz
cd /usr/src/noip-2.1.9-1
sudo make install
else
echo "Noip client already installed - delete /usr/local/etc/no-ip2.conf if you want to change config"
fi
noip2 -S

hostname=`noip2 -S 2>&1 | grep host | tr -s ' ' | tr -d '\t' | cut -f2 -d' ' | head -1`

if [ "$hostname" = "" ]
then
echo "Could not determine host name - did no ip dynamic dns install fail?"
echo "Cannot continue!"
exit 5
fi

# execute installer
noip2

sudo apt-get install -y nginx python3-certbot-nginx inetutils-ping

if [ "`grep '.well-known' /etc/nginx/sites-enabled/default`" = "" ]
then
sudo rm -f /tmp/nginx.conf
sudo grep -v '^#' /etc/nginx/sites-enabled/default >/tmp/nginx.conf

cat /tmp/nginx.conf | sed -z -e 'sZlocation / {[^}]*}Zlocation /.well-known {\n        try_files $uri $uri/ =404;\n}\n\nlocation / {\nproxy_pass  http://127.0.0.1:1337/;\nproxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;\nproxy_set_header X-Forwarded-Proto https;\nproxy_http_version 1.1;\nproxy_set_header Upgrade $http_upgrade;\nproxy_set_header Connection "upgrade";\n}Zg' >/etc/nginx/sites-enabled/default

sudo service nginx stop

else
echo "Nginx config already patched"
fi

sudo service nginx start
sudo certbot --nginx -d "$hostname"

sudo systemctl daemon-reload
sudo systemctl start mongodb


cat> /etc/nightscout-start.sh<<EOF

#!/bin/sh
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
. /etc/nsconfig
export MONGO_COLLECTION="entries"
export MONGO_CONNECTION="mongodb://username:password@localhost:27017/Nightscout"
export INSECURE_USE_HTTP=true
export HOSTNAME="127.0.0.1"
export PORT="1337"
cd /srv/$repo
EOF

cat>> /etc/nightscout-start.sh<< "EOF"

while [ "`netstat -lnt | grep 27017 | grep -v grep`" = "" ]
do
echo "Waiting for mongo to start"
sleep 5
done
sleep 5
while [ 1 ]
do
node server.js
sleep 30
done
EOF
