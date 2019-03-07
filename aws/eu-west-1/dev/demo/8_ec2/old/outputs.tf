output "elb_address" {
  value = "${aws_elb.hello-web-elb.dns_name}"
}

output "addresses" {
  value = "${aws_instance.hello_elb_demo_instance.*.public_ip}"
}
