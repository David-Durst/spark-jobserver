This is a fork of [Spark Job Server](https://github.com/spark-jobserver/spark-jobserver) designed for Amazon EC2. It contains scripts which launch an EC2 cluster, deploy an appropriately configured instance of the job server, and run a sample application.

## How To Use

1. Sign up for an Amazon AWS account.
2. Assign your access key ID and secret access key to the bash variables AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY.
    * I recommend doing this by placing the following export statements in your .bashrc file.
    * export AWS_ACCESS_KEY_ID=accesskeyId
    * export AWS_SECRET_ACCESS_KEY=secretAccessKey
3. Configure config/user-ec2-settings. In particular, set KEY_PAIR to the name of your EC2 key pair and SSH_KEY to the location of the pair's private key.
    * I recommend using an ssh key that does not require entering a password on every use. Otherwise, you will need to enter the password many times
4. Run bin/ec2_deploy.sh to start the EC2 cluster. Go to the url printed at the end of the script to view the Spark Job Server frontend. Change the port from 8090 to 8080 to view the Spark Standalone Cluster frontend.
5. Run bin/ec2_example.sh to setup the example. Go to the url printed at the end of the script to view the example.