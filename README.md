# Overview 

This repository hosts a Terraform project which creates almost all the required dependencies to support the R package [`musicassessr`](https://github.com/syntheso/musicassessr). More specifically, it creates the relevant Amazon Web Server (AWS) resources, builds and packages the required Lambda dependencies and dockerizes a Shiny app which uses `musicassessr` functionality.

There are 3 main steps, each of which have several substeps. You should only need to do most of this once to make use of the `musicassessr` functionality:

1) Setup the AWS architecture (for recording and processing audio in the cloud)
2) Update or deploy `musicassessr`/Shiny apps to the created EC2 server (to run your `musicassessr` functionality i.e., collect data for a psychology test)
3) Setup up SSL. This is required to remove browser security warnings, which are otherwise produced by using functionality which requests to use a user's microphone. NB, you will need your own registered domain name for this step.


## Prerequisites
1. Terraform 0.15.x or later =>[Installation Guide](https://www.terraform.io/downloads.html)
2. AWS CLI => [Installation Guide](https://aws.amazon.com/cli/)
3. Docker => [Install](https://www.docker.com/)


# Usage

## 1) Setup AWS architecture
For more information about the AWS architecture setup, please see [Architecture Overview](https://github.com/mcetn/shiny-app-aws/blob/main/architecture_overview.md).

- If you do not have one already, [create an AWS account](https://aws.amazon.com/resources/create-account/).
- Get your AWS access key(AWS_ACCESS_KEY_ID) and secret access keys(AWS_SECRET_ACCESS_KEY) => [How To](https://docs.aws.amazon.com/sdk-for-javascript/v2/developer-guide/getting-your-credentials.html). 
- Clone the present repository locally to your computer, cd to the directory, then in your terminal, enter the commands below (replacing with your AWS credentials from earlier).

```

# Configure environment variables (required for both):
$ export AWS_ACCESS_KEY_ID=put_your_access_key_id_here
$ export AWS_SECRET_ACCESS_KEY=put_your_secret_access_key_here


# step A (Base)
# Move into the boilerplate directory
$ cd boilerplate
$ make plan

$ make apply


# step B (Deploying the Shiny app)
# Go back to the parent directory
$ cd ..

$ make plan

$ make apply

```

If you want to delete all these resources, run the following command:

```
$ make destroy
$ cd boilerplate
$ make destroy
```
## 2) Update or deploy `musicassessr`/Shiny apps to the EC2

```
# upload your shiny app files to EC2
$ scp -i shiny-ec2-key.pem  -r <local-shiny-app-folder-path>  ubuntu@<ip>:/home/ubuntu
# connect to your instance using SSH
$ ssh -i shiny-ec2-key.pem ubuntu@<ip>
# move your files from /home/ubuntu/ to /srv/shiny-server/ (this is where the Shiny Server is located)
$ mv /home/ubuntu/<shiny-app-folder> /srv/shiny-server
# install all the packages for your application
$ sudo su - \
-c "R -e \"install.packages(musicassessr, repos='https://cran.rstudio.com/')\""
$ sudo chown -R shiny /srv/shiny-server/<shiny-app-folder>
$ sudo  systemctl restart shiny-server.service
```
## 3) Setting up SSL 
[Installation Guide](https://github.com/mcetn/shiny-app-aws/blob/main/ssl.md)



