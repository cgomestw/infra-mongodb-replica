
provider "aws" {
  region = "${var.region}"
}

data "aws_subnet" "vpc" {
  count = "${var.spot_servers}"
  id = "${var.subnet_ids[count.index]}"
}

resource "template_dir" "config" {
  source_dir      = "${path.module}/templates"
  destination_dir = "${path.cwd}/config"

  vars {
    replica_set	= "${var.replica_set}"
  }
}

resource "aws_ebs_volume" "data-volumes" {
  count             = "${var.spot_servers}"
  availability_zone = "${element(data.aws_subnet.vpc.*.availability_zone, count.index)}"
  size              = "${var.volume_size}"
  type              = "${var.volume_type}"
  iops              = "${var.volume_iops}"

  tags {
    Name       = "mongodb-${var.tag_name}-vol-${count.index}"
  }  
}

resource "aws_spot_instance_request" "cluster" {
  ami                         = "${var.ecs_instance_amis["${var.region}"]}"
  instance_type               = "${var.aws_instance_type}"
  vpc_security_group_ids      = ["${var.security_group}"]
  subnet_id                   = "${element(var.subnet_ids, count.index)}"
  key_name                    = "${var.key_name}"
  count                       = "${var.spot_servers}"
  wait_for_fulfillment        = true
  spot_price                  = "${var.spot_price}"  
  associate_public_ip_address = true
 
  tags {
    Name       = "mongodb-${var.tag_name}-${count.index}"
  }
}

resource "null_resource" "configuration" {
  count    = "${var.spot_servers}"

  triggers = {
    cluster_instance_ids = "${join(",", aws_spot_instance_request.cluster.*.id)}"
  }

  connection {
    host = "${element(aws_spot_instance_request.cluster.*.public_ip, count.index)}"
    user = "${var.ami_username}"
    private_key = "${file("${var.key_path}")}"
  }
  
  # copy provisioning files
  provisioner "file" {
    source = "${path.module}/scripts"
    destination = "/tmp"
  }
  
  # copy config files
  provisioner "file" {
    source = "${template_dir.config.destination_dir}"
    destination = "/tmp"
  }

  # execute scripts
  provisioner "remote-exec" {
    inline = [
    "echo Clusters: ${join(" ", aws_instance.cluster.*.private_ip)}",
	  "chmod +x /tmp/scripts/provision.sh",
    "chmod +x /tmp/scripts/bootstrap-replset.sh",
	  "/tmp/scripts/provision.sh ${var.provision}",
    "echo ${count.index} > /tmp/instance-number.txt",
    "/tmp/scripts/bootstrap-replset.sh ${var.replica_set} ${join(" ", aws_instance.cluster.*.private_ip)}"
    ]
  }  
}

resource "aws_volume_attachment" "data" {
  device_name       = "/dev/xvdb"
  volume_id         = "${element(aws_ebs_volume.data-volumes.*.id, count.index)}"
  instance_id       = "${element(aws_spot_instance_request.cluster.*.spot_instance_id, count.index)}"
  # skip_destroy      = true
  count             = "${var.spot_servers}"
}

