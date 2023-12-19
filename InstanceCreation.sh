#!/bin/bash

AMI=ami-03265a0778a880afb
SG_ID=sg-01833f2b4eac3f880

Instances=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "web")

for i in "${Instances[@]}"
do
echo "Instance is : $i"
if [ $i == "mongodb" ] || [ $i == "mysql" ] || [ $i == "shipping" ]
then
Instance_Type="t3.small"
else
Instance_Type="t2.micro"
fi
aws ec2 run-instances --image-id $AMI  --instance-type $Instance_Type  --security-group-ids $SG_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]"

done