# Create the user-data for the Consul server
data "template_file" "consul-server" {
  count    = "${var.server.count}"
  template = "${file("templates/consul.sh.tpl")}"
  vars = {
    role = "server"
    consul_version = "${var.consul_version}"
    config = <<EOF
     "bootstrap_expect": ${var.server.count},
     "node_name": "${var.server.prefix}-${count.index+1}",
     "retry_join": ["provider=aws tag_key=${var.consul_join.tag_key} tag_value=${var.consul_join.tag_value}"],
     "ui": true,
     "client_addr": "0.0.0.0",
     "server": true
    EOF
  }
}

# Create the user-data for the Consul server
data "template_file" "consul-client" {
  count    = "${var.client.count}"
  template = "${file("templates/consul.sh.tpl")}"
  vars = {
    role = "client"
    consul_version = "${var.consul_version}"
    config = <<EOF
     "node_name": "${var.client.prefix}-${count.index+1}",
     "retry_join": ["provider=aws tag_key=${var.consul_join.tag_key} tag_value=${var.consul_join.tag_value}"],
     "enable_script_checks": true,
     "server": false
    EOF
  }
}
data "aws_ami" "ubuntu" { # Get latest ubuntu server
    most_recent = true
    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server*"]
    }
    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }
    owners = ["099720109477"] # Canonical
}
resource "aws_instance" "consul-server" {
  count                  = "${var.server.count}"
  ami                    = "${data.aws_ami.ubuntu.id}"
  instance_type          = "${var.ec2_instance.type}"
  iam_instance_profile   = "${aws_iam_instance_profile.consul-join.name}"
  key_name               = "${var.ec2_instance.key_pair_name}"
  vpc_security_group_ids = ["${aws_security_group.consul-sec-group.id}"]
  subnet_id              = "${aws_subnet.consul-public-subnet.id}"
  tags = {
    Name = "${var.server.prefix}-${count.index+1}"
    "${var.consul_join.tag_key}" = "${var.consul_join.tag_value}"
  }
  user_data = "${element(data.template_file.consul-server.*.rendered, count.index)}"
}
resource "aws_instance" "consul-client" {
  count                  = "${var.client.count}"
  ami                    = "${data.aws_ami.ubuntu.id}"
  instance_type          = "${var.ec2_instance.type}"
  iam_instance_profile   = "${aws_iam_instance_profile.consul-join.name}"
  key_name               = "${var.ec2_instance.key_pair_name}"
  vpc_security_group_ids = ["${aws_security_group.consul-sec-group.id}"]
  subnet_id              = "${aws_subnet.consul-public-subnet.id}"
  tags = {
    Name = "${var.client.prefix}-${count.index+1}"
    "${var.consul_join.tag_key}" = "${var.consul_join.tag_value}"
  }
  user_data = "${element(data.template_file.consul-client.*.rendered, count.index)}"
}