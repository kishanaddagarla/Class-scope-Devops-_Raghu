#!/bin/bash

LOG=/tmp/stack.log 
rm -f $LOG 
R="\e[31m"
G="\e[32m"
C="\e[36m"
N="\e[0m"

HEAD() {
    echo -e "\e[1;33m$1${N}\n"
}

Info() {
    echo -n -e "\t-> ${C}$1${N} - "
}

Stat() {
    if [ $? -eq 0 ]; then 
        echo -e "${G}SUCCESS${N}"
    else
        echo -e "${R}FAILURE${N}"
        echo "Check the log file for the error, Location of log file is $LOG"
        exit 1
    fi
}


### Main Program 
USER_ID=$(id -u)
if  [ $USER_ID -ne 0 ] ; then 
    echo -e "${R}You need to be a root user to perform this script${N}"
    exit 1
fi

HEAD "DB COMPONENT SETUP"
Info "Installing MariaDB Server"
yum install mariadb-server -y &>>$LOG 
Stat $?

systemctl enable mariadb &>>$LOG 
Info "Starting MariaDB Server"
systemctl start mariadb &>>$LOG  
Stat $?

echo "create database if not exists studentapp;
use studentapp;
CREATE TABLE if not exists Students(student_id INT NOT NULL AUTO_INCREMENT,
	student_name VARCHAR(100) NOT NULL,
    student_addr VARCHAR(100) NOT NULL,
	student_age VARCHAR(3) NOT NULL,
	student_qual VARCHAR(20) NOT NULL,
	student_percent VARCHAR(10) NOT NULL,
	student_year_passed VARCHAR(10) NOT NULL,
	PRIMARY KEY (student_id)
);
grant all privileges on studentapp.* to 'student'@'%' identified by 'student@1';
flush privileges;" >/tmp/student.sql 

Info "Configuring Databases"
mysql </tmp/student.sql &>>$LOG 
Stat $?

exit
HEAD "APP COMPONENT SETUP"
Info "Installing Tomcat Server"

HEAD "WEB COMPONENT SETUP"
Info "Installing HTTPD Server"
Info "Starting HTTPD Server"
