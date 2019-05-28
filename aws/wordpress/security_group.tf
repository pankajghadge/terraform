resource "aws_security_group" "wp_db" {
  name   = "db-secgroup"
  vpc_id = "${aws_vpc.main_vpc.id}"

  # ssh access from anywhere
  ingress {
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"

    #cidr_blocks = ["0.0.0.0/0"]
    security_groups = ["${aws_security_group.wp_sg.id}"]
  }

  #egress {
  #  from_port = 0
  #  to_port = 0
  #  protocol = "-1"
  #  cidr_blocks = ["0.0.0.0/0"]
  #}
}

resource "aws_security_group" "wp_sg" {
  name   = "ap-secgroup"
  vpc_id = "${aws_vpc.main_vpc.id}"

  # Internal HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #ssh from anywhere (unnecessary)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ping access from anywhere
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
