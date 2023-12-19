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

dnf install python36 gcc python3-devel -y   &>> $Logfile
VALIDATE $? "Installing  Python"

# checking if Roboshop user already exists or not and then creating if does not exist
id roboshop
if [ $? -ne 0 ]
then
useradd roboshop
VALIDATE $? "Roboshop user creation"
else
echo -e "$R Roboshop user already exists  $Y SKIPPING \$N "
fi

mkdir /app   &>> $Logfile
VALIDATE $? "Making App directory"

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip   &>> $Logfile
VALIDATE $? "Downloading Payment"


cd /app  &>> $Logfile
VALIDATE $? "Chanding App directory"

unzip /tmp/payment.zip  &>> $Logfile
VALIDATE $? "Unzipping Payment"

cd /app  &>> $Logfile
VALIDATE $? "Changing App directory"

pip3.6 install -r requirements.txt  &>> $Logfile
VALIDATE $? "Installing pip3" 

cp /home/centos/Roboshop/payment.service /etc/systemd/system/payment.service  &>> $Logfile
VALIDATE $? "Copying Payment service"


systemctl daemon-reload   &>> $Logfile
VALIDATE $? "Reloading daemon"

systemctl enable payment   &>> $Logfile
VALIDATE $? "Enabling Payment"

systemctl start payment  &>> $Logfile
VALIDATE $? "Starting Payment"
