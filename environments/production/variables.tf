variable "aws_region" {
  type    = string
  default = "us-east-1"
  validation {
    condition     = var.aws_region == "us-east-1"
    error_message = "This reference architecture supports only us-east-1."
  }
}

variable "target_account_id" {
  description = "Expected AWS account ID for the Production member account."
  type        = string
  sensitive   = true
  validation {
    condition     = can(regex("^[0-9]{12}$", var.target_account_id))
    error_message = "target_account_id must contain exactly 12 digits."
  }
}

variable "deployment_role_name" {
  type    = string
  default = "OrganizationAccountAccessRole"
}
variable "project_name" { type = string }
variable "kubernetes_version" { type = string }
variable "vpc_cidr" { type = string }
variable "node_instance_types" { type = list(string) }
