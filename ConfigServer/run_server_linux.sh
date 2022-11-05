#!/bin/bash
if [ "`id -u`" != "0" ]
then
echo "Script needs root - pleass run sudo ./run_server_linux.sh"
echo "Cannot continue.."
exit 5
fi


export SECRET_KEY=$(uuidgen)
export ENV_DEBUG=False
export ENV_TOKEN=$(uuidgen)
export NS_CONFIG_FILE=/etc/nsconfig

sudo apt-get -y install python3-pip
pip install Django
pip install django-extensions Werkzeug
pip install qrcode

. /etc/free-dns.sh
python3 manage.py migrate  >> /tmp/variables_log 2>&1

#make sure to put this after the migrate, as the migrate might fail.
export KILL_AFTER_IDLE_TIME=900

CERT_LOCATION="/etc/letsencrypt/live/"$HOSTNAME

echo
echo PLEASE CONNECT TO https://$HOSTNAME:3389/variables?token=$ENV_TOKEN
echo "The server will run for 15 minutes, and after that will stop (if not used). Press ctrl C to stop it before that."
echo

#python3 manage.py runserver 0.0.0.0:3389  >> /tmp/variables_log 2>&1
python3 manage.py runserver_plus 0.0.0.0:3389 --cert-file $CERT_LOCATION/cert.pem --key-file $CERT_LOCATION/privkey.pem >> /tmp/variables_log 2>&1
