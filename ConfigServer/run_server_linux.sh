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

sudo apt install python3-pip
pip install Django
pip install django-extensions Werkzeug


python3 manage.py migrate  >> /tmp/variables_log 2>&1

. /etc/free-dns.sh
CERT_LOCATION="/etc/letsencrypt/live/"$HOSTNAME

echo
echo PLEASE CONNECT TO https://$HOSTNAME:3389/variables?token=$ENV_TOKEN
echo

#python3 manage.py runserver 0.0.0.0:3389
python3 manage.py runserver_plus 0.0.0.0:3389 --cert-file $CERT_LOCATION/cert.pem --key-file $CERT_LOCATION/privkey.pem >> /tmp/variables_log 2>&1

