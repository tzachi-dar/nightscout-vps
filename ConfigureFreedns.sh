sudo apt-get install bind9-dnsutils
apt-get install cron

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
#echo "*/5 * * * * root sleep 12 ; /usr/bin/update_freedns.sh >> /tmp/freedns.log 2>&1" > /etc/cron.d/freedns
echo "* * * * * root sleep 12 ; /usr/bin/update_freedns.sh >> /tmp/freedns.log 2>&1" > /etc/cron.d/freedns

sudo certbot --nginx -d "$hostname" --redirect 