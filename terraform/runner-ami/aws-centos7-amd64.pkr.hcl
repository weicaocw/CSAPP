packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "runner" {
  ami_name      = "matrixdb-pr-runner-amd64-${var.ami_version}"
  instance_type = "t3a.small"
  region        = "cn-northwest-1"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["837727238323"]
  }
  ssh_username = "ubuntu"
}

build {
  name    = "matrixdb-pr-runner"
  sources = [
    "source.amazon-ebs.runner"
  ]
  provisioner "shell" {
    inline = [
      "echo Installing required components",
      "sudo apt update",
      "sudo apt-get update",
      "sudo apt-get install -y gcc upx-ucl unzip python3-pip awscli jq make s3cmd",

      "git config --global url.\"https://${var.github_config_pat}@github.com/ymatrix-data\".insteadOf \"https://github.com/ymatrix-data\"",
      "sudo git config --global url.\"https://${var.github_config_pat}@github.com/ymatrix-data\".insteadOf \"https://github.com/ymatrix-data\"",
      "export AWS_ACCESS_KEY_ID=\"${var.aws_access_key_id}\"",
      "export AWS_SECRET_ACCESS_KEY=\"${var.aws_secret_access_key}\"",
      "export AWS_DEFAULT_REGION=\"cn-northwest-1\"",

     


      "echo Prepare for dev",
      "aws s3 cp s3://public-packer-artifacts/actions-runner-linux-x64-2.302.1.tar.gz ~/actions-runner-linux-x64-2.302.1.tar.gz",
      "ln -s ~/actions-runner-linux-x64-2.302.1.tar.gz ~/actions-runner.tar.gz",
    ]
  }
}

variable "github_config_pat" {
  // export PKR_VAR_github_config_pat=...
  type    = string
}

variable "aws_access_key_id" {
  // export PKR_VAR_aws_access_key_id=...
  type    = string
}

variable "aws_secret_access_key" {
  // export PKR_VAR_aws_secret_access_key=...
  type    = string
}

variable "ami_version" {
  // export PKR_VAR_ami_version=...
  type    = string
}
