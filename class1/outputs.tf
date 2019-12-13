output "consul_servers_dns" {
    value = "${aws_instance.consul-server.*.public_dns}"
}
output "consul_clients_dns" {
    value = "${aws_instance.consul-client.*.public_dns}"
}