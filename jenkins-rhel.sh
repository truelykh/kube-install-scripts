#!/usr/bin/env bash
set -euo pipefail

# Download the Jenkins repository configuration
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo

# Import the repository GPG key
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

# Install Java (Jenkins requires Java 17 or 21)
sudo yum install -y java-17-openjdk

# Install Jenkins
sudo yum install -y jenkins

# Start and enable Jenkins service
sudo systemctl daemon-reload
sudo systemctl enable --now jenkins

echo "Jenkins installation complete. Access it on port 8080."
echo "Initial admin password is located at: /var/lib/jenkins/secrets/initialAdminPassword"
