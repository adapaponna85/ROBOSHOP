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

curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash   &>> $Logfile
VALIDATE $? "Downlaoding erlang script"

curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash   &>> $Logfile
VALIDATE $? "Downloading rabbitmq script"

dnf install rabbitmq-server -y  &>> $Logfile
VALIDATE $? "Installing rabbitmq server"

systemctl enable rabbitmq-server   &>> $Logfile
VALIDATE $? "Enabling rabbitmq server"

systemctl start rabbitmq-server  &>> $Logfile
VALIDATE $? "Starting rabbitmq server"

rabbitmqctl add_user roboshop roboshop123  &>> $Logfile
VALIDATE $? "Adding Roboshop user"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"   &>> $Logfile
VALIDATE $? "Setting permissions Nodejs"