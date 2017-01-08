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
USER_DATA="bootstrap.sh $APP $ENVIRONMENT > /home/ubuntu/bootstrap.log"
REGION=sa-east-1

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
    --region $REGION

#rm ./INSTANCES_IPS 2>/dev/null
