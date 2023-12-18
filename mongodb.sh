#!/bin/bash
user=$(id -u)
R="e\[31m"
G="e\[32m"
Y="e\[33m"
N="e\[0m"

Timestamp=$(date +%F-$H-$M-$S")
Logfile="($0-$Timestamp.log)"

if [ $user -ne 0 ]
then
echo -e " $R Unauthorized user! Please login as root user to proceed.. $N "
else
echo -e " $G Authorized user! Proceeding.. $N  "
fi

