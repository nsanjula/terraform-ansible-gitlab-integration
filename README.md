# Terraform, Ansible, and GitLab CI/CD AWS Automation Project

## Project Overview

This project demonstrates an Infrastructure as Code and configuration automation workflow for provisioning and configuring an AWS EC2 based web server environment. The project combines Terraform for infrastructure provisioning, Ansible for server configuration, and GitLab CI/CD concepts for automating the full delivery flow.

The main goal of the project is to show how cloud infrastructure can be created, configured, and managed through code instead of manual console operations. It focuses on a practical DevOps workflow where infrastructure creation, remote server configuration, state management, security scanning, and cleanup can be handled through a pipeline-driven process.

## What This Project Demonstrates

- AWS infrastructure provisioning using Terraform
- EC2 instance creation with configurable AMI, instance type, region, and instance count
- Security group configuration for SSH, HTTP, and outbound access
- SSH key pair management for connecting to the provisioned instance
- Terraform remote state design using GitLab's HTTP backend
- Dynamic inventory generation for Ansible using Terraform output data
- Server configuration with Ansible after infrastructure provisioning
- Apache HTTP server installation and startup on the EC2 instance
- Deployment of a simple static `index.html` page to the web server
- GitLab CI/CD workflow design for formatting, initialization, validation, scanning, deployment, configuration, and destruction

## Architecture Summary

The project follows a simple DevOps automation architecture:

![GitLab pipeline architecture](images/Gitlab%20pipeline.png)

Terraform is responsible for building the infrastructure layer in AWS. After the EC2 instance is created, its public IP address is written into a `hosts` file. That file acts as the Ansible inventory, allowing the configuration stage to connect to the instance and install the required software.

Ansible then connects to the EC2 instance using SSH, installs Apache HTTP Server, enables and starts the service, and copies the project web page into the Apache document root.

## Terraform Infrastructure Layer

Terraform is used as the Infrastructure as Code tool for defining and provisioning the AWS resources. The configuration is split across multiple files to keep the project organized and easy to understand.

### Provider Configuration

The AWS provider is configured through a variable-based region value. This keeps the region flexible and allows the same code structure to be reused with different AWS regions.

### EC2 Instance Provisioning

The main infrastructure resource is an AWS EC2 instance. The instance configuration is controlled through variables for:

- AWS region
- AMI ID
- Instance type
- Instance count

This approach avoids hard-coding important infrastructure values directly into the resource logic and makes the configuration easier to update.

Each EC2 instance is tagged with a `Name` and `Environment` value. Tagging helps identify provisioned resources inside AWS and reflects a basic cloud resource management practice.

### Security Group Configuration

The security group defines network access for the EC2 instance. It includes:

- SSH access on port `22`
- HTTP access on port `80`
- Outbound IPv4 traffic
- Outbound IPv6 traffic

This allows the server to be accessed for administration through SSH and viewed as a web server through HTTP.

### SSH Key Pair

The Terraform configuration creates an AWS key pair using a local public key file. This key pair is attached to the EC2 instance so that the server can be accessed securely through SSH during the Ansible configuration stage.

The private key is intentionally excluded from version control through `.gitignore`, which reflects the importance of keeping sensitive access credentials out of the repository.

### Hosts File Generation

After the EC2 instance is provisioned, Terraform uses a local execution step to write the instance public IP address into a `hosts` file. This file is used as a dynamic Ansible inventory.

This connects the infrastructure provisioning stage with the configuration management stage. Instead of manually copying the instance IP address, the workflow passes the created server information forward automatically.

## GitLab Terraform State Management

The project is designed to use Terraform's `http` backend, which supports storing Terraform state remotely in GitLab.

Remote state is important in CI/CD based infrastructure workflows because pipeline jobs may run on different runners or machines. Without remote state, each pipeline execution could lose track of the already-created infrastructure.

The GitLab-backed Terraform state approach allows:

- Centralized state storage
- State reuse across pipeline stages
- Locking and unlocking during Terraform operations
- Safer collaboration compared with local-only state files

The backend is intentionally declared as an HTTP backend so that GitLab CI/CD variables can provide backend details such as the state address, lock address, unlock address, username, and token.

## GitLab CI/CD Workflow Design

The project is based on a pipeline-driven DevOps workflow. The intended CI/CD process separates the work into clear stages:

```text
format -> init -> validate -> security-scan -> apply -> configure -> destroy
```

### Format Stage

The format stage checks Terraform formatting. This helps keep the Terraform files consistent and readable.

### Init Stage

The init stage initializes Terraform and configures the GitLab HTTP backend. This prepares Terraform to download providers and use remote state.

The `.terraform` directory and lock file can be cached between stages so later jobs can reuse the initialized provider data instead of starting from scratch.

### Validate Stage

The validate stage checks whether the Terraform configuration is syntactically valid and internally consistent before infrastructure changes are applied.

### Security Scan Stage

The security scan stage is designed to use a Terraform security scanning tool such as `tfsec`. This adds a security review step before infrastructure is deployed.

Security scanning helps detect risky infrastructure patterns early, such as overly permissive network rules or insecure cloud resource configurations.

### Apply Stage

The apply stage provisions the AWS infrastructure. AWS credentials are expected to be provided securely through GitLab CI/CD variables.

After Terraform creates the EC2 instance, the generated `hosts` file is preserved as a pipeline artifact so the Ansible configuration job can use it.

### Configure Stage

The configure stage runs Ansible against the newly created EC2 instance. SSH access is handled through a private key stored securely as a GitLab CI/CD variable.

This stage installs and configures the application server environment after the infrastructure exists.

### Destroy Stage

The destroy stage is designed as a manual cleanup step. Manual destruction is useful because infrastructure removal should usually require explicit approval instead of happening automatically after every pipeline run.

## Ansible Configuration Layer

Ansible is used to configure the EC2 instance after Terraform provisions it.

The playbook performs three main tasks:

- Installs Apache HTTP Server using `yum`
- Starts and enables the Apache service
- Copies the project `index.html` file to `/var/www/html/index.html`

The playbook runs with privilege escalation enabled because installing packages and writing to the Apache web root require elevated permissions.

This shows the separation between infrastructure provisioning and server configuration:

- Terraform creates the server and network resources
- Ansible configures the software inside the server

## Web Server Output

The repository includes a simple `index.html` page that is deployed by Ansible to the EC2 instance. Once Apache is installed and started, the instance can serve this page over HTTP.

This gives the project a visible deployment result instead of stopping at infrastructure creation only.

## Repository Structure

```text
terraform-ansible-gitlab-integration/
├── README.md
├── .gitignore
├── backend.tf
├── provider.tf
├── variables.tf
├── main.tf
├── security-group.tf
├── key-pair.tf
├── provisioning.yaml
├── index.html
└── terra-gitlab-key.pub
```

### File Responsibilities

| File                | Purpose                                                                         |
| ------------------- | ------------------------------------------------------------------------------- |
| `backend.tf`        | Defines the Terraform HTTP backend for GitLab remote state integration          |
| `provider.tf`       | Configures the AWS provider                                                     |
| `variables.tf`      | Defines configurable Terraform inputs                                           |
| `main.tf`           | Creates EC2 instances and generates the Ansible hosts inventory                 |
| `security-group.tf` | Defines inbound and outbound network rules                                      |
| `key-pair.tf`       | Creates the AWS SSH key pair from a public key                                  |
| `provisioning.yaml` | Configures the EC2 instance with Apache using Ansible                           |
| `index.html`        | Static web page deployed to the Apache server                                   |
| `.gitignore`        | Prevents Terraform state, variable files, and key material from being committed |

## Project Outcome

The completed workflow represents an automated path from source code to a configured AWS web server. Terraform provisions the infrastructure, GitLab CI/CD manages the automation flow and remote state, and Ansible configures the instance to serve a web page through Apache.
