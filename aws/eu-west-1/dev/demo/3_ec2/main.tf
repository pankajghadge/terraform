/* 
# Method1: aws ec2 userdata without file function 
resource "aws_instance" "hello_instance" {
  ami           = "${lookup(var.ami,var.region)}"
  instance_type = "${var.instance_type}"
  key_name      = "${aws_key_pair.demo_key.id}"

  user_data = <<EOF
                      #!/bin/bash
                      yum install -y nginx
		      chkconfig nginx on
		      service nginx start
		  EOF

  vpc_security_group_ids = ["${aws_security_group.hello_sg.id}"]
}

*/

# Method2: aws ec2 userdata with file function
resource "aws_instance" "hello_instance" {
  ami           = "${lookup(var.ami,var.region)}"
  instance_type = "${var.instance_type}"
  key_name      = "${aws_key_pair.demo_key.id}"

  user_data = "${file("files/web_bootstrap.sh")}"

  vpc_security_group_ids = ["${aws_security_group.hello_sg.id}"]
}

resource "aws_key_pair" "demo_key" {
  key_name   = "demo-key"
  public_key = "${file("files/demo-key.pub")}"
}

#
# Create EIP and attach it to our hello instance 
#
resource "aws_eip" "hello_eip" {
  instance = "${aws_instance.hello_instance.id}"
  vpc      = true
}

#
# Create security group and attach it to hello instance
#

resource "aws_security_group" "hello_sg" {
  name        = "hello_sg"
  description = "Allow all inbound http traffic"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "eip" {
  value = "${aws_eip.hello_eip.public_ip}"
}
