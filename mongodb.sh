#!/bin/bash
user=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

Timestamp=$(date +%F-%H-%M-%S)
Logfile="/tmp/$0-$Timestamp.log"

VALIDATE()
{
    if [ $? -ne 0 ]
    then
    echo -e "$R $2 Error $N"
    exit 1
    else
    echo -e "$G $2 Success $N"
    fi
}

if [ $user -ne 0 ]
then
echo -e " $R Unauthorized user! Please login as root user to proceed.. $N"
else
echo -e " $G Authorized user! Proceeding.. $N"
fi

cp mongo.repo /etc/yum.repos.d/ &>> Logfile
VALIDATE $? "Copying mongo.repo file"

dnf install mongodb-org -y &>> Logfile
VALIDATE $? "Installing MONGODB"

systemctl enable mongod &>> Logfile
VALDIATE $? "Enabling MONGODB"

systemctl start mongod &>> Logile
VALIDATE $? "Starting MONGODB"

sed -i "s/127.0.0.1/0.0.0.0/g" /etc/mongod.conf &>> Logfile
VALIDATE $? "Remote Access to MONGODB" 

systemctl restart mongod &>> Logfile
VALIDATE $? "Restarting MONGODB"

