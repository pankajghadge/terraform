resource "aws_instance" "hello_elb_demo_instance" {
  count         = "${var.instance_count}"
  ami           = "${lookup(var.ami,var.region)}"
  instance_type = "${var.instance_type}"
  key_name      = "${aws_key_pair.demo_key.id}"

  user_data              = "${file("files/web_bootstrap.sh")}"
  vpc_security_group_ids = ["${aws_security_group.hello_sg.id}"]
  subnet_id              = "${element(data.aws_subnet.vpc_dev_private_subnets.*.id, count.index)}"

  tags {
    Name = "Webserver-${count.index+1}"
  }
}

resource "aws_key_pair" "demo_key" {
  key_name   = "demo-key"
  public_key = "${file("files/demo-key.pub")}"
}

resource "aws_elb" "hello_web_elb" {
  name = "hello-web-elb"

  subnets         = ["${data.aws_subnet.vpc_dev_public_subnets.*.id}"]
  security_groups = ["${aws_security_group.hello_elb_sg.id}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  # The instances are registered automatically
  instances = ["${aws_instance.hello_elb_demo_instance.*.id}"]

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/index.html"
    interval            = 30
  }

  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags {
    Name = "terraform_demo_dev_vpc_elb"
  }
}

resource "aws_lb_cookie_stickiness_policy" "hello_elb_cookie_stickiness" {
  name                     = "hello-elb-stickiness-policy"
  load_balancer            = "${aws_elb.hello_web_elb.id}"
  lb_port                  = 80
  cookie_expiration_period = 600
}

/*
resource "aws_app_cookie_stickiness_policy" "hello_app_cookie_stickiness" {
  name          = "hello-app-stickiness-policy"
  load_balancer = "${aws_elb.hello_web_elb.name}"
  lb_port       = 80
  cookie_name   = "MyAppCookie"
}
*/

resource "aws_autoscaling_group" "hello_autoscaling_group" {
  name     = "HelloAutoscalingGroup"
  max_size = "${var.instance_count+2}"
  min_size = "${var.instance_count}"

  # desired_capacity          = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  load_balancers            = ["${aws_elb.hello_web_elb.name}"]
  force_delete              = true
  vpc_zone_identifier       = ["${data.aws_subnet.vpc_dev_private_subnets.*.id}"]
  #launch_configuration      = "${aws_launch_configuration.hello_launch_configuration.name}"

  launch_template = {
    id      = "${aws_launch_template.hello_launch_template.id}"
    version = "${aws_launch_template.hello_launch_template.latest_version}"
  }

  lifecycle {
    create_before_destroy = true
  }
 
  tag {
    key                 = "Name"
    value               = "terraform_demo_dev_vpc_elb"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = "DEV"
    propagate_at_launch = true
  }
}

/*
resource "aws_launch_configuration" "hello_launch_configuration" {
  name            = "HelloLaunchConfiguration"
  image_id        = "${lookup(var.ami,var.region)}"
  instance_type   = "${var.instance_type}"
  key_name        = "${aws_key_pair.demo_key.id}"
  user_data       = "${file("files/web_bootstrap.sh")}"
  security_groups = ["${aws_security_group.hello_sg.id}"]
}
*/

data "template_file" "hello_template_file" {
  template = "${file("files/web_bootstrap.sh")}"
}


resource "aws_launch_template" "hello_launch_template" {
  name = "HelloLaunchTemplate"
  image_id        = "${lookup(var.ami,var.region)}"
  instance_type   = "${var.instance_type}"
  key_name        = "${aws_key_pair.demo_key.id}"
  user_data       = "${base64encode(data.template_file.hello_template_file.rendered)}"
  vpc_security_group_ids = ["${aws_security_group.hello_sg.id}"]

}  

resource "aws_autoscaling_policy" "add_instances_policy" {
  name                   = "AddInstancesPolicy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.hello_autoscaling_group.name}"
}

resource "aws_autoscaling_policy" "remove_instances_policy" {
  name                   = "RemoveInstancesPolicy"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.hello_autoscaling_group.name}"
}

resource "aws_cloudwatch_metric_alarm" "avg_cpu_ge_80" {
  alarm_name          = "avg_cpu_ge_80"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.hello_autoscaling_group.name}"
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = ["${aws_autoscaling_policy.add_instances_policy.arn}"]
}

resource "aws_cloudwatch_metric_alarm" "avg_cpu_le_30" {
  alarm_name          = "avg_cpu_le_30"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "30"

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.hello_autoscaling_group.name}"
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = ["${aws_autoscaling_policy.remove_instances_policy.arn}"]
}

## Security group ELB ##

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
