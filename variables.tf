variable "aws_region" {
  type = string
  description = "region where AWS resources are created by default"
  default = "us-east-1"
}

variable "aws_ami_id" {
  type = string
  description = "AMI id of the AWS instance"
  default = "ami-0e8a34246278c21e4"
}

variable "aws_instance_count" {
  type = number
  description = "AWS EC2 instance count"
  default = 1
}

variable "aws_instance_type" {
  type = string
  description = "AWS instance type"
  default = "t3.micro"
}