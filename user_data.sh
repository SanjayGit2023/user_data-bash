#!/bin/bash
set -e

# Update package index
sudo apt update -y

# Install necessary packages
sudo apt install -y unzip curl gnupg apt-transport-https

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Clean up installation files
rm -rf awscliv2.zip aws/

# Verify AWS CLI installation
if ! aws --version; then
  echo "AWS CLI installation failed"
  exit 1
fi

# Configure AWS CLI with access keys
aws configure set aws_access_key_id "YOUR_ACCESS_KEY" 
aws configure set aws_secret_access_key "YOUR-SECRET_ACCESS_KEY" 
aws configure set default.region "ap-south-1"
aws configure set default.output "json"

# Verify AWS CLI configuration
if ! aws sts get-caller-identity; then
  echo "AWS CLI configuration failed"
  exit 1
fi

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

# Verify kubectl installation
if ! kubectl version --client; then
  echo "kubectl installation failed"
  exit 1
fi

# Install eksctl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin/
sudo chmod +x /usr/local/bin/eksctl

# Verify eksctl installation
if ! eksctl version; then
  echo "eksctl installation failed"
  exit 1
fi

# Create EKS cluster (2 nodes)
eksctl create cluster --name my-cluster --region ap-south-1 --nodes 2

# Update kubeconfig to use the new cluster
aws eks update-kubeconfig --name my-cluster --region ap-south-1
