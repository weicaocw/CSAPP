locals {
  cluster_id = get_env("TF_VAR_cluster_id")
  gh_token = get_env("TF_VAR_pat")
  cluster_size = get_env("TF_VAR_fleet_size")
  github_endpoint = get_env("TF_VAR_github_endpoint")
  ami_id = get_env("TF_VAR_ami_id")
}

inputs = {
  cluster_id = local.cluster_id
  gh_token = local.gh_token
  cluster_size = local.cluster_size
  github_endpoint = local.github_endpoint
  ami_id = local.ami_id
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    bucket         = "matrixdb-ci-terraform-state"
    key            = "ci-runners/centos17/${local.cluster_id}/terraform.tfstate"
    region         = "cn-northwest-1"
    encrypt        = true
    dynamodb_table = "matrixdb-ci-terraform-state-lock"
  }
}
