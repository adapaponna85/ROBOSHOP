#!/bin/bash
user=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"

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

dnf install maven -y &>> $Logfile
VALIDATE $? "Installing Maven"

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

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip  &>> $Logfile
VALIDATE $? "Downloading Shipping directory"

cd /app  &>> $Logfile
VALIDATE $? "Changing App directory"

unzip /tmp/shipping.zip  &>> $Logfile
VALIDATE $? "Unzipping Shipping"

mvn clean package  &>> $Logfile
VALIDATE $? "Installing dependencies"

mv target/shipping-1.0.jar shipping.jar  &>> $Logfile
VALIDATE $? "Renaming jar file"

cp /home/centos/Roboshop/shipping.service /etc/systemd/system/shipping.service  &>> $Logfile
VALIDATE $? "Copying Shipping service"

systemctl daemon-reload  &>> $Logfile
VALIDATE $? "Daemon reload"

systemctl enable shipping   &>> $Logfile
VALIDATE $? "Enable Shipping"

systemctl start shipping  &>> $Logfile
VALIDATE $? "Start Shipping"

dnf install mysql -y  &>> $Logfile
VALIDATE $? "Install MYSQL Client"

mysql -h mysql.apdevops.online -uroot -pRoboShop@1 < /app/schema/shipping.sql  &>> $Logfile
VALIDATE $? "Loading Shippinh Data"

systemctl restart shipping
VALIDATE $? "Restart Shipping"
