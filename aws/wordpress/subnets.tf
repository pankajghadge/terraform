# Declare the data source
data "aws_availability_zones" "azs" {}

resource "aws_subnet" "webservers" {
  count                   = "${length(var.cidr_webservers) > 0 ? length(var.cidr_webservers) : 0}"
  vpc_id                  = "${aws_vpc.main_vpc.id}"
  cidr_block              = "${var.cidr_webservers[count.index]}"
  availability_zone       = "${data.aws_availability_zones.azs.names[count.index]}"
  map_public_ip_on_launch = true

  tags {
    Name = "Webserver-${count.index + 1}"
  }
}

resource "aws_subnet" "rds" {
  count                   = "${length(var.cidr_rds) > 0 ? length(var.cidr_rds) : 0}"
  vpc_id                  = "${aws_vpc.main_vpc.id}"
  cidr_block              = "${var.cidr_rds[count.index]}"
  availability_zone       = "${data.aws_availability_zones.azs.names[count.index]}"
  map_public_ip_on_launch = false

  tags {
    Name = "RDS-${count.index + 1}"
  }
}

resource "aws_route_table" "webservers_rt" {
  vpc_id     = "${aws_vpc.main_vpc.id}"
  depends_on = ["aws_subnet.webservers"]

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags {
    Name = "webservers_rt"
  }
}

resource "aws_route_table_association" "webservers" {
  count          = "${length(var.cidr_webservers) > 0 ? length(var.cidr_webservers) : 0}"
  subnet_id      = "${aws_subnet.webservers.*.id[count.index]}"
  route_table_id = "${aws_route_table.webservers_rt.id}"
  depends_on     = ["aws_subnet.webservers"]
}

# Create Private Route Table
resource "aws_route_table" "rds_rt" {
  vpc_id     = "${aws_vpc.main_vpc.id}"
  depends_on = ["aws_subnet.rds"]

  tags {
    Name = "rds_rt"
  }
}

resource "aws_route_table_association" "rds" {
  count          = "${length(var.cidr_rds) > 0 ? length(var.cidr_rds) : 0}"
  subnet_id      = "${aws_subnet.rds.*.id[count.index]}"
  route_table_id = "${aws_route_table.rds_rt.id}"
  depends_on     = ["aws_subnet.rds"]
}
