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

dnf module disable nodejs -y

VALIDATE $? "Disabling current version of nodejs"

dnf module enable nodejs:18 -y

VALIDATE $? "Enabling Nodejs 18"

dnf install nodejs -y

VALIDATE $? "Installing Nodejs 18"

useradd roboshop 

VALIDATE $? "Creating user roboshop"

mkdir /app

VALIDATE $? "Creating app directory"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip

VALIDATE $? "Downloading Catalogue application"

cd /app 

VALIDATE $? "Entering into app directory"

unzip /tmp/catalogue.zip

VALIDATE $? "Unzipping the catalogue application"

npm install 

VALIDATE $? "Installing Dependencies"

cp /home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service # Currently, we are in app directory but catalogue.service app was downloaded in roboshop-shell so give absolute path

VALIDATE $? "Copying catalogue service file"

systemctl daemon-reload

VALIDATE $? "Catalogue Daemon reloading"

systemctl enable catalogue

VALIDATE $? "Enabling catalogue application"

systemctl start catalogue

VALIDATE $? "Starting catalogue application"

cp /home/centos/roboshop-shell/mongodb.repo /etc/yum.repos.d/mongo.repo

VALIDATE $? "Copying mongo repo"

dnf install mongodb-org-shell -y

VALIDATE $? "Installing MongoDB Client"

mongo --host $MongoDB_Host </app/schema/catalogue.js

VALIDATE $? "Loading catalogue data into Mongo DB"


