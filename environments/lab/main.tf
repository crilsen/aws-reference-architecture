provider "aws" {
  region = var.aws_region

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
  source                = "../../modules/network"
  project_name          = var.project_name
  vpc_cidr              = var.vpc_cidr
  availability_zones    = local.availability_zones
  aws_region            = var.aws_region
  single_nat_gateway    = var.single_nat_gateway
  nat_eip_allocation_id = var.nat_eip_allocation_id
  tags                  = { Environment = "Lab", Purpose = "Learning" }
}

module "identity" {
  source       = "../../modules/iam"
  project_name = var.project_name
}

module "cluster" {
  source                      = "../../modules/eks"
  project_name                = var.project_name
  kubernetes_version          = var.kubernetes_version
  private_subnet_ids          = module.network.private_subnet_ids
  cluster_role_arn            = module.identity.cluster_role_arn
  node_role_arn               = module.identity.node_role_arn
  ebs_csi_role_arn            = module.identity.ebs_csi_role_arn
  enable_ebs_csi_pod_identity = true
  cluster_security_group_id   = module.network.cluster_security_group_id
  node_security_group_id      = module.network.node_security_group_id
  node_instance_types         = var.node_instance_types
  endpoint_public_access      = var.endpoint_public_access
  public_access_cidrs         = var.public_access_cidrs
  node_desired_size           = var.node_desired_size
  node_min_size               = var.node_min_size
  node_max_size               = var.node_max_size
  tags                        = { Environment = "Lab", Purpose = "Learning" }
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

module "github_runner" {
  source = "../../modules/github-runner"

  project_name                      = var.project_name
  aws_region                        = var.aws_region
  subnet_id                         = module.network.private_subnet_ids[0]
  cluster_security_group_id         = module.network.cluster_security_group_id
  github_repository_url             = var.github_repository_url
  registration_token_parameter_name = var.github_runner_registration_token_parameter_name
  tags                              = { Environment = "Lab", Purpose = "GitHubActions" }
}
