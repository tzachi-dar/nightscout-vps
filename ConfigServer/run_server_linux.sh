#!/bin/bash
export SECRET_KEY=$(uuidgen)
export ENV_DEBUG=False 
export ENV_TOKEN=$(uuidgen)
export NS_CONFIG_FILE=/etc/nsconfig

python3 manage.py migrate

pip install django-extensions Werkzeug

. /etc/free-dns.sh
CERT_LOCATION="/etc/letsencrypt/live/"$HOSTNAME

echo PLEASE CONNECT TO:
echo https://$HOSTNAME:3389/variables?token=$ENV_TOKEN


#python3 manage.py runserver 0.0.0.0:3389
python3 manage.py runserver_plus 0.0.0.0:3389 --cert-file $CERT_LOCATION/cert.pem --key-file $CERT_LOCATION/privkey.pem

