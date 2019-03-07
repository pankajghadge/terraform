output "elb_address" {
  value = "${aws_lb.hello_alb.dns_name}"
}

output "image_hosts_addresses" {
  value = "${aws_instance.hello_alb_backend_images_instance.*.private_ip}"
}

output "video_hosts_addresses" {
  value = "${aws_instance.hello_alb_backend_videos_instance.*.private_ip}"
}
