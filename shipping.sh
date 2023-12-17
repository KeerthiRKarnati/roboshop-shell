#!/bin/bash

ID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

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

dnf install maven -y &>> $LOGFILE

VALIDATE $? "Installing maven"

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

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $LOGFILE

VALIDATE $? "Downloading shipping application"

cd /app &>> $LOGFILE

VALIDATE "Moving to app directorty"

unzip -o /tmp/shipping.zip &>> $LOGFILE

VALIDATE $? "Unzipping the shipping application"

mvn clean package &>> $LOGFILE

VALIDATE $? "Downloading the dependencies"

mv target/shipping-1.0.jar shipping.jar &>> $LOGFILE

VALIDATE $? "Renaming the jar file"

cp /home/centos/roboshop-shell/shipping.service /etc/systemd/system/shipping.service &>> $LOGFILE

VALIDATE $? "Copying shipping services"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "Shipping Daemon reloading"

systemctl enable shipping &>> $LOGFILE

VALIDATE $? "Enabling shipping services"

systemctl start shipping &>> $LOGFILE

VALIDATE $? "Starting shipping services"

dnf install mysql -y &>> $LOGFILE
 
VALIDATE $? "Installing mysql client"

mysql -h mysql.aiawsdevops.online -uroot -pRoboShop@1 < /app/schema/shipping.sql &>> $LOGFILE

VALIDATE $? "Loading data to mysql server"

systemctl restart shipping &>> $LOGFILE

VALIDATE $? "Restarting the shipping services"

#check netstat -lntp
#check sudo less /var/log/messages

