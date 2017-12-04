# TF Mongodb Replica

Terraform scripts for MongoDB Replica Cluster provisioning

# Pre-requisites

1. Install [terraform](https://www.terraform.io/downloads.html) `0.11.0`
2. Install [awscli](https://docs.aws.amazon.com/cli/latest/userguide/installing.html) `1.14.2`
3. Install [Python](https://www.python.org/downloads/release/python-361/) `3.6.1`.

# Manual steps Before Starting Deployment

1. Generate a KeyPair and add the name of the KeyPair in variables.tf file.
2. Get the pem file and place it in the project folder with 660 permission to be used by terraform to ssh and execute startup scripts
3. Execute `aws configure` to configure your credencials to be used by Terraform
4. Edit all the files with name variables.tf with your personal configuration

# Validate the Deployment
terraform init
terraform workspace new <projeto>
terraform get
terraform plan

# Start Deployment
terraform apply 

# Destroy all Resources
terraform destroy