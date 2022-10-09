#!/bin/bash

echo
echo "Move to use free dns instead of noip.com"
echo


if [ "`id -u`" != "0" ]
then
echo "Script needs root - execute bootstrap.sh or use sudo bash installation.sh"
echo "Cannot continue.."
exit 5
fi

sudo apt-get install bind9-dnsutils -y
sudo apt-get install cron

read -rep "Please enter host name (for example mynightscoute.mooo.com) "$'\n'"hostname: " hostname
read -rep "please enter direct url. Should look like https://freedns.afraid.org/dynamic/update.php?d005WVNjWkE3aDhyWkJpa1h1cFZiOUV5OjIwNzQ4NTY1 "$'\n'" direct_url: " directurl

#create a file to store the data for the chron tab script.
cat> /etc/free-dns.sh<<EOF
#!/bin/sh
export HOSTNAME=$hostname
export DIRECTURL=$directurl
EOF

#Create the file for the crontab itself

cat> /usr/bin/update_freedns.sh<<EOF
#!/bin/sh

#FreeDNS updater script

. /etc/free-dns.sh
registered=\$(nslookup \$HOSTNAME|tail -n2|grep A|sed s/[^0-9.]//g)

current=\$(wget -q -O - http://checkip.dyndns.org|sed s/[^0-9.]//g)
echo \$current \$registered
       [ "\$current" != "\$registered" ] && {                           
          wget -q -O /dev/null \$DIRECTURL 
          echo "DNS updated on:"; date
  }
EOF

chmod +x /usr/bin/update_freedns.sh

#create the chrontab itself
echo "* * * * * root sleep 12 ; /usr/bin/update_freedns.sh >> /tmp/freedns.log 2>&1" > /etc/cron.d/freedns

#Start the first update immediately
wget -O - $directurl

# wait for the ip to be updated. This might take up to 10 minutes.

while : ; do
    sleep 30
    registered=$(nslookup $hostname|tail -n2|grep A|sed s/[^0-9.]//g)
    current=$(wget -q -O - http://checkip.dyndns.org|sed s/[^0-9.]//g)
    echo $current $registered
    [[ "$registered" != "$current" ]] || break
done

#Fix the certificate using the new host name.
sudo certbot --nginx -d "$hostname" --redirect 