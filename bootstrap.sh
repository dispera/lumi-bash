#!/bin/bash

# Get the variables passed as arguments from ec2.sh
APP=$1
ENVIRONMENT=$2

# This is the IP of the Salt Master
SALT_MASTER_IP=192.168.3.230

# Add the Salt Master IP to our hosts file
# and alias as salt, so the salt minion file
# call to 'master: salt' resolves to our master.
echo "$SALT_MASTER_IP salt" >> /etc/hosts

# The Salt Master is configured to auto accept keys,
# for the purposes of this homework. It does not see
# the internet so all requests would be from our AWS VPC.

# Get latest salt bootstrap script and install saltstack

mkdir -p /etc/salt/
touch /etc/salt/minion

cat <<EOF > /etc/salt/minion
grains:
  env: $ENVIRONMENT
EOF

curl -L https://bootstrap.saltstack.com | sh

# Wait for salt to finish installing and for the minion
# key to be accepted on master.

TIMEOUT=120
COUNT=0
while [ ! -f /etc/salt/pki/minion/minion_master.pub ]; do
    echo "Waiting for salt install."
    if [ "$COUNT" -ge "$TIMEOUT" ]; then
        echo "minion_master.pub not detected by timeout"
        exit 1
    fi
    sleep 5
    COUNT=$((COUNT+5))
done


# Apply the salt state for our Application
echo "Calling Application: $APP"
salt-call state.apply $APP saltenv=$ENVIRONMENT

# Apply the salt highstate for the choonsen environment.
echo "Calling Salt Highstate"
salt-call state.highstate saltenv=$ENVIRONMENT

sudo ln -s /etc/nginx/sites-available/myapp /etc/nginx/sites-enabled

# We start the Gunicorn process for our Application,
# as we have added it to init with our gunicorn state.
sudo start webapp

exit 0

# sudo gunicorn --bind 0.0.0.0:8000 wsgi:app
