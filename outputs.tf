output "ip" {
    value = aws_eip.eip.public_ip
}

output "fqdn" {
    value = aws_eip.eip.public_dns
}
