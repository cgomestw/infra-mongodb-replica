output "public_ips" {
  value = "${aws_instance.cluster.*.public_ip}"
}

output "private_ips" {
  value = "${aws_instance.cluster.*.private_ip}"
}

output "instance_ids" {
  value = "${join("\n", aws_instance.cluster.*.id)}"
}