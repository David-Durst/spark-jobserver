This is a fork of [Spark Job Server](https://github.com/spark-jobserver/spark-jobserver) designed for Amazon EC2. It contains scripts which launch an EC2 cluster, deploy an appropriately configured instance of the job server, and run a sample application.

## Setting Up The EC2 Cluster

1. Sign up for an Amazon AWS account.
2. Assign your access key ID and secret access key to the bash variables AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY.
    * I recommend doing this by placing the following export statements in your .bashrc file.
    * export AWS_ACCESS_KEY_ID=accesskeyId
    * export AWS_SECRET_ACCESS_KEY=secretAccessKey
3. Copy job-server/config/user-ec2-settings.sh.template to job-server/config/user-ec2-settings.sh and configure it. In particular, set KEY_PAIR to the name of your EC2 key pair and SSH_KEY to the location of the pair's private key.
    * I recommend using an ssh key that does not require entering a password on every use. Otherwise, you will need to enter the password many times
4. Run bin/ec2_deploy.sh to start the EC2 cluster. Go to the url printed at the end of the script to view the Spark Job Server frontend. Change the port from 8090 to 8080 to view the Spark Standalone Cluster frontend.
5. Run bin/ec2_example.sh to setup the example. Go to the url printed at the end of the script to view the example.
4. Run bin/ec2_destroy.sh to shutdown the EC2 cluster.

## Using The Example

1. Start a Spark Context by pressing the "Start Context" button.
2. Load data by pressing the "Resample" button. The matrix of scatterplots and category selection dropdown will only appear after loading data from the server.
    * It will take approximately 30-35 minutes the first time you press resample after starting a new context. The cluster spends 20 minutes pulling data from an S3 bucket. It spends the rest of the time running the k-means clustering algorithm.
    * Subsequent presses will refresh the data in the scatterplots. These presses will take about 10 seconds as the data is reloaded from memory using a NamedRDD.
3. After performing the data analysis, shutdown the context by pressing the "Stop Context" button.
