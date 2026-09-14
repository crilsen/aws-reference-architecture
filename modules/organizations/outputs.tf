output "organization_id" {
  value = aws_organizations_organization.this.id
}

output "workloads_organizational_unit_id" {
  value = aws_organizations_organizational_unit.workloads.id
}

output "lab_account_id" {
  value = aws_organizations_account.lab.id
}

output "production_account_id" {
  value = aws_organizations_account.production.id
}
