aws_region           = "us-east-1"
target_account_id    = "replace-with-production-account-id"
deployment_role_name = "OrganizationAccountAccessRole"
project_name         = "kubernetes-production"
kubernetes_version   = "1.33"
vpc_cidr             = "10.43.0.0/16"
node_instance_types  = ["t3.medium"]
