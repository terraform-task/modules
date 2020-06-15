variable "region" {
    default = "us-east-2"
}

variable "aws_access_key" {
    default = ""
}

variable "aws_secret_key" {
    default = ""
}

variable "key_name" {
    default = "terraform"
}

variable "private_key_path" {
    default = "/home/lalitsharma/Downloads/terraform.pem"
}

variable "cidr" {
    default = "172.23.0.0/16"
}

variable "terraform_sb_pb_count" {
    default = "2"
}

variable "terraform_sb_pv_count" {
    default = "2"
}











