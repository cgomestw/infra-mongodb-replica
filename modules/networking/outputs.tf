output "security_group_mongo" {
  value = "${aws_security_group.mongo.id}"
}

output "security_group_allow_all" {
  value = "${aws_security_group.allow_all.id}"
}

output "route_table_data" {
  value = "${aws_route_table.route-table.id}"
}

output "subnet_ids" {
    value = "${aws_subnet.main.*.id}"
}

output "subnet_cidr_blocks" {
  value = ["${aws_subnet.main.*.cidr_block}"]
}