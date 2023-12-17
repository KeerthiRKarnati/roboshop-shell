#!/bin/bash

ID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
MongoDB_Host = mongodb.aiawsdevops.online

echo -e "Script started executed at $Y $TIMESTAMP $N" &>> $LOGFILE

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

dnf install nginx -y

VALIDATE $? "Installing Nginx"

systemctl enable nginx

VALIDATE $? "Enabling nginx"

systemctl start nginx

VALIDATE $? "Starting nginx"

rm -rf /usr/share/nginx/html/*

VALIDATE $? "Removing default content in we browser"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip

VALIDATE $? "Downloading Web application"

cd /usr/share/nginx/html

VALIDATE $? "Moving  into nginx (/usr/share/nginx/html) directory"

unzip -o /tmp/web.zip

VALIDATE $? "Unzipping the web application"

cp /home/centos/roboshop-shell/roboshop.conf /etc/nginx/default.d/roboshop.conf

VALIDATE $? "Copying roboshop reverse proxy conf" 

systemctl restart nginx 

VALIDATE $? "Restarted nginx"

#check netstat -lntp
#check sudo less /var/log/messages


