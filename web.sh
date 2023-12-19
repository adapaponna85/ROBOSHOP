#!/bin/bash
user=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"

MONGODB_Host=mongodb.apdevops.online
Timestamp=$(date +%F-%H-%M-%S)
Logfile="/tmp/$0-$Timestamp.log"

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
    echo -e " $R2 ... $R Failed $N "
    exit
    else
    echo -e "$2 ... $G Success $N "
    fi 
}


dnf install nginx -y
VALIDATE $? "Installing nginx"

systemctl enable nginx
VALIDATE $? "Enabling nginx"

systemctl start nginx
VALIDATE $? "Starting nginx"

rm -rf /usr/share/nginx/html/*
VALIDATE $? "Removing default content"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip
VALIDATE $? "Downloading web application"

cd /usr/share/nginx/html
VALIDATE $? "Moving to nginx html directory"

unzip /tmp/web.zip
VALIDATE $? "Unzipping web"

cp /home/centos/Roboshop/roboshop.conf /etc/nginx/default.d/roboshop.conf
VALIDATE $? "Copied Roboshop Reverse Proxy Config"

systemctl restart nginx
VALIDATE $? "Restarted nginx"
