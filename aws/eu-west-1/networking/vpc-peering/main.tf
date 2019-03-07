data "aws_vpc" "vpc-ppd" {
  tags {
    Name = "vpc-ppd"
  }
}

data "aws_vpc" "vpc-dev" {
  tags {
    Name = "vpc-dev"
  }
}

module "vpc_peering-ppd-dev" {
  source = "../../modules/networking/vpc-peering"
  namespace        = "cp"
  stage            = "dev"
  name             = "cluster"
  requestor_vpc_id = "${data.aws_vpc.vpc-ppd.id}"
  acceptor_vpc_id  = "${data.aws_vpc.vpc-dev.id}"

  tags = {
    Owner       = "Pankaj"
    Terraform   = "true"
  }

  vpc_peering_tags = {
    Name = "vpc-peering-ppd-dev"
  }
}

/*
output "aws_vpc_ppd" {
   value = "${data.aws_vpc.vpc-ppd.id}"
}

output "aws_vpc_dev" {
   value = "${data.aws_vpc.vpc-dev.id}"
}
*/
