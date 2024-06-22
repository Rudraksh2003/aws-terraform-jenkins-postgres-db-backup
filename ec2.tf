resource "aws_instance" "jenkins" {
  ami           = "ami-0dc2d3e4c0f9ebd18" # Amazon Linux 2 AMI
  instance_type = "t2.micro"

  key_name = "your-key-pair" # Ensure you have a key pair created in AWS

  tags = {
    Name = "JenkinsServer"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo amazon-linux-extras install java-openjdk11 -y",
      "wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat/jenkins.repo",
      "rpm --import https://pkg.jenkins.io/redhat/jenkins.io.key",
      "sudo yum install jenkins -y",
      "sudo systemctl start jenkins",
      "sudo systemctl enable jenkins"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("path/to/your-key-pair.pem")
      host        = aws_instance.jenkins.public_ip
    }
  }
}

output "jenkins_public_ip" {
  value = aws_instance.jenkins.public_ip
}
