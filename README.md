# Overview 

Terraform project, which creates almost all required AWS resources as well as taking care of building and packaging of required Lambda dependencies and dockerizing Shiny app.

## How to use this? <a name="setup"></a>
This project is based on Terraform.
### Prerequisites
1. Terraform 0.15.x or later =>[Installation Guide](https://www.terraform.io/downloads.html)
2. AWS CLI => [Installation Guide](https://aws.amazon.com/cli/)
3. Docker
4. jq => sudo apt install jq or yum install jq


Once all prerequisites are installed, pull this repository and run following commands:
```
$ make plan    // Creates an execution plan
$ make apply // Executes the actions proposed in a Terraform plan
```

This will output "Shiny App URL" on the terminal, which can be used to access Shiny app Webserver.
Along with "Shiny App URL", you will also get the s3 demo url (previous project) to help you to test all functionalities are working as expected

If you want to delete all these resources, run the following command:

```
$ make destroy
```

