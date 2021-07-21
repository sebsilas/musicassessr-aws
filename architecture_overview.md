# Architecture Overview
Deploying this solution wirh Terraform builds the following environment in the AWS Cloud:

![AWS ](architecture.png)

# Components

## Step A: Base 
Creates the foundational infrastructure for the application's infrastructure (boilerplate). These Terraform files will create:

- Two S3 Buckets (source and destination)
- A Lambda Function (Sonic pYIN), including its deployment process (building and pushing the container image)
- The Amazon API Gateway used to invoke Lambda function
- A Cognito identity pool (used to grant webserver permissions to read and upload to the newly created S3 buckets)

Typically, these Terraform files will only need to be run once, and then should only
need changes very infrequently. This will output :

| Name | Description |
|------|-------------|
| api_base_url | The AWS API Gateway endpoint URL  |
| s3_source_bucket  | The S3 source bucket name  |
| s3_destination_bucket | The S3 destination  bucket name  |
| aws_cognito_identity_pool  | The ID of the Identity Pool |

## Step B: Deploying the Shiny app

Packages and deploys the Shiny App.

- Create VPC 
- Create Security Groups
- Launch an EC2 instance from a custom Amazon Machine Image (AMI)


This will output "Shiny App URL" in the terminal, which can be used to access Shiny app webserver.
