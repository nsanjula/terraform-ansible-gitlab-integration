# Terraform Ansible GitLab Integration

This project contains a simple Terraform setup for provisioning AWS EC2
instances. It is intended to be used with GitLab CI/CD and can generate a
local `hosts` file containing the public IP addresses of the created instances.

## What It Creates

- AWS EC2 instance(s)
- AWS key pair from a local public key
- Security group rules for SSH, HTTP, and outbound traffic
- A generated `hosts` file with instance public IP addresses

## Project Files

- `provider.tf` - AWS provider configuration
- `backend.tf` - Terraform HTTP backend configuration
- `variables.tf` - Input variable definitions
- `terraform.tfvars` - Local variable values, ignored by Git
- `main.tf` - EC2 instance and hosts file generation
- `security-group.tf` - Security group and network rules
- `key-pair.tf` - AWS key pair resource

## Required Inputs

The project expects these variables:

```hcl
aws_region         = "us-east-1"
aws_ami_id         = "ami-xxxxxxxxxxxxxxxxx"
aws_instance_count = 1
aws_instance_type  = "t3.micro"
```

## Usage

Initialize Terraform:

```bash
terraform init
```

Check the configuration:

```bash
terraform validate
```

Preview changes:

```bash
terraform plan
```

Apply changes:

```bash
terraform apply
```

Destroy resources:

```bash
terraform destroy
```

## GitLab Backend

The backend is configured as an HTTP backend:

```hcl
terraform {
  backend "http" {}
}
```

Backend settings such as address, lock address, unlock address, username, and
password/token should be provided during `terraform init`, usually through
GitLab CI/CD variables.

## SSH Key

The Terraform key pair uses:

```hcl
file("./terra-gitlab-key.pub")
```

Keep the private key secure and do not commit it to Git.

## Notes

- Make sure AWS credentials are available before running Terraform.
- Review security group rules before applying in a real environment.
- The generated `hosts` file is created locally after instances are provisioned.
