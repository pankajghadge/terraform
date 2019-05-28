output "addresses" {
  value = "${aws_instance.web_server.*.public_ip}"
}
