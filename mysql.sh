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
    echo -e " $R2 ... $R Failed $N "
    exit
    else
    echo -e "$2 ... $G Success $N "
    fi 
}

dnf module disable mysql -y  &>> $Logfile
VALIDATE $? "Disabling current mysql version"

cp mysql.repo  /etc/yum.repos.d/mysql.repo  &>> $Logfile
VALIDATE $? "Copying MySQL repo"

dnf install mysql-community-server -y  &>> $Logfile
VALIDATE $? "Installing MYSQL"

systemctl enable mysqld  &>> $Logfile
VALIDATE $? "Enabling MySQL Server"

systemctl start mysqld  &>> $Logfile
VALIDATE $? "Starting MySQL Server"

mysql_secure_installation --set-root-pass RoboShop@1  &>> $Logfile
VALIDATE $? "Setting MySQL Root password"



