#!/bin/bash

# Run template and pass environment variables set via session or leave defaults for testing

# Uncomment these for testing purposes
dbname=m2database
dbusername=m2_user
dbpassword=cD3ugB3Eyz0N9Tim5f3D
myip=$(awless whoami --ip-only)
az1=us-east-2a
az2=us-east-2b
maguser=2b1db2836a1bdc0b3740257716f942bb
magpw=ae59850def572919979465cc57250480
branch=awless

# Variable for m2_launch_app portion
keypairname=m2-app-keypair
magver=2.1.7

# Run underlying infrastructure template including RDS database creation
awless run ./Templates/m2_infra.aws \
myip=$myip \
dbname=$dbname \
dbusername=$dbusername \
dbpassword=$dbpassword \
az1=$az1 az2=$az2

# Continuously check availability of database before deploying application
awless check --force database id=$dbname state=available timeout=1800

# This is for the hostname of the RDS instance we just created
dbhost=$(awless show $dbname --values-for=PublicDNS)

# Launch instance with newly created keypair and inject user-data script to then launch docker container + attach to RDS instance
awless run ./Templates/m2_launch_app.aws \
keypairname=$keypairname \
userdata=./init.sh \
dbhost=$dbhost \
dbname=$dbname \
dbusername=$dbusername \
dbpassword=$dbpassword \
maguser=$maguser \
magpw=$magpw \
magver=$magver \
branch=$branch

echo "RDS endpoint:$dbhost, don't forget to enable DNS hostnames in VPC plus make DB public in AWS console"
echo ""
