variable "project_name" { type = string }
variable "aws_region" { type = string }
variable "subnet_id" { type = string }
variable "cluster_security_group_id" { type = string }
variable "github_repository_url" { type = string }
variable "registration_token_parameter_name" { type = string }
variable "instance_type" {
  type    = string
  default = "t3.small"
}
variable "runner_version" {
  type    = string
  default = "2.331.0"
}
variable "tags" {
  type    = map(string)
  default = {}
}
