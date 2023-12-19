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
echo -e "$R Roboshop user already exists  $Y SKIPPING \$N "
fi

mkdir -p /app  &>> $Logfile
VALIDATE $? "Creating App directory"

curl -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip  &>> $Logfile
VALIDATE $? "Downloading the Application code"

cd /app  &>> $Logfile
VALIDATE $? "Chanding the App directory"

unzip -o /tmp/user.zip  &>> $Logfile
VALIDATE $? "unzipping user"

npm install  &>> $Logfile
VALIDATE $? "Installing dependencies"

# use Absolute path, becuase user.service exists there
cp /home/centos/Roboshop/user.service /etc/systemd/system/user.service  &>> $Logfile
VALIDATE $? "Copying user service file"

systemctl daemon-reload &>> $Logfile
VALIDATE $? "user daemon reload"

systemctl enable user &>> $Logfile
VALIDATE $? "Enabling user"

systemctl start user &>> $Logfile
VALIDATE $? "Starting user"

cp /home/centos/Roboshop/mongo.repo /etc/yum.repos.d/mongo.repo &>> $Logfile
VALIDATE $? "Copying mongodb repo"

dnf install mongodb-org-shell -y  &>> $Logfile
VALIDATE $? "Installing Mongo DB Client"

mongo --host $MONGODB_Host </app/schema/user.js  &>> $Logfile
VALIDATE $? "Loading user data into MongoDB"

