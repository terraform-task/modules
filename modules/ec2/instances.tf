
############### provider ###############

provider "aws" {
  region = var.region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}
  

###############  modules #############

module "vpc" {
    source = "/home/lalitsharma/hard_disk/learning/terraform/opstree_tf_1/modules/vpc"
    aws_access_key  = ""
    aws_secret_key  = ""
    key_name  = "terraform"
    private_key_path = "/home/lalitsharma/Downloads/terraform.pem"
    region  = "us-east-2"
    cidr  = "172.23.0.0/16"
    terraform_sb_pb_count = 2
    terraform_sb_pv_count = 2
}

############### resources ###############

resource "aws_instance" "ec2" {
  count = var.terraform_ec2_count
  ami           = "ami-07c1207a9d40bc3bd"
  instance_type = "t2.micro"
  subnet_id = element(module.vpc.public_subnet,count.index)
  key_name = var.key_name
}

############## output ##########
output "instance" {
    value = aws_instance.ec2[*].id
}
