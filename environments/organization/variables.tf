variable "aws_region" {
  description = "AWS region used for Organizations API requests."
  type        = string
  default     = "us-east-1"

  validation {
    condition     = var.aws_region == "us-east-1"
    error_message = "This lab supports only us-east-1."
  }
}

variable "management_account_id" {
  description = "Expected AWS account ID for the Organizations management account."
  type        = string
  sensitive   = true

  validation {
    condition     = can(regex("^[0-9]{12}$", var.management_account_id))
    error_message = "management_account_id must contain exactly 12 digits."
  }
}

variable "organization_name" {
  description = "Generic label used for organizational resources."
  type        = string
}

variable "lab_account_email" {
  description = "Unique email address for the lab member account."
  type        = string
  sensitive   = true
}

variable "production_account_email" {
  description = "Unique email address for the production member account."
  type        = string
  sensitive   = true
}

variable "account_access_role_name" {
  description = "Role created in member accounts for management-account access."
  type        = string
  default     = "OrganizationAccountAccessRole"
}
