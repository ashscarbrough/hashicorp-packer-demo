variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "ec2_instance_ami_name" {
  type    = string
  default = "hc-base-al2023-x86_64"
}

variable "hcp_bucket_name" {
  type    = string
  default = "packer-demo-al2023"
}

variable "hcp_channel_name" {
  type    = string
  default = "dev"
}

variable "app_version" {
  type    = string
  default = "0.1"
}
