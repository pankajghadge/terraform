data "template_file" "wp_deploy" {
  template = "${file("./files/wp_user_data.sh")}"

  vars {
    db_ip       = "${aws_db_instance.wp_db.address}"
    db_user     = "${var.db_user}"
    db_password = "${var.db_password}"
  }
}

resource "aws_key_pair" "wp_key" {
  key_name   = "demo-key"
  public_key = "${file("files/demo-key.pub")}"
}

resource "aws_instance" "web_server" {
  count                  = "${var.web_servers_count}"
  ami                    = "${lookup(var.ami,var.region)}"
  instance_type          = "${var.ec2_instance_type}"
  subnet_id              = "${element(aws_subnet.webservers.*.id,count.index)}"
  vpc_security_group_ids = ["${aws_security_group.wp_sg.id}"]
  key_name               = "${aws_key_pair.wp_key.id}"

  tags {
    Name = "web-server-${count.index}"
  }

  depends_on = ["aws_db_instance.wp_db"]
  user_data  = "${data.template_file.wp_deploy.rendered}"
}
