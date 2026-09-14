provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = var.organization_name
      ManagedBy = "Terraform"
      Purpose   = "Learning"
    }
  }
}

data "aws_caller_identity" "management" {}

check "management_account_boundary" {
  assert {
    condition     = data.aws_caller_identity.management.account_id == var.management_account_id
    error_message = "Refusing to manage AWS Organizations from a credential outside the expected management account."
  }
}

module "organization" {
  source = "../../modules/organizations"

  organization_name         = var.organization_name
  lab_account_email         = var.lab_account_email
  production_account_email  = var.production_account_email
  account_access_role_name  = var.account_access_role_name
}

module "service_control_policies" {
  source = "../../modules/scp"

  target_id = module.organization.workloads_organizational_unit_id
}
