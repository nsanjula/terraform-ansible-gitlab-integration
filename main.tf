resource "aws_instance" "web" {
  ami           = var.aws_ami_id
  instance_type = var.aws_instance_type
  count = var.aws_instance_count
  security_groups = [aws_security_group.terra-gitlab-sg.id]
  key_name = aws_key_pair.terra-gitlab-key.key_name

  tags = {
    Name = "webserver-${count.index}"
    Environment = "dev"
  }
}