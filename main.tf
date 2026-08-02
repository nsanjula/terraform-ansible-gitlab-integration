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

resource "null_resource" "hosts" {
  depends_on = [aws_instance.web]
  triggers = {
    time = "${timestamp()}"
  }
  count = length(aws_instance.web)
  provisioner "local-exec" {
    command = "echo ${element(aws_instance.web[*].public_ip, count.index)} >> ./hosts"
    when    = create
  }
  provisioner "local-exec" {
    command = "rm -f ./hosts"
    when    = destroy
  }
} 