output "deployment_account_id" {
  value     = data.aws_caller_identity.deployment.account_id
  sensitive = true
}
output "cluster_name" { value = module.cluster.cluster_name }
output "cluster_endpoint" {
  value     = module.cluster.cluster_endpoint
  sensitive = true
}
output "repository_url" { value = module.registry.repository_url }
