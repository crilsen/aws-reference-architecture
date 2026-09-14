output "account_structure" {
  description = "Logical account layout managed by this environment."
  value = {
    management = {
      account_id = data.aws_caller_identity.management.account_id
      role       = "management"
    }
    lab = {
      account_id = module.organization.lab_account_id
      role       = "member"
    }
    production = {
      account_id = module.organization.production_account_id
      role       = "member"
    }
  }
  sensitive = true
}

output "service_control_policy_ids" {
  description = "SCP identifiers attached to the workloads OU."
  value       = module.service_control_policies.policy_ids
}
