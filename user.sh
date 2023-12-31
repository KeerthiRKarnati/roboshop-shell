#!/bin/bash

ID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
MongoDB_Host=mongodb.aiawsdevops.online

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

id roboshop #if we use set -e it will be failure here because roboshop user does not exist 
if [ $? -ne 0 ]
then
    useradd roboshop &>> $LOGFILE
    VALIDATE $? "roboshop user creation"
else 
    echo -e "roboshop user already exist $Y SKIPPING $N"
fi

mkdir -p /app &>> $LOGFILE #-p means, if dir already exists - doesn't create, if not exist - create dir

VALIDATE $? "Creating app directory"

curl -L -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>> $LOGFILE

VALIDATE $? "Downloading User application"

cd /app &>> $LOGFILE

VALIDATE $? "Entering into app directory"

unzip -o /tmp/user.zip &>> $LOGFILE #-o means overwrite the data

VALIDATE $? "Unzipping the user application"

npm install &>> $LOGFILE

VALIDATE $? "Installing Dependencies"

cp /home/centos/roboshop-shell/user.service /etc/systemd/system/user.service &>> $LOGFILE # Currently, we are in app directory but catalogue.service app was downloaded in roboshop-shell so give absolute path

VALIDATE $? "Copying user service file"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "user Daemon reloading"

systemctl enable user &>> $LOGFILE

VALIDATE $? "Enabling user application"

systemctl start user &>> $LOGFILE

VALIDATE $? "Starting user application"

cp /home/centos/roboshop-shell/mongodb.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

VALIDATE $? "Copying mongo repo"

dnf install mongodb-org-shell -y &>> $LOGFILE

VALIDATE $? "Installing MongoDB Client"

mongo --host $MongoDB_Host </app/schema/catalogue.js &>> $LOGFILE

VALIDATE $? "Loading user data into Mongo DB"

#check netstat -lnpt
#check sudo less /var/log/messages
