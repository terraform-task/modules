
######### provider ############

provider "aws" {
    region = var.region
    access_key = var.aws_access_key
    secret_key = var.aws_secret_key
}

######### VPC ###########

resource "aws_vpc" "terraform_vpc" {
    cidr_block = "${var.cidr}"
    tags = {
        Name = "terraform_vpc"
    }
}

######### IGW ############

resource "aws_internet_gateway" "terraform_gw" {
    vpc_id = "${aws_vpc.terraform_vpc.id}"
    tags = {
        Name = "terraform_gw"
    }
}

######## Public subnet and route table and NAT  ###########

resource "aws_subnet" "terraform_sb_pb" {
    count = var.terraform_sb_pb_count
    vpc_id  = "${aws_vpc.terraform_vpc.id}"
    map_public_ip_on_launch = true
    cidr_block = cidrsubnet(var.cidr,8,count.index)
    tags = {
        Name = "terraform_sb_pb"
    }
}

resource "aws_route_table" "terraform_rt_pb" {
    vpc_id = "${aws_vpc.terraform_vpc.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.terraform_gw.id}"
    }
    tags = {
      Name = "terraform_rt_pb"
    }
}

resource "aws_route_table_association" "pb" {
    count = var.terraform_sb_pb_count
    subnet_id = aws_subnet.terraform_sb_pb[count.index].id
    route_table_id = aws_route_table.terraform_rt_pb.id

}


resource "aws_eip" "byoip-ip" {
  vpc              = true
  public_ipv4_pool = "amazon"
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = "${aws_eip.byoip-ip.id}"
  subnet_id     = "${aws_subnet.terraform_sb_pb[0].id}"
}

######## Private subnet , route table  ###########

resource "aws_subnet" "terraform_sb_pv" {
    count = var.terraform_sb_pv_count
    vpc_id  = "${aws_vpc.terraform_vpc.id}"
    cidr_block = cidrsubnet(var.cidr,8,count.index + 2)
    tags = {
        Name = "terraform_sb_pv"
    }
}


resource "aws_route_table" "terraform_rt_pv" {
    vpc_id = "${aws_vpc.terraform_vpc.id}"
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat_gw.id
    }
    tags = {
      Name = "terraform_rt_pv"
    }
}

resource "aws_route_table_association" "pv" {
    count = var.terraform_sb_pv_count
    subnet_id = aws_subnet.terraform_sb_pv[count.index].id
    route_table_id = aws_route_table.terraform_rt_pv.id

}

############ Security group ###########
resource "aws_security_group" "Jumphost_terraform" {
  name   = "Jumphost_terraform_sg"
  vpc_id = aws_vpc.terraform_vpc.id

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

####### Bastion (jumpserver) ############

resource "aws_instance" "jumphost" {
  ami           = "ami-07c1207a9d40bc3bd"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.terraform_sb_pb[0].id
  key_name = var.key_name

  tags = {
    Name = "Jumphost_terraform"
  }
}

########## Output ###########

output "vpc_id" {
    value = aws_vpc.terraform_vpc.id
}

output "igw_id" {
    value = aws_internet_gateway.terraform_gw.vpc_id
}

output "public_subnet" {

    value = aws_subnet.terraform_sb_pb.*.id
}

output "private_subnet" {
    value = aws_subnet.terraform_sb_pv.*.id
}

output "elastic_ip_nat" {
    value = aws_eip.byoip-ip.id
}

output "natgateway_id" {
    value = aws_nat_gateway.nat_gw.*.id
}

output "sg_terraform" {
    value = aws_security_group.Jumphost_terraform.id
}

output "instance" {
    value = aws_instance.jumphost.id
}



