##########################
###   Configuration    ###
##########################

variable "region" {
  description = "The AWS region"
}

variable "tag_name" {
  description = "The AWS tag name, the same of workspace."
}

variable "cluster_servers" {
  description = "The number of servers in the cluster"
}


##########################
###      MongoDB       ###
##########################

variable "replica_set" {
  description = "Replicaset Name."
}

variable "provision" {
   description = "Provision Parameter (mongod, agent)"
}

##########################
###      Compute       ###
##########################

variable "key_name" {
  description = "SSH key name"
}

variable "key_path" {
  description = "Path to the private key specified by key_name."
}

variable "security_group" {
  description = "Mongo security group"
}

variable "subnet_ids" {
  type = "list"
}

variable "ecs_instance_amis" {
  description = "the id of the AMI to use for the EC2 instances"
  type = "map"
  default = {
    "us-east-1" = "ami-04351e12",
    "us-east-2" = "ami-207b5a45",
    "us-west-1" = "ami-7d664a1d",
    "us-west-2" = "ami-57d9cd2e",
    "ca-central-1" = "ami-3da81759"
  }
}

variable "ami_username" {
  description = "the username to use to ssh to the EC2 instance"
  default = "ec2-user"
}

variable "aws_instance_type" {
   default = "m4.large"
}

variable "volume_size" {
  description = "EBS disk size."
   default = "20"
}

variable "volume_type" {
  description = "EBS disk volume type (standard, io1, gp2)."
   default = "gp2"
}
variable "volume_iops" {
  description = "The amount of provisioned IOPS. This must be set with a volume_type of 'io1'."
   default = "1000"
}

