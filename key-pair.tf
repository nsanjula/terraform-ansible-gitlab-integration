resource "aws_key_pair" "terra-gitlab-key" {
  key_name   = "terra-gitlab-key"
  public_key = file("./terra-gitlab-key.pub")
}