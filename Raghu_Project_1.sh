#!/bin/bash

# === CONFIG SECTION ===
WORKDIR="terraform_ec2_project"
TF_FILE="main.tf"
AWS_REGION="us-east-1"
AMI_ID="ami-0c02fb55956c7d316"  # Amazon Linux 2 AMI
INSTANCE_TYPE="t2.micro"
KEY_NAME="your-aws-keypair"    # Replace with your AWS key pair
INSTANCE_TAG="AI-Driven-EC2"

# === STEP 1: Install Terraform if not present ===
if ! command -v terraform &> /dev/null; then
  echo "🚀 Installing Terraform..."
  sudo apt update && sudo apt install -y wget unzip
  wget https://releases.hashicorp.com/terraform/1.8.4/terraform_1.8.4_linux_amd64.zip
  unzip terraform_1.8.4_linux_amd64.zip
  sudo mv terraform /usr/local/bin/
  rm terraform_1.8.4_linux_amd64.zip
fi

# === STEP 2: Create Terraform Configuration ===
mkdir -p $WORKDIR && cd $WORKDIR
cat <<EOF > $TF_FILE
provider "aws" {
  region = "$AWS_REGION"
}

resource "aws_instance" "ec2_demo" {
  ami           = "$AMI_ID"
  instance_type = "$INSTANCE_TYPE"
  key_name      = "$KEY_NAME"

  tags = {
    Name = "$INSTANCE_TAG"
  }
}
EOF

# === STEP 3: Terraform Lifecycle ===
terraform init
terraform validate

echo "🛠️  Creating EC2 instance..."
terraform apply -auto-approve

echo "📡 Verifying instance..."
terraform show | grep public_ip

# === Cleanup Option ===
read -p "Do you want to destroy the infrastructure after testing? (y/n): " RESP
if [[ "$RESP" == "y" ]]; then
  echo "🔥 Destroying resources..."
  terraform destroy -auto-approve
else
  echo "✅ Resources left active. You can destroy them later with: terraform destroy -auto-approve"
fi
