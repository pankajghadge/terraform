resource "aws_instance" "hello_instance" {
  ami           = "ami-08935252a36e25f85"
  instance_type = "t2.micro"
  key_name      = "${aws_key_pair.demo1-key.id}"
}

resource "aws_key_pair" "demo_key" {
  key_name   = "demo1-key"
  public_key = "${file("files/demo1-key.pub")}"
}

output "public_ip" {
    value = "${aws_instance.hello_instance.public_ip}"
}
