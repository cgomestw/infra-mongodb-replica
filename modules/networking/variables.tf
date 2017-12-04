##########################
###      Compute       ###
##########################
variable "region" {
  description = "The AWS region"
}

variable "tag_name" {
  description = "The AWS tag name, the same of workspace."
}

variable "project" {
  default = "mongodb-replica"
}

variable "external_access_cidr_block" {
  default = "0.0.0.0/0"
}
