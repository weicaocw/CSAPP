packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "runner" {
  ami_name      = "matrixdb-pr-runner-ubuntu-amd64-${var.ami_version}"
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
  name    = "matrixdb-pr-runner-ubuntu"
  sources = [
    "source.amazon-ebs.runner"
  ]
  provisioner "shell" {
    inline = [
      "echo Installing required components",
      "sudo apt-get update",
      "sudo apt-get install -y software-properties-common",
      "sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test",
      "sudo DEBIAN_FRONTEND=noninteractive apt-get install -y bison ccache cmake curl flex git git-core gcc-11 g++-11 inetutils-ping krb5-kdc krb5-admin-server libapr1-dev libbz2-dev libcurl4-gnutls-dev libevent-dev libkrb5-dev libpam-dev libperl-dev libreadline-dev libssl-dev libxerces-c-dev libxml2-dev libyaml-dev libzstd-dev locales net-tools ninja-build openssh-client openssh-server openssl python3-dev python3-pip python3-psutil python3-pygresql python3-setuptools python3-yaml zlib1g-dev zip unzip",
      "sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 100 --slave /usr/bin/g++ g++ /usr/bin/g++-11 --slave /usr/bin/gcov gcov /usr/bin/gcov-11",
      "sudo update-alternatives --config gcc",
      "sudo apt-get install -y libldap2-dev libuv1-dev liblz4-dev",
      "sudo apt-get install -y libxxhash-dev",
      "sudo apt-get install -y rsync",
      "sudo apt-get install -y lsof",
      "sudo apt-get install -y iproute2",
      "sudo apt-get install -y locales && locale-gen \"en_US.UTF-8\" && update-locale LC_ALL=\"en_US.UTF-8\"",
      "sudo apt-get install -y libmysqlclient-dev libjson-c-dev pkg-config autoconf automake autoconf-archive libtool patchelf",
      "sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 50",
      "sudo apt-get install -y coreutils",
      "sudo service ssh restart",

      "sudo apt-get install -y upx-ucl awscli jq make s3cmd",
      "git config --global url.\"https://${var.github_config_pat}@github.com/ymatrix-data\".insteadOf \"https://github.com/ymatrix-data\"",
      "sudo git config --global url.\"https://${var.github_config_pat}@github.com/ymatrix-data\".insteadOf \"https://github.com/ymatrix-data\"",
      "export AWS_ACCESS_KEY_ID=\"${var.aws_access_key_id}\"",
      "export AWS_SECRET_ACCESS_KEY=\"${var.aws_secret_access_key}\"",
      "export AWS_DEFAULT_REGION=\"cn-northwest-1\"",


      "echo Prepare for dev",
      "sudo apt-get install -y gh"
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
