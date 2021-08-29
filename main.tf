terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}
provider "aws" {
  region = var.AWS_REGION
  shared_credentials_file = "~/.aws/credentials"
  profile                 = var.AWS_PROFILE
}
resource "aws_vpc" "default" {
  cidr_block            = var.VPC_CIDR_BLOCK
  instance_tenancy      = "default"
  enable_dns_support    = var.DNS_SUPPORT 
  enable_dns_hostnames  = var.DNS_HOSTNAMES
  tags = {
      Name = "default_vpc"
  }
}
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.default.id
}
resource "aws_route_table" "Public_RT" {
  vpc_id = aws_vpc.default.id
  tags = {
        Name = "public_route_table"
    }
}
resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.Public_RT.id
  destination_cidr_block = var.PUBLIC_DEST_CIDR_BLOCK
  gateway_id             = aws_internet_gateway.gw.id
}
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.default.id
  cidr_block              = var.PUBLIC_CIDR_BLOCK
  availability_zone       = var.DEFAULT_AZ[var.AWS_REGION]
  map_public_ip_on_launch = true
  depends_on              = [aws_internet_gateway.gw]
  tags = {
    Name = "public_subnet"
  }
}
resource "aws_route_table_association" "Public_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.Public_RT.id
}
resource "aws_key_pair" "deployer" {
    key_name   = "deployer-key"
    public_key = file(var.PATH_TO_PUBLIC_KEY)
}
data "template_file" "userdata_win" {
  template = <<EOF
<powershell>
net user ${var.INSTANCE_USERNAME} '${var.INSTANCE_PASSWORD}' /add /y
net localgroup administrators ${var.INSTANCE_USERNAME} /add
winrm quickconfig -q
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="300"}'
winrm set winrm/config '@{MaxTimeoutms="1800000"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
netsh advfirewall firewall add rule name="WinRM 5985" protocol=TCP dir=in localport=5985 action=allow
netsh advfirewall firewall add rule name="WinRM 5986" protocol=TCP dir=in localport=5986 action=allow
net stop winrm
sc.exe config winrm start=auto
net start winrm
</powershell>
EOF
}
resource "aws_security_group" "allow_rdp_and_winrm" {
  name    = "allow_rdp_and_winrm"
  vpc_id  = aws_vpc.default.id
  egress {
    from_port     = 0
    to_port       = 0
    protocol      = "-1"
    cidr_blocks   = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = [var.ALLOWED_INGRESS_CIDR_BLOCK]
  }
  ingress {
    from_port   = 5985
    to_port     = 5985
    protocol    = "tcp"
    cidr_blocks = [var.ALLOWED_INGRESS_CIDR_BLOCK]
  }
  tags = {
      Name = "allow_rdp_and_winrm"
  } 
}

resource "aws_instance" "windows" {
  ami                     = var.WIN_AMIS[var.AWS_REGION]
  instance_type           = var.INSTANCE_TYPE
  private_ip              = var.INSTANCE_IP
  subnet_id               = aws_subnet.public_subnet.id
  key_name                = aws_key_pair.deployer.key_name
  user_data               = data.template_file.userdata_win.rendered
  vpc_security_group_ids  = [ aws_security_group.allow_rdp_and_winrm.id ]
  provisioner "file" {
    source      = "test.txt"
    destination = "C:/test.txt"
  }
  connection {
    host      = coalesce(self.public_ip, self.private_ip)
    type      = "winrm"
    timeout   = "10m"
    user      = var.INSTANCE_USERNAME
    password  = var.INSTANCE_PASSWORD
  }
}
resource "aws_eip" "eip" {
  vpc                       = true
  instance                  = aws_instance.windows.id
  associate_with_private_ip = var.INSTANCE_IP
  depends_on                = [aws_internet_gateway.gw]
}
