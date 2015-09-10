# Environment and deploy file
# For use with bin/server_deploy, bin/server_package etc.
# SSH Key to login to server that hosts Spark master node and Job Server

#MUST CUSTOMIZE THESE TO RUN
SSH_KEY=/home/david/.ssh/id_rsa
KEY_PAIR=ddurstLaptop

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
DEPLOY_HOSTS=$("$EC2DEPLOY" get-master $CLUSTER_NAME | tail -n1)

#This line is a hack to edit the ec2.conf file so that the master option is correct. Since we are allowing Amazon to
#dynamically allocate a url for the master node, we must update the configuration file in between cluster startup
#and Job Server deployment
sed -i -E "s/master = .*/master = \"spark:\/\/$DEPLOY_HOSTS:7077\"/g" "$bin"/../config/ec2.conf

#open the port on the master for Spark Job Server to work
aws ec2 authorize-security-group-ingress --group-name $CLUSTER_NAME --protocol tcp --port 8090 --cidr 0.0.0.0/0

#configure environment variables for job server
APP_USER=root
APP_GROUP=root
INSTALL_DIR=/root/job-server
LOG_DIR=/var/log/job-server
PIDFILE=spark-jobserver.pid
JOBSERVER_MEMORY=1G
SPARK_VERSION=1.5.0
SPARK_HOME=/root/spark
SPARK_CONF_DIR=$SPARK_HOME/conf
# Only needed for Mesos deploys
SPARK_EXECUTOR_URI=/home/spark/spark-0.8.0.tar.gz
# Only needed for YARN running outside of the cluster
# You will need to COPY these files from your cluster to the remote machine
# Normally these are kept on the cluster in /etc/hadoop/conf
# YARN_CONF_DIR=/pathToRemoteConf/conf
# HADOOP_CONF_DIR=/pathToRemoteConf/conf
SCALA_VERSION=2.10.3 # or 2.11.6
