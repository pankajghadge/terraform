data "aws_vpc" "vpc_dev" {
  tags {
    Name = "vpc-dev"
  }
}

data "aws_subnet_ids" "vpc_dev_public_subnets" {
  vpc_id = "${data.aws_vpc.vpc_dev.id}"
  tags {
    Access = "public"
  }
}

data "aws_subnet" "vpc_dev_public_subnets" {
  count = "${length(data.aws_subnet_ids.vpc_dev_public_subnets.ids)}"
  id    = "${data.aws_subnet_ids.vpc_dev_public_subnets.ids[count.index]}"
}

data "aws_subnet_ids" "vpc_dev_private_subnets" {
  vpc_id = "${data.aws_vpc.vpc_dev.id}"
  tags {
    Access = "private"
  }
}

data "aws_subnet" "vpc_dev_private_subnets" {
  count = "${length(data.aws_subnet_ids.vpc_dev_private_subnets.ids)}"
  id    = "${data.aws_subnet_ids.vpc_dev_private_subnets.ids[count.index]}"
}

output "dev_public_subnet_ids" {
  value = ["${data.aws_subnet.vpc_dev_public_subnets.*.id}"]
}

output "dev_private_subnet_ids" {
  value = ["${data.aws_subnet.vpc_dev_private_subnets.*.id}"]
}

/*
output "aws_vpc_dev" {
  value = "${data.aws_vpc.vpc_dev.id}"
}

output "subnet_cidr_blocks" {
  value = ["${data.aws_subnet.dev_public_subnets.*.id}"]
}

output "aws_vpc_dev_public_subnet" {
  value = "${data.aws_subnet_ids.vpc_dev_public_subnets.*.id}"
}
*/
