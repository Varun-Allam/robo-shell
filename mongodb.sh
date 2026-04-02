#!/bin/bash

USERID=$(id -u) 
R="\e[31m" 
G="\e[32m"
Y="\e[33m" 
N="\e[0m"  


LOGS_FOLDER="/var/log/robo-shell" 
SCRIPT_NAME=$( echo $0 | cut -d '.' -f1 )
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log" 

mkdir -p $LOGS_FOLDER 

echo "Script started execute at : $(date)" | tee -a $LOG_FILE

if [ $USERID -ne 0 ]; then 
    echo -e "$R ERROR $N" 
    exit 1 #Fail other than zero
fi 


VALIDATE(){
    if [ $1 -ne 0 ]; then 
        echo -e "$R ERROR $2 $N" | tee -a $LOG_FILE
        exit 2 
    else 
        echo -e "$G  success $N" | tee -a $LOG_FILE
    fi
} 


cp mongo.repo /etc/yum.repos.d/mongo.repo 
VALIDATE $? "Adding mongo repo" 

dnf install mongodb-org -y &>>$LOG_FILE 
VALIDATE $? "installing mongodb" 



systemctl enable mongod &>>$LOG_FILE 
VALIDATE $? "enable mongodb" 

systemctl start mongod &>>$LOG_FILE 
VALIDATE $? "start mongodb" 
