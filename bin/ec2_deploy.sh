#!/bin/bash
#MUST CUSTOMIZE THESE TO RUN
# SSH Key to login to server that hosts Spark master node and Job Server
SSH_KEY=/home/david/.ssh/id_rsa
KEY_PAIR=ddurstLaptop

bin=`dirname "${BASH_SOURCE-$0}"`
bin=`cd "$bin"; pwd`

#get spark binaries if they haven't been downloaded and extracted yet
if [ ! -d "$bin"/../spark-1.5.0-bin-hadoop2.6 ]; then
    wget -P "$bin"/.. http://apache.arvixe.com/spark/spark-1.5.0/spark-1.5.0-bin-hadoop2.6.tgz
    tar -xvzf "$bin"/../spark-1.5.0-bin-hadoop2.6.tgz -C "$bin"/..
fi

#run spark-ec2 to start ec2 cluster
CLUSTER_NAME=medium1Slave
EC2DEPLOY="$bin"/../spark-1.5.0-bin-hadoop2.6/ec2/spark-ec2
"$EC2DEPLOY" --key-pair=$KEY_PAIR --identity-file=$SSH_KEY --region=us-east-1 --zone=us-east-1a --instance-type=m3.medium --slaves 1 launch $CLUSTER_NAME
#There is only 1 deploy host. However, the variable is plural as that is how Spark Job Server named it.
#To minimize changes, I left the variable name alone.
export DEPLOY_HOSTS=$("$EC2DEPLOY" get-master $CLUSTER_NAME | tail -n1)

#This line is a hack to edit the ec2.conf file so that the master option is correct. Since we are allowing Amazon to
#dynamically allocate a url for the master node, we must update the configuration file in between cluster startup
#and Job Server deployment
sed -i -E "s/master = .*/master = \"spark:\/\/$DEPLOY_HOSTS:7077\"/g" "$bin"/../config/ec2.conf

#open the port on the master for Spark Job Server to work
aws ec2 authorize-security-group-ingress --group-name $CLUSTER_NAME-master --protocol tcp --port 8090 --cidr 0.0.0.0/0

. server_deploy.sh ec2

echo "The Job Server is listening at $DEPLOY_HOSTS"