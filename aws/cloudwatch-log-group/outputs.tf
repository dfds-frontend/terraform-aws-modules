output "arn" {
  value = "${aws_cloudwatch_log_group.log_group}"
}

output "name" {
  value = "${var.name}"
}
