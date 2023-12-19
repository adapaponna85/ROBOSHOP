#!/bin/bash
user=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"

MONGODB_Host=mongodb.apdevops.online
Timestamp=$(date +%F-%H-%M-%S)
Logfile="/tmp/$0-$Timestamp.log"
exec &>$Logfile

if [ $user -ne 0 ]
then
echo -e "$R Not an authorized user. Please login as Root user $N"
exit 1
else 
echo -e "$G Authorized user, proceeding.. $N "
fi

VALIDATE()
{
    if [ $1 -ne 0 ]
    then
    echo -e " $R $2 Failed $N "
    exit
    else
    echo -e "$G $2 Success $N "
    fi 
}

dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y
VALIDATE $? "Installing remi release"

dnf module enable redis:remi-6.2 -y
VALIDATE $? "Enabling redis"

dnf install redis -y
VALIDATE $? "Installing redis"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis.conf 
VALIDATE $? "Allowing remote connections"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf
VALIDATE $? "Allowing remote connections"

systemctl enable redis
VALIDATE $? "Enabled redis"

systemctl start redis
VALIDATE $? "Started redis"



