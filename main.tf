##########################
###      AWS ENV       ###
##########################

provider "aws" {
  region = "${var.region}"
}

module "networking" {
  source   = "./modules/networking"
  region   = "${var.region}"
  tag_name = "${var.tag_name}"

}

##########################
###      ECS SPOT      ###
##########################

# module "mongo_spot" {
#   source         = "./modules/spot"
#   region         = "${var.region}"
#   key_name       = "${var.key_name}"
#   key_path       = "${var.key_path}"
#   security_group = "${module.networking.security_group_mongo}"
#   subnet_ids     = "${module.networking.subnet_ids}"
#   tag_name       = "${var.tag_name}"
#   spot_servers   = "1"
#   replica_set    = "replicadb"
#   provision      = "mongod"
#   spot_price     = "0.5"
# }

# output "public_ips_spot" {
#   value = "${module.mongo_spot.public_ips}"
# }

##########################
###     ECS CLUSTER    ###
##########################

module "mongo_cluster" {
  source         = "./modules/cluster"
  region         = "${var.region}"
  key_name       = "${var.key_name}"
  key_path       = "${var.key_path}"
  security_group = "${module.networking.security_group_mongo}"
  subnet_ids     = "${module.networking.subnet_ids}"
  tag_name       = "${var.tag_name}"
  cluster_servers  = "3"
  replica_set      = "replicadb"
  provision        = "mongod"
}

output "public_ips_cluster" {
  value = "${module.mongo_cluster.public_ips}"
}