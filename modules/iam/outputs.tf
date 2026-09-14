output "cluster_role_arn" {
  value      = aws_iam_role.cluster.arn
  depends_on = [aws_iam_role_policy_attachment.cluster]
}

output "node_role_arn" {
  value      = aws_iam_role.node.arn
  depends_on = [aws_iam_role_policy_attachment.node]
}
