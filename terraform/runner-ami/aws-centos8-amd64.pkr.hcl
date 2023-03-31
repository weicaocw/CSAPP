packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "runner" {
  ami_name      = "matrixdb-pr-runner-centos8-amd64-${var.ami_version}"
  instance_type = "t3a.small"
  region        = "cn-northwest-1"
  source_ami_filter {
    filters = {
      name                = "	CentOS-8.5*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["121995761632"]
  }
  ssh_username = "centos"
}

build {
  name    = "matrixdb-pr-runner-centos8"
  sources = [
    "source.amazon-ebs.runner"
  ]
  provisioner "shell" {
    inline = [
      "echo Installing required components",
      "sudo dnf -y --disablerepo '*' --enablerepo=extras swap centos-linux-repos centos-stream-repos && sudo dnf -y distro-sync && sudo dnf -y install epel-release && sudo dnf -y install 'dnf-command(config-manager)' && sudo dnf config-manager --set-enabled powertools && sudo dnf config-manager --set-enabled epel && sudo dnf -y update",
      "sudo dnf -y install unzip autoconf autoconf-archive bison cmake3 flex libtool make which patchelf git rsync bc",
      "sudo dnf -y install apr-devel bzip2-devel expat-devel libcurl-devel libevent-devel libuuid-devel libxml2-devel libyaml-devel libzstd-devel openldap-devel openssl-devel pam-devel readline-devel snappy-devel libicu perl-ExtUtils-Embed perl-Env perl-JSON",
      "sudo dnf -y install xxhash-devel",
      "sudo dnf -y install lz4-devel mysql-devel python3-devel python3-pip",
      "sudo dnf -y install postgresql-devel",
      "sudo dnf -y install rpmdevtools",
      "sudo dnf -y install openssh-server net-tools",
      // "sudo dnf -y install  https://apache.jfrog.io/artifactory/arrow/centos/$(cut -d: -f5 /etc/system-release-cpe | cut -d. -f1)-stream/apache-arrow-release-latest.rpm https://apache.jfrog.io/artifactory/arrow/centos/8/x86_64/Packages/arrow-glib-devel-3.0.0-1.el8.x86_64.rpm https://apache.jfrog.io/artifactory/arrow/centos/8/x86_64/Packages/arrow-devel-3.0.0-1.el8.x86_64.rpm https://apache.jfrog.io/artifactory/arrow/centos/8/x86_64/Packages/arrow-libs-3.0.0-1.el8.x86_64.rpm https://apache.jfrog.io/artifactory/arrow/centos/8/x86_64/Packages/arrow-glib-libs-3.0.0-1.el8.x86_64.rpm https://apache.jfrog.io/artifactory/arrow/centos/8/x86_64/Packages/parquet-libs-3.0.0-1.el8.x86_64.rpm https://apache.jfrog.io/artifactory/arrow/centos/8/x86_64/Packages/parquet-glib-libs-3.0.0-1.el8.x86_64.rpm https://apache.jfrog.io/artifactory/arrow/centos/8/x86_64/Packages/parquet-devel-3.0.0-1.el8.x86_64.rpm https://apache.jfrog.io/artifactory/arrow/centos/8/x86_64/Packages/parquet-glib-devel-3.0.0-1.el8.x86_64.rpm gcc-c++",
      // "sudo pip3 --no-cache-dir install pysocks && sudo pip3 --no-cache-dir install argparse psutil pygresql pyyaml",
      "sudo touch /opt/gcc_env.sh",
      "sudo curl -L \"https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)\" -o /usr/local/bin/docker-compose && sudo chmod +x /usr/local/bin/docker-compose",
      "sudo dnf -y remove libpq && sudo dnf -y install https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm && sudo dnf -qy module disable postgresql && sudo dnf -y install postgresql12-devel",
      "sudo mkdir -p /tmp/build-libuv && sudo cd /tmp/build-libuv && sudo curl -# --location --output libuv-1.39.0.tar.gz https://github.com/libuv/libuv/archive/v1.39.0.tar.gz && sudo tar xf libuv-1.39.0.tar.gz && sudo cd libuv-1.39.0 && sudo cmake -B build -D CMAKE_BUILD_TYPE=Release && sudo make -C build -j4 install && sudo rm -rf /tmp/build-libuv",
      "sudo mkdir -p /tmp/build-uvw && sudo cd /tmp/build-uvw && sudo curl -# --location --output uvw-2.7.0_libuv_v1.39.tar.gz https://github.com/skypjack/uvw/archive/refs/tags/v2.7.0_libuv_v1.39.tar.gz && sudo tar xf uvw-2.7.0_libuv_v1.39.tar.gz && sudo cd uvw-2.7.0_libuv_v1.39 && sudo cmake -B build && sudo make -C build install && sudo rm -rf /tmp/build-uvw",
      "sudo curl -# --location --output /usr/include/libdivide.h https://raw.githubusercontent.com/ridiculousfish/libdivide/master/libdivide.h",
      "sudo curl -# --location --output /usr/include/pdqsort.h https://raw.githubusercontent.com/orlp/pdqsort/master/pdqsort.h",
      "sudo echo \"743bd0a029bf8de56a587c270d97031e0099fe2b7142cef03e0da16e282655a0  xerces-c-3.1.2.tar.gz\" > /tmp/xerces-c-3.1.2.tar.gz.sha256",
      "sudo mkdir -p /tmp/build-xerces-c && sudo cd /tmp/build-xerces-c && sudo curl -# --location --output xerces-c-3.1.2.tar.gz http://archive.apache.org/dist/xerces/c/3/sources/xerces-c-3.1.2.tar.gz && sudo cp /tmp/xerces-c-3.1.2.tar.gz.sha256 . && sudo sha256sum -c xerces-c-3.1.2.tar.gz.sha256 && sudo tar xf xerces-c-3.1.2.tar.gz && sudo cd xerces-c-3.1.2 && sudo ./configure && sudo make -j4 && sudo make install && sudo cp /usr/local/lib/libxerces-c* /lib64 && sudo cd /lib64 && sudo ln -sf libxerces-c-3.1.so libxerces-c.so && sudo ldconfig && sudo cd /tmp/build-xerces-c && sudo rm -rf /tmp/build-xerces-c",
      "sudo rm -f /tmp/xerces-c-3.1.2.tar.gz.sha256",

      "sudo apt-get install -y gcc upx-ucl unzip python3-pip awscli jq make s3cmd",
      "git config --global url.\"https://${var.github_config_pat}@github.com/ymatrix-data\".insteadOf \"https://github.com/ymatrix-data\"",
      "sudo git config --global url.\"https://${var.github_config_pat}@github.com/ymatrix-data\".insteadOf \"https://github.com/ymatrix-data\"",
      "export AWS_ACCESS_KEY_ID=\"${var.aws_access_key_id}\"",
      "export AWS_SECRET_ACCESS_KEY=\"${var.aws_secret_access_key}\"",
      "export AWS_DEFAULT_REGION=\"cn-northwest-1\"",

      "echo Prepare for dev",
      "sudo dnf install 'dnf-command(config-manager)'",
      "sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo",
      "sudo dnf install -y gh",
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
