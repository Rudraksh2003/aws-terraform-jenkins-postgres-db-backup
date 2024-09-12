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
run this 
```
chmod +x jenkins_setup.sh
sudo ./jenkins_setup.sh
```

### `jenkins_backup_job.xml`

This file contains the Jenkins job configuration for PostgreSQL backup by the help of free style:

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
or
```bash
#!/bin/bash

# Set PostgreSQL environment variables
export PGPASSWORD='barbazqux'

# Define backup directory and file
BACKUP_DIR="/var/lib/jenkins/backup"
BACKUP_FILE="$BACKUP_DIR/mydatabase.backup"

# Ensure the backup directory exists
sudo mkdir -p $BACKUP_DIR
sudo chown jenkins:jenkins $BACKUP_DIR

# Perform the database backup
pg_dump -h terraform-20240912164702173100000001.c72msiceshh4.us-east-1.rds.amazonaws.com \
        -U rudraksh \
        -d mydatabase \
        -F c -b -v -f $BACKUP_FILE

# Check the status of the backup command
if [ $? -ne 0 ]; then
  echo "Backup failed!"
  exit 1
else
  echo "Backup successful!"
  exit 0
fi
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



---
# **More Detail about the project and use cases**




**Objective:**
The primary objective of this project is to automate the backup process of a PostgreSQL database using Jenkins, a popular open-source automation server. This automation ensures that your database is regularly backed up, which is crucial for data recovery, disaster recovery, and maintaining business continuity.

**Components:**
1. **Jenkins**: An automation server used to build, deploy, and automate various tasks.
2. **PostgreSQL**: A powerful, open-source relational database system.
3. **Backup Script**: A shell script that uses `pg_dump` to create a backup of the PostgreSQL database.
4. **Jenkins Job**: A Jenkins Freestyle project that executes the backup script on a scheduled basis or upon manual trigger.

### **How It Works**

1. **Jenkins Setup**:
   - **Freestyle Job Configuration**: You configure a Jenkins Freestyle job to execute a shell script.
   - **Script Execution**: The shell script is executed as part of the Jenkins job. This script uses the `pg_dump` utility to create a backup of the PostgreSQL database.

2. **Shell Script Functionality**:
   - **Environment Variables**: Sets the PostgreSQL password to allow authentication without manual input.
   - **Directory Management**: Ensures the backup directory exists and has the correct permissions.
   - **Database Backup**: Uses `pg_dump` with specified options to create a backup file in a custom format, including large objects, and stores it in the backup directory.
   - **Status Reporting**: Checks the success or failure of the backup command and provides appropriate feedback.

### **Use Cases**

1. **Regular Backups**:
   - **Scheduled Backups**: Set up Jenkins to run the backup script on a schedule (e.g., daily, weekly) to ensure regular backups.
   - **Automated Backup Process**: Reduces the risk of human error and ensures that backups are consistently created.

2. **Disaster Recovery**:
   - **Data Recovery**: In case of data corruption or loss, use the backup files to restore the PostgreSQL database to a previous state.
   - **Business Continuity**: Minimizes downtime and data loss, helping to maintain business operations.

3. **Testing and Development**:
   - **Environment Duplication**: Use backups to create copies of the database for testing or development purposes, ensuring that tests are conducted on real-world data.

4. **Compliance and Reporting**:
   - **Data Retention Policies**: Maintain historical backups to comply with data retention policies or regulatory requirements.
   - **Backup Reporting**: Generate reports on the status of backups and recovery processes for audits and compliance reviews.

5. **Cost Management**:
   - **Cloud Storage Integration**: Extend the solution to integrate with cloud storage services (e.g., AWS S3) for cost-effective and scalable backup storage.
   - **Automated Cleanup**: Implement backup retention policies and automated cleanup to manage storage costs.

### **Effective Use**

1. **Configure Alerts**:
   - Set up notifications in Jenkins to alert administrators if a backup fails, ensuring quick resolution of any issues.

2. **Secure Backups**:
   - Ensure backup files are stored securely with appropriate permissions and encryption if necessary.

3. **Monitor Backup Jobs**:
   - Regularly review backup job logs and reports to ensure backups are completed successfully and to troubleshoot any issues.

4. **Test Restores**:
   - Periodically test restoring from backups to verify that the backup files are valid and can be used for recovery.

5. **Document Procedures**:
   - Maintain documentation of the backup process, including configurations, schedules, and restoration procedures, for reference and compliance.

By implementing this automated backup solution with Jenkins and PostgreSQL, you can streamline database management, improve data protection, and ensure that your data is reliably backed up and recoverable.
---
## License

This project is licensed under the   GNU GENERAL PUBLIC LICENSE- see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [Terraform](https://www.terraform.io/)
- [AWS](https://aws.amazon.com/)
- [Jenkins](https://www.jenkins.io/)

---

Replace placeholders like `your-username`, `your-key.pem`, and `your-ec2-instance-public-dns` with actual values specific to your setup. This README provides a comprehensive guide to setting up and using your project.

