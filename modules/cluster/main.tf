provider "aws" {
  region = "${var.region}"
}


data "aws_subnet" "vpc" {
  count = "${var.cluster_servers}"
  id = "${var.subnet_ids[count.index]}"
}

resource "template_dir" "config" {
  source_dir      = "${path.module}/templates"
  destination_dir = "${path.cwd}/config"

  vars {
    replica_set	= "${var.replica_set}"
  }
}

resource "aws_instance" "cluster" {
  ami                         = "${var.ecs_instance_amis["${var.region}"]}"
  instance_type               = "${var.aws_instance_type}"
  vpc_security_group_ids      = ["${var.security_group}"]
  subnet_id                   = "${element(data.aws_subnet.vpc.*.id, count.index)}"
  key_name                    = "${var.key_name}"
  count                       = "${var.cluster_servers}"
  associate_public_ip_address = true
  
  
  ebs_block_device {
    device_name = "/dev/xvdb"
    volume_size = "${var.volume_size}"
    volume_type = "${var.volume_type}"
    iops        = "${var.volume_iops}"
  }
 
  tags {
    Name       = "mongodb-${var.tag_name}-${count.index}"

  }
}

resource "null_resource" "configuration" {
  count    = "${var.cluster_servers}"

  triggers = {
    cluster_instance_ids = "${join(",", aws_instance.cluster.*.id)}"
  }

  connection {
    host = "${element(aws_instance.cluster.*.public_ip, count.index)}"
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

