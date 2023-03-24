terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.66.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "3.1.0"
    }
  }
}

provider "aws" {
  region = "cn-northwest-1"
}

module "ec2_spot_cluster" {
  source = "../aws"

  cluster_id       = var.cluster_id
  gh_token         = var.gh_token
  github_endpoint  = var.github_endpoint
  ami_id           = var.ami_id // ci-soa-github-runner
  ami_default_user = "ubuntu"
  instance_type    = "t3a.small"
  cluster_size     = var.cluster_size
}
