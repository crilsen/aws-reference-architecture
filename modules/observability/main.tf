resource "aws_cloudwatch_log_group" "workloads" {
  name              = "/${var.project_name}/${var.cluster_name}/workloads"
  retention_in_days = 14
}
