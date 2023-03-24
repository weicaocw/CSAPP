variable "resource_prefix" {
  type    = string
  default = "ci-runner"
  validation {
    condition     = can(regex("^[0-9a-z][0-9a-z-]+[0-9a-z]$", var.resource_prefix))
    error_message = "The resource prefix should be at least 3 characters long and uses [0-9a-z] and dash only, and not start or end with a dash."
  }
}

variable "ami_id" {
  type    = string
  default = "ami-04422ce5081d0f609" // ci-soa-github-runner
}

variable "ami_default_user" {
  type    = string
  default = "ubuntu"
}

variable "instance_type" {
  type    = string
  default = "t3a.small"
}

variable "root_volume_type" {
  type    = string
  default = "gp3"
}

variable "root_volume_size" {
  type    = number
  default = 10
}

variable "cluster_id" {
  type = string
}

variable "gh_token" {
  type = string
}

variable "github_endpoint" {
  type = string
}

variable "cluster_size" {
  type    = number
  default = 18
}

variable "vpc_id" {
  type    = string
  default = "vpc-08f6b222b4d81ac77"
}

variable "launch_specifications" {
  type = set(
    object({
      subnet_id = string,
    })
  )
  default = [
    {
      subnet_id = "subnet-0d388dc3dea007639"
    },
    {
      subnet_id = "subnet-07704d06629827e0e"
    },
    {
      subnet_id = "subnet-0fce74b2b26c9ae2b"
    },
  ]
}
