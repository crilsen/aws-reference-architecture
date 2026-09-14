resource "aws_organizations_organization" "this" {
  feature_set          = "ALL"
  enabled_policy_types = ["SERVICE_CONTROL_POLICY"]
}

resource "aws_organizations_organizational_unit" "workloads" {
  name      = "Workloads"
  parent_id = aws_organizations_organization.this.roots[0].id

  tags = {
    Name = "${var.organization_name}-workloads"
  }
}

resource "aws_organizations_account" "lab" {
  name      = "Lab"
  email     = var.lab_account_email
  parent_id = aws_organizations_organizational_unit.workloads.id
  role_name = var.account_access_role_name

  close_on_deletion = false

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_organizations_account" "production" {
  name      = "Production"
  email     = var.production_account_email
  parent_id = aws_organizations_organizational_unit.workloads.id
  role_name = var.account_access_role_name

  close_on_deletion = false

  lifecycle {
    prevent_destroy = true
  }
}
