output "policy_ids" {
  value = { for key, policy in aws_organizations_policy.this : key => policy.id }
}
