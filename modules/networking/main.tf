module "vpc" {
  source = "./vpc"
  region = "${var.region}"
  tag_name = "${var.tag_name}"

}

# Declare the data source
data "aws_availability_zones" "az_available" {}


#############
## Subnets ##
#############

resource "aws_subnet" "main" {
  count             = "${length(data.aws_availability_zones.az_available.names)}"
  availability_zone = "${data.aws_availability_zones.az_available.names[count.index]}"
  vpc_id            = "${module.vpc.vpc_id}"
  cidr_block        = "${cidrsubnet(module.vpc.vpc_cidr, 4, count.index+1)}"
  map_public_ip_on_launch = true

  tags {
    Name = "${var.tag_name}-${count.index}"
    Project     = "${var.project}"
    Environment = "${terraform.workspace}"
  }
}

##########################
###   Security Groups ###
##########################
resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all inbound traffic"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "mongo" {
  name        = "${var.tag_name}-mongo-sg"
  description = "open mongo ports inbound and outbound"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }  

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

##########################
###   Route Tables     ###
##########################

resource "aws_route_table" "route-table" {
  vpc_id = "${module.vpc.vpc_id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${module.vpc.internet_gateway_id}"
  }

  tags {
    Name = "${var.tag_name}-route-table"
  }
}

resource "aws_route_table_association" "route_association" {
  count = "${length(data.aws_availability_zones.az_available.names)}"
  subnet_id      = "${element(aws_subnet.main.*.id, count.index)}"
  route_table_id = "${aws_route_table.route-table.id}"
}
