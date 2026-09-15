locals { common_tags = merge(var.tags, { Project = var.project_name, ManagedBy = "Terraform" }) }
resource "aws_kms_key" "eks" {
  description             = "Encrypt Kubernetes secrets for ${var.project_name}."
  deletion_window_in_days = 7
  enable_key_rotation     = true
  tags                    = merge(local.common_tags, { Name = "${var.project_name}-kms" })
}
resource "aws_kms_alias" "eks" {
  name          = "alias/${var.project_name}-eks"
  target_key_id = aws_kms_key.eks.key_id
}
resource "aws_cloudwatch_log_group" "cluster" {
  name              = "/aws/eks/${var.project_name}/cluster"
  retention_in_days = var.log_retention_days
  tags              = merge(local.common_tags, { Name = "${var.project_name}-cluster-logs" })
}
resource "aws_eks_cluster" "this" {
  name                      = var.project_name
  role_arn                  = var.cluster_role_arn
  version                   = var.kubernetes_version
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  vpc_config {
    subnet_ids              = var.private_subnet_ids
    security_group_ids      = var.cluster_security_group_id == null ? [] : [var.cluster_security_group_id]
    endpoint_private_access = true
    endpoint_public_access  = var.endpoint_public_access
    public_access_cidrs     = var.endpoint_public_access ? var.public_access_cidrs : []
  }
  encryption_config {
    provider { key_arn = aws_kms_key.eks.arn }
    resources = ["secrets"]
  }
  tags       = merge(local.common_tags, { Name = "${var.project_name}-cluster" })
  depends_on = [aws_cloudwatch_log_group.cluster]
}
resource "aws_launch_template" "nodes" {
  name_prefix            = "${var.project_name}-ng-default-"
  vpc_security_group_ids = var.node_security_group_id == null ? [] : [var.node_security_group_id]
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      encrypted   = true
      volume_type = "gp3"
      volume_size = var.node_disk_size
    }
  }
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }
  tag_specifications {
    resource_type = "instance"
    tags          = merge(local.common_tags, { Name = "${var.project_name}-node" })
  }
}
resource "aws_eks_node_group" "default" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.project_name}-default"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.private_subnet_ids
  instance_types  = var.node_instance_types
  launch_template {
    id      = aws_launch_template.nodes.id
    version = "$Latest"
  }
  scaling_config {
    desired_size = var.node_desired_size
    min_size     = var.node_min_size
    max_size     = var.node_max_size
  }
  update_config { max_unavailable = 1 }
  labels = { workload = "general" }
  tags   = merge(local.common_tags, { Name = "${var.project_name}-ng-default" })
}
resource "aws_eks_addon" "core" {
  for_each                    = toset(["coredns", "kube-proxy", "vpc-cni", "eks-pod-identity-agent"])
  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = each.value
  resolve_conflicts_on_update = "PRESERVE"
  depends_on                  = [aws_eks_node_group.default]
}
resource "aws_eks_pod_identity_association" "ebs_csi" {
  count           = var.enable_ebs_csi_pod_identity ? 1 : 0
  cluster_name    = aws_eks_cluster.this.name
  namespace       = "kube-system"
  service_account = "ebs-csi-controller-sa"
  role_arn        = var.ebs_csi_role_arn
  depends_on      = [aws_eks_node_group.default]
}

resource "aws_eks_addon" "ebs_csi" {
  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = "aws-ebs-csi-driver"
  resolve_conflicts_on_update = "PRESERVE"
  depends_on                  = [aws_eks_pod_identity_association.ebs_csi]
}
