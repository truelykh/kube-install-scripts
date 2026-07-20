#!/usr/bin/env bash
set -euo pipefail

# Update package index
sudo apt-get update -y

# Install Java (Jenkins requires Java 17 or 21)
sudo apt-get install -y openjdk-17-jre

# Add Jenkins repository GPG key
sudo mkdir -p /usr/share/keyrings
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null

# Add Jenkins repository to system sources
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/" | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

# Update package index again with Jenkins repo
sudo apt-get update -y

# Install Jenkins
sudo apt-get install -y jenkins

# Start and enable Jenkins service
sudo systemctl enable --now jenkins

echo "Jenkins installation complete. Access it on port 8080."
echo "Initial admin password is located at: /var/lib/jenkins/secrets/initialAdminPassword"
