
output "public_ips" {
  value = "${aws_spot_instance_request.cluster.*.public_ip}"
}

output "private_ips" {
  value = "${aws_spot_instance_request.cluster.*.private_ip}"
}

output "instance_ids" {
  value = "${join("\n", aws_spot_instance_request.cluster.*.spot_instance_id)}"
}