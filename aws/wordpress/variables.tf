variable "aws_secret_key" {}

variable "aws_access_key" {}

variable "region" {
  description = "The AWS region."
  default     = "eu-west-1"
}

variable "ami" {
  description = "Amazon Machine Image (AMI)"

  default = {
    eu-west-1  = "ami-0ff760d16d9497662"
    eu-west-2  = "ami-01419b804382064e4"
    eu-west-3  = "ami-0dd7e7ed60da8fb83"
    ap-south-1 = "ami-0937dcc711d38ef3f"
  }

  type = "map"
}

variable "instance_user" {
  description = "aws ami ssh user"
  default     = "ec2-user"
}

variable "vpc_cidr" {
  default = "192.50.0.0/16"
}

variable "vpc_tenency" {
  default = "default"
}

variable "cidr_webservers" {
  type    = "list"
  default = ["192.50.1.0/24", "192.50.2.0/24"]
}

variable "cidr_rds" {
  type    = "list"
  default = ["192.50.3.0/24", "192.50.4.0/24"]
}

variable "ec2_instance_type" {
  default = "t2.micro"
}

variable "rds_instance_type" {
  default = "db.t2.micro"
}

variable "web_servers_count" {
  default = "1"
}

#variable "db_sub_count" {
#  default = "2"
#}

variable "db_password" {
  default = "root@1234"
}

variable "db_user" {
  default = "admin"
}

variable "rds_storage_gb" {
  default = "50"
}

variable "rds_engine" {
  default = "mysql"
}

variable "rds_engine_version" {
  default = "5.7.22"
}
