provider "aws" {
  region = var.aws_region

  assume_role {
    role_arn     = "arn:aws:iam::${var.target_account_id}:role/${var.deployment_role_name}"
    session_name = "terraform-kubernetes-lab"
  }

  default_tags {
    tags = { Project = var.project_name, Environment = "Lab", ManagedBy = "Terraform", Purpose = "Learning" }
  }
}

data "aws_caller_identity" "deployment" {}
data "aws_availability_zones" "available" { state = "available" }
locals { availability_zones = slice(data.aws_availability_zones.available.names, 0, 2) }

check "lab_account_boundary" {
  assert {
    condition     = data.aws_caller_identity.deployment.account_id == var.target_account_id
    error_message = "Refusing to deploy the Lab environment outside the expected Lab account."
  }
}

module "network" {
  source             = "../../modules/network"
  project_name       = var.project_name
  vpc_cidr           = var.vpc_cidr
  availability_zones = local.availability_zones
}

module "identity" {
  source       = "../../modules/iam"
  project_name = var.project_name
}

module "cluster" {
  source              = "../../modules/eks"
  project_name        = var.project_name
  kubernetes_version  = var.kubernetes_version
  private_subnet_ids  = module.network.private_subnet_ids
  cluster_role_arn    = module.identity.cluster_role_arn
  node_role_arn       = module.identity.node_role_arn
  node_instance_types = var.node_instance_types
}

module "registry" {
  source       = "../../modules/registry"
  project_name = var.project_name
}
module "observability" {
  source       = "../../modules/observability"
  project_name = var.project_name
  cluster_name = module.cluster.cluster_name
}
