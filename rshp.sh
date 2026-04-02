#!/bin/bash 

AMI_ID="ami-0220d79f3f480ecf5" 
SG_ID="sg-0e2dffc85a2dd9b4b" 
DOMAIN_NAME="sandhya.fun" 
HOST_ZONE_ID="Z07101602FRRRZHC331MP"


for instance in "$@"   # take dynamic inputs
do 
    #echo "Creating instance: $instance"

    INSTANCE_ID=$(aws ec2 run-instances \
        --image-id $AMI_ID \
        --instance-type t3.micro \
        --security-group-ids $SG_ID \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
        --query 'Instances[0].InstanceId' \
        --output text)

    #echo "Instance ID: $INSTANCE_ID"

    # wait until instance is running
    aws ec2 wait instance-running --instance-ids $INSTANCE_ID

    if [ "$instance" != "frontend" ]; then
        IP=$(aws ec2 describe-instances \
            --instance-ids $INSTANCE_ID \
            --query 'Reservations[0].Instances[0].PrivateIpAddress' \
            --output text)
        RECORD_NAME="$instance.$DOMAIN_NAME" 
    else 
        IP=$(aws ec2 describe-instances \
            --instance-ids $INSTANCE_ID \
            --query 'Reservations[0].Instances[0].PublicIpAddress' \
            --output text)
        RECORD_NAME="$DOMAIN_NAME"
    fi 

    echo "$instance: $IP" 
    #echo "-----------------------------"

    aws route53 change-resource-record-sets \
    --hosted-zone-id $HOST_ZONE_ID \
    --change-batch '{
        "Changes": [{
        "Action": "UPSERT",
        "ResourceRecordSet": {
            "Name": "'$RECORD_NAME'",
            "Type": "A",
            "TTL": 1,
            "ResourceRecords": [{"Value": "'$IP'"}]
        }
        }]
    }'



done