provider "aws" {
  region = "${var.aws_region}"
}
resource "aws_vpc" "consul-vpc" {
  cidr_block           = "${var.vpc_config.cidr}"
  enable_dns_hostnames = "${var.vpc_config.enable_dns_hostnames}"
  tags = {
    Name = "${var.vpc_config.name}"
  }
}
resource "aws_internet_gateway" "consul-igw" {
  vpc_id = "${aws_vpc.consul-vpc.id}"
  tags = {
    Name = "${var.vpc_igw_name}"
  }
}
resource "aws_security_group" "consul-sec-group" {
  vpc_id = "${aws_vpc.consul-vpc.id}"
  name        = "${var.sec_group_config.name}"
  description = "${var.sec_group_config.description}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
    description = "Allow all inside security group"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.sec_group_config.cidr}"]
  }

  ingress {
    from_port   = 8500
    to_port     = 8500
    protocol    = "tcp"
    cidr_blocks = ["${var.sec_group_config.cidr}"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["${var.sec_group_config.cidr}"]
  }
  tags = {
    Name = "${var.sec_group_config.name}"
  }
}
resource "aws_subnet" "consul-public-subnet" {
  vpc_id                  = "${aws_vpc.consul-vpc.id}"
  cidr_block              = "${var.subnet_config.cidr}"
  availability_zone       = "${var.subnet_config.av_zone}"
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.subnet_config.name}"
  }
}
resource "aws_route_table" "consul-public-rt" {
  vpc_id = "${aws_vpc.consul-vpc.id}"
  route {
    cidr_block = "${var.public_rt.cidr}"
    gateway_id = "${aws_internet_gateway.consul-igw.id}"
  }
  tags = {
    Name = "${var.public_rt.name}"
  }
}
resource "aws_route_table_association" "consul-rt-assoc" {
  subnet_id       = "${aws_subnet.consul-public-subnet.id}"
  route_table_id  = "${aws_route_table.consul-public-rt.id}"
}