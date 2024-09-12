#!/bin/bash

# Update the instance
sudo apt update -y

# Install Java (Jenkins requires Java)
sudo apt install -y openjdk-11-jdk

# Add Jenkins repository
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key

echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
/etc/apt/sources.list.d/jenkins.list > /dev/null

# Update package index and install Jenkins
sudo apt update -y
sudo apt install -y jenkins

# Start Jenkins service
sudo systemctl start jenkins

# Enable Jenkins service to start on boot
sudo systemctl enable jenkins

# Open the necessary port (8080 by default for Jenkins)
sudo ufw allow 8080

# Print initial Jenkins admin password
echo "Jenkins initial admin password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword

echo "Jenkins has been installed and configured. You can access it via http://<instance-public-ip>:8080"
