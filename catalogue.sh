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

dnf module disable nodejs -y &>> $LOGFILE

VALIDATE $? "Disabling current version of nodejs"

dnf module enable nodejs:18 -y &>> $LOGFILE

VALIDATE $? "Enabling Nodejs 18"

dnf install nodejs -y &>> $LOGFILE

VALIDATE $? "Installing Nodejs 18"

id roboshop
if [ $? -ne 0 ]
then
    useradd roboshop &>> $LOGFILE
    VALIDATE $? "roboshop user creation"
else 
    echo -e "roboshop user already exist $Y SKIPPING $N"
fi

mkdir -p /app &>> $LOGFILE #-p means, if dir already exists - doesn't create, if not exist - create dir

VALIDATE $? "Creating app directory"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE

VALIDATE $? "Downloading Catalogue application"

cd /app &>> $LOGFILE

VALIDATE $? "Entering into app directory"

unzip -o /tmp/catalogue.zip &>> $LOGFILE #-o means overwrite the data

VALIDATE $? "Unzipping the catalogue application"

npm install &>> $LOGFILE

VALIDATE $? "Installing Dependencies"

cp /home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service &>> $LOGFILE# Currently, we are in app directory but catalogue.service app was downloaded in roboshop-shell so give absolute path

VALIDATE $? "Copying catalogue service file"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "Catalogue Daemon reloading"

systemctl enable catalogue &>> $LOGFILE

VALIDATE $? "Enabling catalogue application"

systemctl start catalogue &>> $LOGFILE

VALIDATE $? "Starting catalogue application"

cp /home/centos/roboshop-shell/mongodb.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

VALIDATE $? "Copying mongo repo"

dnf install mongodb-org-shell -y &>> $LOGFILE

VALIDATE $? "Installing MongoDB Client"

mongo --host $MongoDB_Host </app/schema/catalogue.js &>> $LOGFILE

VALIDATE $? "Loading catalogue data into Mongo DB"


