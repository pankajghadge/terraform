resource "aws_instance" "hello_alb_backend_images_instance" {
  count         = 1
  ami           = "${lookup(var.ami,var.region)}"
  instance_type = "${var.instance_type}"
  key_name      = "${aws_key_pair.demo_key.id}"

  user_data              = "${file("files/web_bootstrap.sh")}"
  vpc_security_group_ids = ["${aws_security_group.hello_sg.id}"]
  subnet_id              = "${element(data.aws_subnet.vpc_dev_private_subnets.*.id, count.index)}"

  tags {
    Name = "Webserver-images-${count.index+1}"
  }
}

resource "aws_instance" "hello_alb_backend_videos_instance" {
  count         = 1
  ami           = "${lookup(var.ami,var.region)}"
  instance_type = "${var.instance_type}"
  key_name      = "${aws_key_pair.demo_key.id}"

  user_data              = "${file("files/web_bootstrap.sh")}"
  vpc_security_group_ids = ["${aws_security_group.hello_sg.id}"]
  subnet_id              = "${element(data.aws_subnet.vpc_dev_private_subnets.*.id, count.index)}"

  tags {
    Name = "Webserver-videos-${count.index+1}"
  }
}

resource "aws_key_pair" "demo_key" {
  key_name   = "demo-key"
  public_key = "${file("files/demo-key.pub")}"
}

/***** Declaration/initiation of applicatoin load balancer ********/

resource "aws_lb" "hello_alb" {  
  name            = "hello-web-alb" 
  internal        = false 
  load_balancer_type = "application"
  subnets         = ["${data.aws_subnet.vpc_dev_public_subnets.*.id}"]
  security_groups = ["${aws_security_group.hello_elb_sg.id}"]

  tags {    
    Name    = "terraform_demo_dev_vpc_alb"    
  } 
  enable_deletion_protection = false
  idle_timeout    = 60
  enable_cross_zone_load_balancing = true  
  
}
/***** End of Declaration of applicatoin load balancer ********/

/***** Load balancer listener 80 or 443 or any other port ********/

resource "aws_lb_listener" "listen_80" {
  load_balancer_arn = "${aws_lb.hello_alb.arn}"
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.hello_alb_target_group_default.arn}"
  }
}

#resource "aws_lb_listener" "listen_443" {
#  load_balancer_arn = "${aws_lb.hello_alb.arn}"
#  port              = "443"
#  protocol          = "HTTPS"
#
#  ssl_policy        = "ELBSecurityPolicy-2016-08"
#  certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"
#  default_action {
#    type             = "forward"
#    target_group_arn = "${aws_lb_target_group.hello_alb_target_group_default.arn}"
#  }
#}

/***** End of Load balancer listener 80 or 443 or any other port ******/


/***** Load balancer frontend conditions and actions  ********/

resource "aws_lb_listener_rule" "frontend_images_80" {
  listener_arn = "${aws_lb_listener.listen_80.arn}"
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.backend_images.arn}"
  }

  condition {
    field  = "path-pattern"
    values = ["/images/*"]
  }
}



resource "aws_lb_listener_rule" "frontend_videos_80" {
  listener_arn = "${aws_lb_listener.listen_80.arn}"
  priority     = 99

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.backend_videos.arn}"
  }

  condition {
    field  = "path-pattern"
    values = ["/videos/*"]
  }
}

resource "aws_lb_listener_rule" "frontend_default_80" {
  listener_arn = "${aws_lb_listener.listen_80.arn}"
  priority     = 98

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.backend_default.arn}"
  }

}
/****** End of Load balancer frontend conditions and actions ******/

/****** Load balancer Backend (Group of instances) ********/

resource "aws_alb_target_group" "backend_default" {

  name     = "application-name-alb-target-group-default"  
  port     = 80  
  protocol = "HTTP"  
  vpc_id   = "${data.aws_vpc.vpc_dev.id}" 

  tags {    
    name = "application_name_alb_target_group_default"    
  }   
  stickiness {    
    type            = "lb_cookie"    
    cookie_duration = 1800    
    enabled         = true  
  }   
  health_check {    
    healthy_threshold   = 3    
    unhealthy_threshold = 10    
    timeout             = 5    
    interval            = 10    
    path                = "/health_check.html"    
    port                = "80"  
  }
}

resource "aws_alb_target_group_attachment" "default_hosts" {
  count = "${length(aws_instance.hello_alb_backend_images_instance.*.id)+length(aws_instance.hello_alb_backend_videos_instance.*.id)}"
  target_group_arn = "${aws_alb_target_group.backend_default.arn}"
  target_id        = "${element(split(",", join(",", concat(aws_instance.hello_alb_backend_images_instance.*.id, aws_instance.hello_alb_backend_videos_instance.*.id)), count.index))}"
}


resource "aws_alb_target_group" "backend_images" {

  name     = "application-name-alb-target-group-images"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${data.aws_vpc.vpc_dev.id}"

  tags {
    name = "application_name_alb_target_group_images"
  }
  stickiness {
    type            = "lb_cookie"
    cookie_duration = 1800
    enabled         = true
  }
  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 10
    timeout             = 5
    interval            = 10
    path                = "/health_check.html"
    port                = "80"
  }   
}

resource "aws_alb_target_group_attachment" "images_hosts" {
  count = "${length(aws_instance.hello_alb_backend_images_instance.*.id)}"
  target_group_arn = "${aws_alb_target_group.backend_images.arn}"
  target_id        = "${element(split(",", join(",", aws_instance.hello_alb_backend_images_instance.*.id), count.index))}"
}

resource "aws_alb_target_group" "backend_videos" {
  name     = "application-name-alb-target-group-videos"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${data.aws_vpc.vpc_dev.id}"

  tags {
    name = "application_name_alb_target_group_videos"
  }G

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 1800
    enabled         = true
  }

  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 10
    timeout             = 5
    interval            = 10
    path                = "/health_check.html"
    port                = "80"
  }
}

resource "aws_alb_target_group_attachment" "videos_hosts" {
  count = "${length(aws_instance.hello_alb_backend_videos_instance.*.id)}"
  target_group_arn = "${aws_alb_target_group.backend_videos.arn}"
  target_id        = "${element(split(",", join(",", aws_instance.hello_alb_backend_videos_instance.*.id), count.index))}"
}

/************** End of Group of instances *****************/

/**************     Security group ELB    *****************/

resource "aws_security_group" "hello_elb_sg" {
  name        = "web_inbound"
  description = "Allow HTTP from Anywhere"
  vpc_id      = "${data.aws_vpc.vpc_dev.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#
# Create security group and attach it to hello instance
#

resource "aws_security_group" "hello_sg" {
  name        = "hello_sg"
  description = "Allow all inbound http traffic"
  vpc_id      = "${data.aws_vpc.vpc_dev.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    #cidr_blocks = ["0.0.0.0/0"]
    security_groups = ["${aws_security_group.hello_elb_sg.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

/**************  END of Security group ELB   *****************/

resource "aws_launch_template" "images_host_launch_template" {
  name = "ImageHostLaunchTemplate"
  image_id        = "${lookup(var.ami,var.region)}"
  instance_type   = "${var.instance_type}"
  key_name        = "${aws_key_pair.demo_key.id}"
  user_data       = "${file("files/web_bootstrap.sh")}"
  vpc_security_group_ids = ["${aws_security_group.hello_sg.id}"]

}

resource "aws_autoscaling_group" "images_target_group_autoscaling" {
  name     = "ImageTargetGroupAutoscaling"
  max_size = "${length(aws_instance.hello_alb_backend_images_instance.*.id)}+2"
  min_size = "${length(aws_instance.hello_alb_backend_images_instance.*.id)}"

  # desired_capacity          = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  #load_balancers           = ["${aws_elb.hello-web-elb.name}"]
  target_group_arns         = ["${aws_alb_target_group.backend_images.arn}"] 
  force_delete              = true
  vpc_zone_identifier       = ["${data.aws_subnet.vpc_dev_private_subnets.*.id}"]
  #launch_configuration      = "${aws_launch_configuration.hello_launch_configuration.name}"

  launch_template = {
    id      = "${aws_launch_template.images_host_launch_template.id}"
    version = "${aws_launch_template.images_host_launch_template.latest_version}"
  }
  lifecycle {
    create_before_destroy = true
  }
  tags {
    Name = "terraform_demo_dev_vpc_alb_autoscaling_images"
  }
}

resource "aws_autoscaling_policy" "add_instances_policy_application_name_images" {
  name                   = "AddInstancesPolicyApplicationNameImage"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.images_target_group_autoscaling.name}"
}

resource "aws_autoscaling_policy" "remove_instances_policy_application_name_images" {
  name                   = "RemoveInstancesPolicyApplicationNameImage"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.images_target_group_autoscaling.name}"
}

resource "aws_cloudwatch_metric_alarm" "avg_cpu_ge_80_application_name_images" {
  alarm_name          = "avg_cpu_ge_80_application_name_images"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.images_target_group_autoscaling.name}"
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = ["${aws_autoscaling_policy.add_instances_policy_application_name_images.arn}"]
}

resource "aws_cloudwatch_metric_alarm" "avg_cpu_le_30_application_name_images" {
  alarm_name          = "avg_cpu_le_30_application_name_images"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "30"

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.images_target_group_autoscaling.name}"
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = ["${aws_autoscaling_policy.remove_instances_policy_application_name_images.arn}"]
}


resource "aws_launch_template" "videos_host_launch_template" {
  name = "VideoHostLaunchTemplate"
  image_id        = "${lookup(var.ami,var.region)}"
  instance_type   = "${var.instance_type}"
  key_name        = "${aws_key_pair.demo_key.id}"
  user_data       = "${file("files/web_bootstrap.sh")}"
  vpc_security_group_ids = ["${aws_security_group.hello_sg.id}"]

}

resource "aws_autoscaling_group" "videos_target_group_autoscaling" {
  name     = "ImageTargetGroupAutoscaling"
  max_size = "${length(aws_instance.hello_alb_backend_videos_instance.*.id)}+2"
  min_size = "${length(aws_instance.hello_alb_backend_videos_instance.*.id)}"

  # desired_capacity          = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  #load_balancers           = ["${aws_elb.hello-web-elb.name}"]
  target_group_arns         = ["${aws_alb_target_group.backend_videos.arn}"]
  force_delete              = true
  vpc_zone_identifier       = ["${data.aws_subnet.vpc_dev_private_subnets.*.id}"]
  #launch_configuration      = "${aws_launch_configuration.hello_launch_configuration.name}"

  launch_template = {
    id      = "${aws_launch_template.videos_host_launch_template.id}"
    version = "${aws_launch_template.videos_host_launch_template.latest_version}"
  }
  lifecycle {
    create_before_destroy = true
  }
  tags {
    Name = "terraform_demo_dev_vpc_alb_autoscaling_videos"
  }
}

resource "aws_autoscaling_policy" "add_instances_policy_application_name_videos" {
  name                   = "AddInstancesPolicyApplicationNameVideo"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.videos_target_group_autoscaling.name}"
}

resource "aws_autoscaling_policy" "remove_instances_policy_application_name_videos" {
  name                   = "RemoveInstancesPolicyApplicationNameImage"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.videos_target_group_autoscaling.name}"
}

resource "aws_cloudwatch_metric_alarm" "avg_cpu_ge_80_application_name_videos" {
  alarm_name          = "avg_cpu_ge_80_application_name_videos"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.videos_target_group_autoscaling.name}"
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = ["${aws_autoscaling_policy.add_instances_policy_application_name_videos.arn}"]
}

resource "aws_cloudwatch_metric_alarm" "avg_cpu_le_30_application_name_videos" {
  alarm_name          = "avg_cpu_le_30_application_name_videos"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "30"

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.videos_target_group_autoscaling.name}"
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = ["${aws_autoscaling_policy.remove_instances_policy_application_name_videos.arn}"]
}

