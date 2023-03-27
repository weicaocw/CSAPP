resource "tls_private_key" "cluster_priv_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "cluster_key_pair" {
  key_name   = "${var.resource_prefix}-key-${var.cluster_id}"
  public_key = tls_private_key.cluster_priv_key.public_key_openssh
  depends_on = [tls_private_key.cluster_priv_key]
  tags = {
    TerraformEC2SpotClusterID = var.cluster_id
    GithubEndpoint            = var.github_endpoint
    FleetSize                 = var.cluster_size
  }
}

resource "aws_security_group" "fleet_sg" {
  name   = "${var.resource_prefix}-sg-${var.cluster_id}"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    TerraformEC2SpotClusterID = var.cluster_id
    GithubEndpoint            = var.github_endpoint
    FleetSize                 = var.cluster_size
  }
}

resource "aws_spot_fleet_request" "fleet_request" {
  fleet_type                  = "maintain"
  iam_fleet_role              = "arn:aws-cn:iam::121995761632:role/aws-service-role/spotfleet.amazonaws.com/AWSServiceRoleForEC2SpotFleet"
  target_capacity             = var.cluster_size
  instance_pools_to_use_count = 2
  // Temporary workaround from https://github.com/hashicorp/terraform-provider-aws/issues/10083
  terminate_instances_with_expiration = true
  tags = {
    TerraformEC2SpotClusterID = var.cluster_id
    GithubEndpoint            = var.github_endpoint
    FleetSize                 = var.cluster_size
  }

  dynamic "launch_specification" {
    for_each = var.launch_specifications
    content {
      instance_type          = var.instance_type
      ami                    = var.ami_id
      key_name               = aws_key_pair.cluster_key_pair.key_name
      subnet_id              = launch_specification.value.subnet_id
      vpc_security_group_ids = [aws_security_group.fleet_sg.id]

      root_block_device {
        volume_type           = var.root_volume_type
        volume_size           = var.root_volume_size
        delete_on_termination = true
      }

      user_data = <<-EOF
        #!/bin/bash
        sudo -i -u ${var.ami_default_user} bash <<EOS
        mkdir -p ~/.ssh
        echo "StrictHostKeyChecking no" >> ~/.ssh/config
        chmod 600 ~/.ssh/config

        mkdir ~/runner
        tar zxf actions-runner.tar.gz -C runner

        export GH_TOKEN=${var.gh_token}
        export TOKEN=\$(gh api --method POST \
          -H "Accept: application/vnd.github+json" \
          /repos/weicao92/CSAPP/actions/runners/registration-token | jq -r ".token")

        cd runner
        ./config.sh --url ${var.github_endpoint} \
          --token \$TOKEN \
          --disableupdate \
          --unattended > ~/config.log 2>&1
        nohup ./run.sh > ~/runner.log 2>&1
        EOS
      EOF

      tags = {
        TerraformEC2SpotClusterID = var.cluster_id
        GithubEndpoint            = var.github_endpoint
        FleetSize                 = var.cluster_size
      }
    }
  }
}
