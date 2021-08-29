variable "AWS_REGION" { default = "us-east-1" }
variable "AWS_PROFILE" {  }
variable "WIN_AMIS" {
    type = map
    default = { 
      us-east-1 = "ami-029bfac3973c1bda1"
      us-west-2 = "ami-0e9172b6cfc14e8d2"
    }
}
variable "DEFAULT_AZ" {
    type = map
    default = { 
      us-east-1 = "us-east-1a"
      us-west-2 = "us-west-2a"
    }
}
variable "PATH_TO_PRIVATE_KEY" { default = "~/.ssh/id_rsa" }
variable "PATH_TO_PUBLIC_KEY" { default = "~/.ssh/id_rsa.pub" }
variable "INSTANCE_USERNAME" { default = "admin" }
variable "INSTANCE_PASSWORD" { }
variable "PUBLIC_DEST_CIDR_BLOCK" {
    default = "0.0.0.0/0"
}
variable "VPC_CIDR_BLOCK" {
    default = "10.0.0.0/16"
}
variable "PUBLIC_CIDR_BLOCK" {
    default = "10.0.1.0/24"
}
variable "INSTANCE_IP" {
    default = "10.0.1.100"
}
variable "INSTANCE_TYPE" {
    default = "t2.micro"
}
variable "DNS_SUPPORT" {
    default = true
}
variable "DNS_HOSTNAMES" {
    default = true
}
variable "ALLOWED_INGRESS_CIDR_BLOCK" {
    default = "0.0.0.0/0"
}
