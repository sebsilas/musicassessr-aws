# Overview 

Terraform project, which creates almost all required AWS resources as well as taking care of building and packaging of required Lambda dependencies and dockerizing Shiny app.

# Architecture Overview
Deploying this solution wirh Terraform builds the following environment in the AWS Cloud.

![AWS ](architecture.png)

## Prerequisites
1. Terraform 0.15.x or later =>[Installation Guide](https://www.terraform.io/downloads.html)
2. AWS CLI => [Installation Guide](https://aws.amazon.com/cli/)
3. Docker


# Components

## Base 
Creates the foundational infrastructure for the application's infrastructure(bolierplate). These Terraform files will create:

- Two S3 Buckets (source and destination)
- a Lamdda Function (Sonic Pyin) including its deployment process (building and pushing the conatiner image)
- Amazon API Gateway ( used to invoke lambda function)
- Coginito pool identiy pool (used to grant webserver permissions to read and upload on the newly created S3 buckets)

Typically, these Terraform files will only need to be run once, and then should only
need changes very infrequently.This will output :

| Name | Description |
|------|-------------|
| api_base_url | The AWS API Gateway endpoint URL  |
| s3_source_bucket  | The S3 source bucket name  |
| s3_destination_bucket | The S3 destination  bucket name  |
| aws_cognito_identity_pool  | The Id of the identity pool |

## Deploying the shiny app

Packages and deploys the shiny app.

- Create VPC 
- Create Security Groups
- Launch an EC2 instance from a custom Amazon Machine Image (AMI)


This will output "Shiny App URL" on the terminal, which can be used to access Shiny app Webserver.

# Usage

```

# Configure environment variables:
$ export AWS_ACCESS_KEY_ID=put_your_access_key_id_here
$ export AWS_SECRET_ACCESS_KEY=put_your_secret_access_key_here

# Move into the boilerplate directory
$ cd boilerplate

$ make plan

$ make apply

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

