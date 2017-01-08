#!/bin/bash

# The arguments passed to the script will be:
# <app> <environment> <num_servers> <instance_type>

# AWS CLI Variables
APP=$1
ENVIRONMENT=$2
NUM_SERVERS=$3
INSTANCE_TYPE=$4
KEY_NAME=diego-key
SECURITY_GROUP=diego-flask-sg
# The ami-a73264ce is for us-east-1 region,
# this is for sa-east-1 region. EBS, 64 bit.
PRECISE_AMI=ami-35258228
USER_DATA="file://bootstrap.sh"
REGION=sa-east-1

# Now we create bootstrap.sh file. We will then use aws cli
# to pass it as user-data to our instances, at launch.
cat <<EOF > bootstrap.sh
#!/bin/bash -ex

# We add this so we can save the output of this script
# to the logs below and to syslog:
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

# Get the variables passed as arguments from ec2.sh
APP=$1
ENVIRONMENT=$2

# This is the IP of the Salt Master
SALT_MASTER_IP=172.31.13.129

# Add the Salt Master IP to our hosts file
# and alias as salt, so the salt minion file
# call to 'master: salt' resolves to our master.
echo "\$SALT_MASTER_IP salt" >> /etc/hosts

# The Salt Master is configured to auto accept keys,
# for the purposes of this homework. It does not see
# the internet so all requests would be from our AWS VPC.

# Get latest salt bootstrap script and install saltstack

mkdir -p /etc/salt/
touch /etc/salt/minion

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
echo "Saltstack: Calling application: $APP"
salt-call state.apply $APP saltenv=$ENVIRONMENT

# Apply the salt highstate for the choosen environment.
echo "Saltstack: Calling $ENVIRONMENT highstate"
salt-call state.highstate saltenv=$ENVIRONMENT

# We remove nginx default site as it conflicts with our app
rm /etc/nginx/sites-enabled/default

# We enable our app on nginx
ln -s /etc/nginx/sites-available/webapp /etc/nginx/sites-enabled

# We start the Gunicorn process for our Application,
# as we have added it to init with our gunicorn state.
sudo start webapp

# Restart nginx to apply the changes
service nginx restart

exit 0
EOF

# Example Instance launch:
# aws ec2 run-instances \
#   --image-id ami-35258228 \
#   --count 1 \
#   --instance-type t1.micro \
#   --key-name diego-key \
#   --security-groups diego-flask-sg \
#   --user-data "bootstrap.sh blogapp dev > /home/ubuntu/bootstrap.log" \
#   --region sa-east-1

aws ec2 run-instances \
    --image-id $PRECISE_AMI \
    --count $NUM_SERVERS \
    --instance-type $INSTANCE_TYPE \
    --key-name $KEY_NAME \
    --security-groups $SECURITY_GROUP \
    --user-data $USER_DATA \
    --region $REGION \
    > aws_run_log

echo "AWS Instance creation is in progress... waiting 5 minutes for the public IPs"
sleep 300

cat aws_run_log | grep InstanceId | cut -d ':' -f2 | cut -d '"' -f2 > instance_id_list

echo "\nThis are the public IPs of the EC2 instances:"
while read ID; do
  aws ec2 describe-instances --instance-ids $ID \
  | grep PublicIpAddress | cut -d ':' -f2 | cut -d '"' -f2
done <instance_id_list
