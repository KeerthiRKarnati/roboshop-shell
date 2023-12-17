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

dnf install python36 gcc python3-devel -y &>> $LOGFILE

VALIDATE $? "Installing python"

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

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>> $LOGFILE

VALIDATE $? "Downloading payment application"

cd /app &>> $LOGFILE

VALIDATE $? "Moving to app directory"

unzip -o /tmp/payment.zip &>> $LOGFILE

VALIDATE $? "Unzipping the Payment application"

pip3.6 install -r requirements.txt &>> $LOGFILE

VALIDATE $? "Install Dependencies"

cp /home/centos/roboshop-shell/payment.service /etc/systemd/system/payment.service &>> $LOGFILE # Currently, we are in app directory but catalogue.service app was downloaded in roboshop-shell so give absolute path

VALIDATE $? "Copying payment service file"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "Payment Daemon reloading"

systemctl enable payment &>> $LOGFILE 

VALIDATE $? "Enabling payment services"

systemctl start payment &>> $LOGFILE

VALIDATE $? "Starting Payment services"

#check netstat -lnpt
#check sudo less /var/log/messages