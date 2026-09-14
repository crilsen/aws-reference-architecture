resource "aws_kms_key" "eks" {
  description = "Encrypt Kubernetes secrets for the lab cluster."
  deletion_window_in_days = 7
  enable_key_rotation = true
}
resource "aws_cloudwatch_log_group" "cluster" {
  name = "/aws/eks/${var.project_name}/cluster"
  retention_in_days = 14
}
resource "aws_eks_cluster" "this" {
  name = var.project_name
  role_arn = var.cluster_role_arn
  version = var.kubernetes_version
  enabled_cluster_log_types = ["api", "audit", "authenticator"]
  vpc_config {
    subnet_ids = var.private_subnet_ids
    endpoint_private_access = true
    endpoint_public_access = true
    public_access_cidrs = ["0.0.0.0/0"]
  }
  encryption_config {
    provider {
      key_arn = aws_kms_key.eks.arn
    }
    resources = ["secrets"]
  }
  depends_on = [aws_cloudwatch_log_group.cluster]
}
resource "aws_eks_node_group" "default" {
  cluster_name = aws_eks_cluster.this.name
  node_group_name = "default"
  node_role_arn = var.node_role_arn
  subnet_ids = var.private_subnet_ids
  instance_types = var.node_instance_types
  scaling_config {
    desired_size = 2
    min_size     = 1
    max_size     = 3
  }
  update_config { max_unavailable = 1 }
}
resource "aws_eks_addon" "core" {
  for_each = toset(["coredns", "kube-proxy", "vpc-cni", "eks-pod-identity-agent"])
  cluster_name = aws_eks_cluster.this.name
  addon_name = each.value
  resolve_conflicts_on_update = "PRESERVE"
  depends_on = [aws_eks_node_group.default]
}
