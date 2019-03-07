data "aws_availability_zones" "available" {}
data "aws_region" "current" {}

module "vpc-dev" {
  source = "../../modules/networking/vpc"

  name = "vpc-dev"
  cidr = "10.8.252.0/22"

  #azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  #azs             = ["eu-west-1a", "eu-west-1b"]
  azs = ["${data.aws_availability_zones.available.names[0]}", "${data.aws_availability_zones.available.names[1]}"]

  private_subnets = ["10.8.254.0/24", "10.8.255.0/24"]
  public_subnets  = ["10.8.252.0/24", "10.8.253.0/24"]

  map_public_ip_on_launch = true

  enable_dhcp_options = true

  enable_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  dhcp_options_domain_name         = "${data.aws_region.current.name == "us-east-1" ? "ec2.internal" : format("%s.compute.internal", data.aws_region.current.name)}"
  dhcp_options_domain_name_servers = ["AmazonProvidedDNS"]

  single_nat_gateway = true

  #one_nat_gateway_per_az = true

  # VPC endpoint for S3
  enable_s3_endpoint = true
  # VPC endpoint for DynamoDB
  enable_dynamodb_endpoint = false
  tags = {
    Owner       = "Pankaj"
    Terraform   = "true"
    Environment = "dev"
  }
  vpc_tags = {
    Name = "vpc-dev"
  }
  public_subnet_tags = {
    Access = "public"
  }
  private_subnet_tags = {
    Access = "private"
  }

}

/*
module "vpc-ppd" {
  source = "../../modules/networking/vpc"

  name = "vpc-ppd"
  cidr = "10.8.240.0/22"

  #azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  #azs             = ["eu-west-1a", "eu-west-1b"]
  azs              = ["${data.aws_availability_zones.available.names[0]}", "${data.aws_availability_zones.available.names[1]}"]

  private_subnets = ["10.8.243.0/24", "10.8.242.0/24"]
  public_subnets  = ["10.8.240.0/24", "10.8.241.0/24"]

  map_public_ip_on_launch = true

  enable_dhcp_options = true

  enable_nat_gateway = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  dhcp_options_domain_name         = "${data.aws_region.current.name == "us-east-1" ? "ec2.internal" : format("%s.compute.internal", data.aws_region.current.
  name)}"
  dhcp_options_domain_name_servers = ["AmazonProvidedDNS"]


  single_nat_gateway = true
  #one_nat_gateway_per_az = true

  # VPC endpoint for S3
  enable_s3_endpoint = true

  # VPC endpoint for DynamoDB
  enable_dynamodb_endpoint = false


  tags = {
    Owner       = "Pankaj"
    Terraform   = "true"
    Environment = "ppd"
  }

  vpc_tags = {
    Name = "vpc-ppd"
  }

}

module "vpc-prd" {
  source = "../../modules/networking/vpc"

  name = "vpc-prd"
  cidr = "10.8.244.0/22"

  #azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  #azs             = ["eu-west-1a", "eu-west-1b"]
  azs              = ["${data.aws_availability_zones.available.names[0]}", "${data.aws_availability_zones.available.names[1]}"]

  private_subnets = ["10.8.246.0/24", "10.8.247.0/24"]
  public_subnets  = ["10.8.244.0/24", "10.8.245.0/24"]


  map_public_ip_on_launch = true

  enable_dhcp_options = true

  enable_nat_gateway = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  dhcp_options_domain_name         = "${data.aws_region.current.name == "us-east-1" ? "ec2.internal" : format("%s.compute.internal", data.aws_region.current.
    name)}"
  dhcp_options_domain_name_servers = ["AmazonProvidedDNS"]

  single_nat_gateway = true
  #one_nat_gateway_per_az = true

  # VPC endpoint for S3
  enable_s3_endpoint = true

  # VPC endpoint for DynamoDB
  enable_dynamodb_endpoint = false

  tags = {
    Owner       = "Pankaj"
    Terraform   = "true"
    Environment = "prd"
  }

  vpc_tags = {
    Name = "vpc-prd"
  }

}

*/


/*
output "ppd_vpc_id" {
  value       = "${module.vpc-ppd.vpc_id}"
  description = "VPC PPD Id peering connection ID"
}

output "dev-vpc_id" {
  description = "The DEV ID of the VPC"
     value       = "${module.vpc-dev.vpc_id}"
}

*/


/*
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

output "aws_vpc_ppd" {
  value = "${data.aws_vpc.vpc-ppd.id}"
}

output "aws_vpc_dev" {
  value = "${data.aws_vpc.vpc-dev.id}"
}
*/

