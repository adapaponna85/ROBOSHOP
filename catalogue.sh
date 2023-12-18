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
    echo -e " $R $2 Failed $N "
    exit
    else
    echo -e "$G $2 Success $N "
    fi 
}

dnf module disable nodejs -y &>> $Logfile
VALIDATE $? "Disabling Nodejs"

dnf module enable nodejs:18 -y &>> $Logfile
VALIDATE $? "Enabling Nodejs"

dnf install nodejs -y &>> $Logfile
VALIDATE $? "Installing Nodejs"

# checking if Roboshop user already exists or not and then creating if does not exist
id roboshop
if [ $? -ne 0 ]
then
useradd roboshop
VALIDATE $? "Roboshop user creation"
else
echo -e "\R Roboshop user already exists  $Y SKIPPING \N "
fi

mkdir -p /app  &>> $Logfile
VALIDATE $? "Creating App directory"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip  &>> $Logfile
VALIDATE $? "Downloading the Application code"

cd /app  &>> $Logfile
VALIDATE $? "Chanding the App directory"

unzip -o /tmp/catalogue.zip  &>> $Logfile
VALIDATE $? "unzipping catalogue"

npm install  &>> $Logfile
VALIDATE $? "Installing dependencies"

# use Absolute path, becuase catalogue.service exists there
cp /home/centos/Roboshop/catalogue.service /etc/systemd/system/catalogue.service  &>> $Logfile
VALIDATE $? "Copying catalogue service file"

systemctl daemon-reload &>> $Logfile
VALIDATE $? "catalogue daemon reload"

systemctl enable catalogue &>> $Logfile
VALIDATE $? "Enabling catalogue"

systemctl start catalogue &>> $Logfile
VALIDATE $? "Starting catalogue"

cp /home/centos/Roboshop/mongo.repo /etc/yum.repos.d/mongo.repo &>> $Logfile
VALIDATE $? "Copying mongodb repo"

dnf install mongodb-org-shell -y  &>> $Logfile
VALIDATE $? "Installing Mongo DB Client"

mongo --host $MONGODB_Host </app/schema/catalogue.js  &>> $Logfile
VALIDATE $? "Loading Catalogue data into MongoDB"




