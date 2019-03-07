resource "aws_instance" "hello_instance" {
  ami           = "${lookup(var.ami,var.region)}"
  instance_type = "${var.instance_type}"
  key_name      = "${aws_key_pair.demo_key.id}"
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
  vpc = true
}

output "eip" {
  value = "${aws_eip.hello_eip.public_ip}"
}
