variable "organization_name" {
  type = string
}

variable "lab_account_email" {
  type      = string
  sensitive = true
}

variable "production_account_email" {
  type      = string
  sensitive = true
}

variable "account_access_role_name" {
  type = string
}
