variable "aws_region" {
  description = "AWS region used by the lab."
  type        = string
  default     = "us-east-1"
  validation {
    condition     = var.aws_region == "us-east-1"
    error_message = "This lab supports only us-east-1."
  }
}

variable "target_account_id" {
  description = "Expected AWS account ID for the Lab member account."
  type        = string
  sensitive   = true

  validation {
    condition     = can(regex("^[0-9]{12}$", var.target_account_id))
    error_message = "target_account_id must contain exactly 12 digits."
  }
}

variable "deployment_role_name" {
  description = "IAM role assumed by Terraform in the Lab account."
  type        = string
  default     = "OrganizationAccountAccessRole"
}

variable "project_name" {
  description = "Generic prefix applied to lab resources."
  type        = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,30}$", var.project_name))
    error_message = "Use 3-31 lowercase letters, numbers, or hyphens, starting with a letter."
  }
}

variable "kubernetes_version" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "node_instance_types" {
  type = list(string)
}

variable "single_nat_gateway" {
  description = "Use one NAT Gateway for the Lab to reduce cost."
  type        = bool
  default     = true
}

variable "nat_eip_allocation_id" {
  description = "Existing Elastic IP allocation ID reserved for the Lab NAT Gateway."
  type        = string
  default     = null
}

variable "endpoint_public_access" {
  description = "Expose the EKS API publicly. Keep false unless trusted CIDRs are supplied."
  type        = bool
  default     = false
}

variable "public_access_cidrs" {
  description = "Trusted CIDRs allowed to use the public EKS API endpoint."
  type        = list(string)
  default     = []
}

variable "node_desired_size" {
  description = "Initial desired node count for the Lab managed node group."
  type        = number
  default     = 0
}

variable "node_min_size" {
  description = "Minimum node count for the Lab managed node group."
  type        = number
  default     = 0
}

variable "node_max_size" {
  description = "Maximum node count for the Lab managed node group."
  type        = number
  default     = 1
}

variable "github_repository_url" {
  description = "GitHub repository that owns the self-hosted runner."
  type        = string
}

variable "github_runner_registration_token_parameter_name" {
  description = "Secure SSM parameter containing a time-limited GitHub runner registration token."
  type        = string
}
