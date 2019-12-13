variable "aws_region" {
  default = "us-east-1"
}
variable "vpc_config" {
  default = {
    name = "consul-vpc"
    cidr = "10.0.0.0/16"
    enable_dns_hostnames = true
  }
}
variable "vpc_igw_name" {
  default = "consul-igw"
}
variable "sec_group_config" {
  default = {
    name = "consul-sec-group"
    description = "Allow ssh and consul inbound traffic"
    cidr = "0.0.0.0/0"
  }
}
variable "subnet_config" {
  default = {
    name = "consul-public-subnet"
    cidr = "10.0.1.0/24"
    av_zone = "us-east-1a"
  }
}
variable "public_rt" {
  default = {
    name = "consul-public-rt"
    cidr = "0.0.0.0/0"
  }
}
variable "ec2_instance" {
  default = {
    type = "t2.micro"
    key_pair_name = "ec2_keypair"
  }
}
variable "server" {
  default = {
    count = 3
    prefix = "consul-server"
  }
}
variable "client" {
  default = {
    count = 1
    prefix = "consul-client"
  }
}
variable "consul_join" {
  default = {
    tag_key = "consul_join"
    tag_value = true
  }
}
variable "consul_version" {
  default = "1.6.2"
}
