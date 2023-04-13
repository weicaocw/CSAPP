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

variable "ami_id" {
  type = string
}
