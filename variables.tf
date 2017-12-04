#############################
###   Envirionment Conf   ###
#############################

variable "region" {
  description = "The AWS region"
  default = "us-east-2"
}

variable "key_name" {
  description = "SSH key name"
  default = "SandBox"
}

variable "key_path" {
  description = "Path to the private key specified by key_name."
  default = "SandBox.pem"
}

variable "tag_name" {
  description = "The AWS tag name, the same of workspace."
  default = "sandbox"
}