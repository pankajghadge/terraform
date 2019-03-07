resource "aws_instance" "hello_elb_demo_instance" {
  count         = "${var.instance_count}"
  ami           = "${lookup(var.ami,var.region)}"
  instance_type = "${var.instance_type}"
  key_name      = "${aws_key_pair.demo_key.id}"

  user_data = "${file("files/web_bootstrap.sh")}"
  vpc_security_group_ids = ["${aws_security_group.hello_sg.id}"]
  subnet_id = "${element(data.aws_subnet.vpc_dev_private_subnets.*.id, count.index)}"
  #subnet_id = "${element(split(",",var.data_subnet_ids),count.index)}"
 
  ## Check it later
  /*
  provisioner "file" {
    source = "files/web_bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/bootstrap.sh",
      "sudo /tmp/bootstrap.sh"
    ]
  }
  connection {
    type = "ssh"
    user = "${var.instance_user}"
    private_key = "${file("files/demo-key")}"
  }
  */

  /*
  provisioner "local-exec" {
     command = "echo ${aws_instance.hello_elb_demo_instance.*.private_ip} >> private_ip.txt"
  }
  */

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
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
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

