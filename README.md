# aws-terraform-jenkins-postgres-db-backup


## Project Overview

### Purpose

This project aims to automate the deployment and management of infrastructure using Terraform. Specifically, it focuses on:

1. **Creating an AWS RDS PostgreSQL Instance**: Using Terraform to provision a managed PostgreSQL database.
2. **Deploying Jenkins on an EC2 Instance**: Setting up Jenkins on an EC2 instance for continuous integration and continuous deployment (CI/CD) tasks.
3. **Automating PostgreSQL Backups**: Configuring Jenkins to perform regular backups of the PostgreSQL database using `pg_dump`.

### Goals

- Simplify infrastructure management with Infrastructure as Code (IaC).
- Ensure a reliable CI/CD pipeline using Jenkins.
- Automate database backup processes to ensure data integrity and availability.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) installed
- AWS account and credentials configured (`aws configure`)
- AWS IAM user with necessary permissions for EC2, RDS, and IAM
- Basic knowledge of Terraform and AWS services

## Project Structure

```
├── main.tf                  # Terraform configuration for AWS RDS instance
├── variables.tf             # Variable definitions
├── outputs.tf               # Output definitions
├── ec2_jenkins.tf           # Terraform configuration for AWS EC2 instance running Jenkins
├── jenkins_setup.sh         # Script to install and configure Jenkins on the EC2 instance
├── jenkins_backup_job.xml   # Jenkins job configuration for PostgreSQL backup
└── README.md                # Project documentation
```

## Getting Started

### Clone the Repository

```sh
git clone https://github.com/your-username/terraform-jenkins-rds.git
cd terraform-jenkins-rds
```

### Initialize Terraform

```sh
terraform init
```

### Apply the Terraform Configuration

```sh
terraform apply
```

When prompted, type `yes` to confirm and apply the changes.

### Configure Jenkins

1. **SSH into the Jenkins EC2 instance:**
    ```sh
    ssh -i your-key.pem ec2-user@your-ec2-instance-public-dns
    ```

2. **Run the Jenkins setup script:**
    ```sh
    sudo ./jenkins_setup.sh
    ```

3. **Access Jenkins through the web interface and complete the setup:**
    ```sh
    http://your-ec2-instance-public-dns:8080
    ```

4. **Configure the Jenkins job for PostgreSQL backups using the provided XML configuration (`jenkins_backup_job.xml`).**

## AWS Resources

This project will create the following AWS resources:

- An RDS PostgreSQL instance
- An EC2 instance running Jenkins
- Necessary IAM roles and policies

## Terraform Configuration

### `main.tf`

This file contains the configuration for the AWS RDS instance:

```hcl
provider "aws" {
  region = "us-west-2"
}

resource "aws_db_instance" "example" {
  allocated_storage    = 20
  engine               = "postgres"
  engine_version       = "12.4"
  instance_class       = "db.t3.micro"
  db_name              = "mydatabase"
  username             = "foo"
  password             = "barbazqux"
  parameter_group_name = "default.postgres12"
  skip_final_snapshot  = true
}

output "rds_endpoint" {
  value = aws_db_instance.example.endpoint
}
```

### `variables.tf`

This file contains the variable definitions:

```hcl
variable "aws_region" {
  default = "us-west-2"
}
```

### `outputs.tf`

This file defines the outputs:

```hcl
output "rds_endpoint" {
  value = aws_db_instance.example.endpoint
}
```

### `ec2_jenkins.tf`

This file contains the configuration for the AWS EC2 instance running Jenkins:

```hcl
resource "aws_instance" "jenkins" {
  ami           = "ami-0c55b159cbfafe1f0" # Amazon Linux 2 AMI
  instance_type = "t2.micro"
  key_name      = "your-key"

  tags = {
    Name = "JenkinsServer"
  }

  user_data = file("jenkins_setup.sh")
}
```

### `jenkins_setup.sh`

This script installs and configures Jenkins on the EC2 instance:

```sh
#!/bin/bash
sudo yum update -y
sudo yum install -y java-1.8.0-openjdk
wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo
rpm --import http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key
sudo yum install -y jenkins
sudo service jenkins start
```

### `jenkins_backup_job.xml`

This file contains the Jenkins job configuration for PostgreSQL backup:

```xml
<?xml version='1.1' encoding='UTF-8'?>
<project>
  <actions/>
  <description>Backup PostgreSQL database using pg_dump</description>
  <keepDependencies>false</keepDependencies>
  <properties/>
  <scm class="hudson.scm.NullSCM"/>
  <builders>
    <hudson.tasks.Shell>
      <command>pg_dump -h your-rds-endpoint -U foo -d mydatabase -F c -b -v -f /var/lib/jenkins/backup/mydatabase.backup</command>
    </hudson.tasks.Shell>
  </builders>
  <publishers/>
  <buildWrappers/>
</project>
```

## Usage

1. **Initialize and Apply Terraform Configuration:**
   ```sh
   terraform init
   terraform apply
   ```

2. **Set Up Jenkins:**
   - SSH into the EC2 instance and run the Jenkins setup script.
   - Access the Jenkins web interface and complete the setup.

3. **Configure Backup Job in Jenkins:**
   - Use the provided XML configuration to set up the PostgreSQL backup job in Jenkins.

## Clean Up

To clean up the resources created by this project, run:

```sh
terraform destroy
```

When prompted, type `yes` to confirm and destroy the resources.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [Terraform](https://www.terraform.io/)
- [AWS](https://aws.amazon.com/)
- [Jenkins](https://www.jenkins.io/)

---

Replace placeholders like `your-username`, `your-key.pem`, and `your-ec2-instance-public-dns` with actual values specific to your setup. This README provides a comprehensive guide to setting up and using your project.
