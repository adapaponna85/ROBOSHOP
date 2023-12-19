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

curl -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip  &>> $Logfile
VALIDATE $? "Downloading the Application code"

cd /app  &>> $Logfile
VALIDATE $? "Chanding the App directory"

unzip -o /tmp/cart.zip  &>> $Logfile
VALIDATE $? "unzipping cart"

npm install  &>> $Logfile
VALIDATE $? "Installing dependencies"

# use Absolute path, becuase cart.service exists there
cp /home/centos/Roboshop/cart.service /etc/systemd/system/cart.service  &>> $Logfile
VALIDATE $? "Copying cart service file"

systemctl daemon-reload &>> $Logfile
VALIDATE $? "cart daemon reload"

systemctl enable cart &>> $Logfile
VALIDATE $? "Enabling cart"

systemctl start cart &>> $Logfile
VALIDATE $? "Starting cart"





