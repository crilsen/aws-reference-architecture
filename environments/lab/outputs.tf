output "deployment_account_id" {
  description = "Verified AWS account receiving the Lab deployment."
  value       = data.aws_caller_identity.deployment.account_id
  sensitive   = true
}

output "cluster_name" { value = module.cluster.cluster_name }
output "cluster_endpoint" {
  value     = module.cluster.cluster_endpoint
  sensitive = true
}
output "repository_url" { value = module.registry.repository_url }
output "configure_kubectl" {
  value = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.cluster.cluster_name}"
}
