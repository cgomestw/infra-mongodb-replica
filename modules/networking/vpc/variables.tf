variable "name" {
  default = "sandbox"
}

variable "project" {
  default = "mongodb-replica"
}

variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "region" {
  description = "The AWS region"
}

variable "tag_name" {
  description = "The AWS tag name, the same of workspace."
}