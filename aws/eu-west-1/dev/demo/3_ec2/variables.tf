variable "access_key" {
  description = "The AWS access key."
}

variable "secret_key" {
  description = "The AWS secret key."
}

variable "region" {
  description = "The AWS region."
  #default     = "eu-west-1"
}

variable "ami" {
  description = "Amazon Machine Image (AMI) is a special type of virtual appliance that is used to create a virtual machine within the Amazon Elastic Compute Cloud (EC2)."

  default = {
    eu-west-1  = "ami-08935252a36e25f85"
    eu-west-2  = "ami-01419b804382064e4"
    eu-west-3  = "ami-0dd7e7ed60da8fb83"
    ap-south-1 = "ami-0937dcc711d38ef3f"
  }

  type = "map"
}

variable "instance_type" {
  description = "Amazon EC2 provides a wide selection of instance types optimized to fit different use cases. Instance types comprise varying combinations of CPU, memory, storage, and networking capacity and give you the flexibility"
  default     = "t2.micro"
}
