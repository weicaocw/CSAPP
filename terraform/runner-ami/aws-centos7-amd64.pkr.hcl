packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "runner" {
  ami_name      = "matrixdb-pr-runner-centos7-amd64-${var.ami_version}"
  instance_type = "t3a.small"
  region        = "cn-northwest-1"
  source_ami_filter {
    filters = {
      name                = "CentOS7.9-"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["336777782633"]
  }
  ssh_username = "ec2-user"
}

build {
  name    = "matrixdb-pr-runner-centos7"
  sources = [
    "source.amazon-ebs.runner"
  ]
  provisioner "shell" {
    inline = [
      "echo Installing required components",
      "sudo yum makecache",
      "sudo rpm --import http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-7 && yum -y install epel-release && yum -y install unzip autoconf autoconf-archive bison cmake3 flex libtool make which patchelf systemd-rpm-macros",
      "sudo yum -y install apr-devel bzip2-devel expat-devel libcurl-devel libevent-devel libuuid-devel libxml2-devel libyaml-devel libzstd-devel openldap-devel openssl-devel pam-devel readline-devel snappy-devel libicu perl-ExtUtils-Embed perl-Env perl-JSON ",
      "sudo yum -y install xxhash-devel",
      "sudo yum install -y http://opensource.wandisco.com/centos/7/git/x86_64/wandisco-git-release-7-2.noarch.rpm && yum install -y git",
      "sudo yum -y install lz4-devel mysql-devel python3-devel python3-pip",
      "sudo yum -y install postgresql-devel",
      "sudo yum -y install rpmdevtools",
      "sudo yum -y install openssh-server net-tools",
      "CENTOS_VERSION=$(cut -d: -f5 /etc/system-release-cpe | cut -d. -f1) && sudo yum -y install https://apache.jfrog.io/artifactory/arrow/centos/${CENTOS_VERSION}/apache-arrow-release-latest.rpm && yum -y install arrow-glib-devel-3.0.0 parquet-devel-3.0.0 gcc gcc-c++",
      "sudo pip3 --no-cache-dir install pysocks && pip3 --no-cache-dir install argparse psutil pygresql pyyaml",
      "sudo yum -y install centos-release-scl centos-release-scl-rh && yum -y install --nogpgcheck devtoolset-11-gcc devtoolset-11-gcc-c++ && pip3 --no-cache-dir install psi && ln -s /usr/bin/cmake3 /usr/bin/cmake && echo -e 'source /opt/rh/devtoolset-11/enable' >> /opt/gcc_env.sh && echo -e 'source /opt/gcc_env.sh' >> /root/.bashrc",
      "sudo yum -y install docker-compose",
      "sudo yum -y install rh-postgresql12-postgresql-devel",
      "sudo yum -y install rust cargo rust-std-static",
      "sudo yum -y install --nogpgcheck llvm-toolset-7.0-clang && echo -e 'source /opt/rh/llvm-toolset-7.0/enable' >> /opt/clang_env.sh && echo -e 'source /opt/clang_env.sh' >> /root/.bashrc",
      "sudo yum clean all",
      "LIBUV_VERSION=1.39.0 && sudo mkdir -p /tmp/build-libuv && cd /tmp/build-libuv && curl -# --location     --output libuv-${LIBUV_VERSION}.tar.gz     https://github.com/libuv/libuv/archive/v${LIBUV_VERSION}.tar.gz && tar xf libuv-${LIBUV_VERSION}.tar.gz && cd libuv-${LIBUV_VERSION} && cmake -B build -D CMAKE_BUILD_TYPE=Release && make -C build -j4 install && rm -rf /tmp/build-libuv",
      "UVW_VERSION=2.7.0_libuv_v1.39 && sudo mkdir -p /tmp/build-uvw && cd /tmp/build-uvw && curl -# --location     --output uvw-${UVW_VERSION}.tar.gz     https://github.com/skypjack/uvw/archive/refs/tags/v${UVW_VERSION}.tar.gz && tar xf uvw-${UVW_VERSION}.tar.gz && cd uvw-${UVW_VERSION} && cmake -B build && make -C build install && rm -rf /tmp/build-uvw",
      "sudo curl -# --location --output /usr/include/libdivide.h https://raw.githubusercontent.com/ridiculousfish/libdivide/master/libdivide.h",
      "sudo curl -# --location --output /usr/include/pdqsort.h https://raw.githubusercontent.com/orlp/pdqsort/master/pdqsort.h",
      "XERCES_C_VERSION=3.1.2 && sudo echo \"743bd0a029bf8de56a587c270d97031e0099fe2b7142cef03e0da16e282655a0  xerces-c-3.1.2.tar.gz\" > /tmp/xerces-c-${XERCES_C_VERSION}.tar.gz.sha256",
      "XERCES_C_VERSION=3.1.2 &&  sudo mkdir -p /tmp/build-xerces-c && cd /tmp/build-xerces-c && curl -# --location     --output xerces-c-${XERCES_C_VERSION}.tar.gz     http://archive.apache.org/dist/xerces/c/3/sources/xerces-c-${XERCES_C_VERSION}.tar.gz && cp /tmp/xerces-c-${XERCES_C_VERSION}.tar.gz.sha256 . && sha256sum -c xerces-c-${XERCES_C_VERSION}.tar.gz.sha256 && tar xf xerces-c-${XERCES_C_VERSION}.tar.gz && cd xerces-c-${XERCES_C_VERSION} && ./configure && make -j4 && make install && rm -rf /tmp/build-xerces-c",
      "XERCES_C_VERSION=3.1.2 &&  sudo rm -f /tmp/xerces-c-${XERCES_C_VERSION}.tar.gz.sha256",
      "sudo ssh-keygen -A",
      "sudo exec /usr/sbin/sshd -D -e \"$@\" &",

      "sudo yum install -y upx-ucl awscli jq s3cmd",
      "git config --global url.\"https://${var.github_config_pat}@github.com/ymatrix-data\".insteadOf \"https://github.com/ymatrix-data\"",
      "sudo git config --global url.\"https://${var.github_config_pat}@github.com/ymatrix-data\".insteadOf \"https://github.com/ymatrix-data\"",
      "export AWS_ACCESS_KEY_ID=\"${var.aws_access_key_id}\"",
      "export AWS_SECRET_ACCESS_KEY=\"${var.aws_secret_access_key}\"",
      "export AWS_DEFAULT_REGION=\"cn-northwest-1\"",

      "echo Prepare for dev",
      "sudo yum-config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo",
      "sudo yum install -y gh",
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
