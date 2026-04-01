#!/bin/bash 

AMI_ID="ami-0220d79f3f480ecf5" 
SG_ID="sg-0e2dffc85a2dd9b4b" 

for instance in $@ #$@ is taking dynamically 
do 
    INSTANCE_ID=$( aws ec2 run-instances --image-id ami-0220d79f3f480ecf5 --instance-type t3.micro --security-group-ids sg-0e2dffc85a2dd9b4b --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=Test}]' --query 'Instances[0].InstanceId' --output text ) 

    if [ $instance != "frontend" ]; then
        IP=$( aws ec2 describe-instances \
  --instance-ids i-029ca58cbd2792c2b \
  --query 'Reservations[0].Instances[0].PrivateIpAddress' \
  --output text ) 

    else 
        IP=$( aws ec2 describe-instances \
  --instance-ids i-029ca58cbd2792c2b \
  --query 'Reservations[0].Instances[0].PublicIpAddress' \
  --output text )
    fi 

    echo "$instance:$IP" 
done