# create the VPC
resource "aws_vpc" "My_Terra_VPC" {
  cidr_block             = "${var.vpc_CIDR_block}"
  tags = {
    Namer= "My Terra VPC"
  }
}

# create the Subnet
resource "aws_subnet" "My_Terra_VPC_Subnet" {
  vpc_id                  = "${aws_vpc.My_Terra_VPC.id}"
  cidr_block              = "${var.subnet_CIDR_block}"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "My Terra VPC Public Subnet"
  }
}

# create the Runner Subnet
resource "aws_subnet" "My_Terra_VPC_Runner_Subnet" {
  vpc_id                  = "${aws_vpc.My_Terra_VPC.id}"
  cidr_block              = "${var.runner_subnet_CIDR_block}"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "My Terra VPC Runner Subnet"
  }
}

# Create the Runners Security Group
resource "aws_security_group" "My_Terra_VPC_Runner_SG" {
  vpc_id        = "${aws_vpc.My_Terra_VPC.id}"
  name          = "My Terra VPC Runners Security Group"
  ingress {
    cidr_blocks = ["${var.subnet_CIDR_block}","${var.terraform_self_IP}"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
  tags = {
    Name = "My Terra VPC Runners Security Group"
  }
}

# Create the Bastion Security Group
resource "aws_security_group" "My_Terra_VPC_Bastion_SG" {
  vpc_id        = "${aws_vpc.My_Terra_VPC.id}"
  name          = "My Terra VPC Bastion Security Group"
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
  tags = {
    Name = "My Terra VPC Bastion Security Group"
  }
}

# Create the Internet Gateway
resource "aws_internet_gateway" "My_Terra_VPC_IGW" {
  vpc_id = "${aws_vpc.My_Terra_VPC.id}"
  tags = {
    Name = "My Terra VPC Internet Gateway"
    }
}

resource "aws_eip" "NAT_EIP" {
  vpc = true
}

# Create the NAT Gateway
resource "aws_nat_gateway" "My_Terra_VPC_NAT" {
  allocation_id = "${aws_eip.NAT_EIP.id}"
  subnet_id     = "${aws_subnet.My_Terra_VPC_Subnet.id}"
}

# Create the Route Table
resource "aws_route_table" "My_Terra_VPC_route_table" {
  vpc_id = "${aws_vpc.My_Terra_VPC.id}"
  depends_on   = ["aws_nat_gateway.My_Terra_VPC_NAT"]
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.My_Terra_VPC_IGW.id}"
  }
  tags = {
    Name = "My Terra VPC Route Table"
    }
}

# Create the Runner Subnet Route Table
resource "aws_route_table" "My_Terra_VPC_Runner_route_table" {
  vpc_id = "${aws_vpc.My_Terra_VPC.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.My_Terra_VPC_IGW.id}"
  }
  route {
    cidr_block = "${var.gitlab_self_IP}"
    nat_gateway_id = "${aws_nat_gateway.My_Terra_VPC_NAT.id}"
  }
  tags = {
    Name = "My Terra VPC Runner Route Table"
    }
}

# Associate the Route Table with the Subnet
resource "aws_route_table_association" "My_Terra_VPC_association" {
  subnet_id      = "${aws_subnet.My_Terra_VPC_Subnet.id}"
  route_table_id = "${aws_route_table.My_Terra_VPC_route_table.id}"
}

# Associate the Route Table with the Subnet
resource "aws_route_table_association" "My_Terra_VPC_Runner_association" {
  subnet_id      = "${aws_subnet.My_Terra_VPC_Runner_Subnet.id}"
  route_table_id = "${aws_route_table.My_Terra_VPC_Runner_route_table.id}"
}
