variable "aws_region" {
  type = string
  description = "region where AWS resources are created by default"
}

variable "aws_ami_id" {
  type = string
  description = "AMI id of the AWS instance"
}

variable "aws_instance_count" {
  type = number
  description = "AWS EC2 instance count"
}

variable "aws_instance_type" {
  type = string
  description = "AWS instance type"
}