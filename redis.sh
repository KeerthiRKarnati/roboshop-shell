#!/bin/bash

ID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

exec &>$LOGFILE #everything will be stored in logfile(echo,...   )

echo -e "Script started executed at $Y $TIMESTAMP $N"

VALIDATE(){
    if [ $1 -ne 0 ]
    then 
        echo  -e "Error:: $2 ... $R FAILED $N"
        exit 1 #if error arises you can't proceed, give other than zero
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

if [ $ID -ne 0 ]
then 
    echo -e "$R Error:: Please run the script with root user $N"
    exit 1 #if error arises you can't proceed, give other than zero
else
    echo -e "You are $G root $N user"
fi

dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y

VALIDATE $? "Installing Remi release"

dnf module enable redis:remi-6.2 -y

VALIDATE $? "Enabling Redis"

dnf install redis -y

VALIDATE $? "Installing Redis"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf

VALIDATE $? "Allowing remote connections"

systemctl enable redis

VALIDATE $? "Enabling Redis"

systemctl start redis

VALIDATE $? "Starting Redis"

#check netstat -lntp
