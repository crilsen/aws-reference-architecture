variable "project_name" { type = string }
variable "kubernetes_version" { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "cluster_role_arn" { type = string }
variable "node_role_arn" { type = string }
variable "node_instance_types" { type = list(string) }
