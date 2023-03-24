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
      "sudo apt-get install -y shadowsocks-libev",
      "sudo systemctl stop shadowsocks-libev",
      "sudo systemctl disable shadowsocks-libev",
      "echo \"{\" > /tmp/local-config.json",
      "echo \"  \\\"server\\\":        \\\"13.233.241.109\\\",\" >> /tmp/local-config.json",
      "echo \"  \\\"server_port\\\":   7193,\" >> /tmp/local-config.json",
      "echo \"  \\\"local_address\\\": \\\"127.0.0.1\\\",\" >> /tmp/local-config.json",
      "echo \"  \\\"local_port\\\":    1080,\" >> /tmp/local-config.json",
      "echo \"  \\\"password\\\":      \\\"testmagi\\\",\" >> /tmp/local-config.json",
      "echo \"  \\\"timeout\\\":       300,\" >> /tmp/local-config.json",
      "echo \"  \\\"method\\\":        \\\"aes-256-cfb\\\",\" >> /tmp/local-config.json",
      "echo \"  \\\"fast_open\\\":     true,\" >> /tmp/local-config.json",
      "echo \"  \\\"wokers\\\":        3\" >> /tmp/local-config.json",
      "echo \"}\" >> /tmp/local-config.json",
      "sudo mv /tmp/local-config.json /etc/shadowsocks-libev/local-config.json",
      "sudo systemctl start shadowsocks-libev-local@local-config.service",
      "sudo systemctl enable shadowsocks-libev-local@local-config.service",
      "git config --global http.proxy 'socks5://127.0.0.1:1080'",
      "git config --global https.proxy 'socks5://127.0.0.1:1080'",
      "git config --global http.sslVerify false",
      "git config --global url.\"https://${var.github_config_pat}@github.com/ymatrix-data\".insteadOf \"https://github.com/ymatrix-data\"",
      "sudo git config --global http.proxy 'socks5://127.0.0.1:1080'",
      "sudo git config --global https.proxy 'socks5://127.0.0.1:1080'",
      "sudo git config --global http.sslVerify false",
      "sudo git config --global url.\"https://${var.github_config_pat}@github.com/ymatrix-data\".insteadOf \"https://github.com/ymatrix-data\"",
      "export AWS_ACCESS_KEY_ID=\"${var.aws_access_key_id}\"",
      "export AWS_SECRET_ACCESS_KEY=\"${var.aws_secret_access_key}\"",
      "export AWS_DEFAULT_REGION=\"cn-northwest-1\"",

      "echo Installing golang and components",
      "aws s3 cp s3://public-packer-artifacts/go1.19.6.linux-amd64.tar.gz /tmp/golang.tar.gz",
      "sudo tar -xzf /tmp/golang.tar.gz --directory /usr/local/",
      "sudo mkdir -p /usr/local/bin",
      "sudo ln -s /usr/local/go/bin/* /usr/local/bin/",
      "sudo rm -rf /tmp/go*",
      "go env -w GOPRIVATE=\"github.com/ymatrix-data\"",
      "go env -w GOPROXY=\"https://goproxy.cn,direct\"",
      "sudo go env -w GOPRIVATE=\"github.com/ymatrix-data\"",
      "sudo go env -w GOPROXY=\"https://goproxy.cn,direct\"",
      "sudo go install github.com/onsi/ginkgo/ginkgo@v1",
      "sudo cp /root/go/bin/ginkgo /usr/local/bin/",
      "sudo rm -rf /root/go",

      "echo Installing terraform and tools",
      "curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg",
      "sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg",
      "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main\" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null",
      "sudo apt update",
      "sudo apt install -y gh",
      "wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg",
      "echo \"deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main\" | sudo tee /etc/apt/sources.list.d/hashicorp.list > /dev/null",
      "sudo apt update",
      "sudo apt install terraform",
      "aws s3 cp s3://public-packer-artifacts/terragrunt_linux_amd64 /tmp/terragrunt_linux_amd64",
      "chmod a+x /tmp/terragrunt_linux_amd64",
      "sudo mv /tmp/terragrunt_linux_amd64 /usr/local/bin/terragrunt",
      "mkdir -p ~/.terraform.d/plugins/registry.terraform.io/hashicorp/aws/3.66.0/linux_amd64",
      "aws s3 cp s3://public-packer-artifacts/terraform-provider-aws_3.66.0_linux_amd64.zip /tmp/terraform-provider-aws_3.66.0_linux_amd64.zip",
      "unzip /tmp/terraform-provider-aws_3.66.0_linux_amd64.zip",
      "chmod a+x terraform-provider-aws*",
      "mv terraform-provider-aws* ~/.terraform.d/plugins/registry.terraform.io/hashicorp/aws/3.66.0/linux_amd64/",
      "rm /tmp/*.zip",
      "mkdir -p ~/.terraform.d/plugins/registry.terraform.io/hashicorp/tls/3.1.0/linux_amd64",
      "aws s3 cp s3://public-packer-artifacts/terraform-provider-tls_3.1.0_linux_amd64.zip /tmp/terraform-provider-tls_3.1.0_linux_amd64.zip",
      "unzip /tmp/terraform-provider-tls_3.1.0_linux_amd64.zip",
      "chmod a+x terraform-provider-tls*",
      "mv terraform-provider-tls* ~/.terraform.d/plugins/registry.terraform.io/hashicorp/tls/3.1.0/linux_amd64/",
      "rm /tmp/*.zip",
      "mkdir -p ~/.terraform.d/plugins/registry.terraform.io/hashicorp/template/2.2.0/linux_amd64",
      "aws s3 cp s3://public-packer-artifacts/terraform-provider-template_2.2.0_linux_amd64.zip /tmp/terraform-provider-template_2.2.0_linux_amd64.zip",
      "unzip /tmp/terraform-provider-template_2.2.0_linux_amd64.zip",
      "chmod a+x terraform-provider-template*",
      "mv terraform-provider-template* ~/.terraform.d/plugins/registry.terraform.io/hashicorp/template/2.2.0/linux_amd64/",
      "rm /tmp/*.zip",
      "mkdir -p ~/.terraform.d/plugins/registry.terraform.io/hashicorp/random/3.4.3/linux_amd64",
      "aws s3 cp s3://public-packer-artifacts/terraform-provider-random_3.4.3_linux_amd64.zip /tmp/terraform-provider-random_3.4.3_linux_amd64.zip",
      "unzip /tmp/terraform-provider-random_3.4.3_linux_amd64.zip",
      "chmod a+x terraform-provider-random*",
      "mv terraform-provider-random* ~/.terraform.d/plugins/registry.terraform.io/hashicorp/random/3.4.3/linux_amd64/",
      "rm /tmp/*.zip",

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
