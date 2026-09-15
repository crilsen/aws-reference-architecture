variable "project_name" { type = string }
variable "kubernetes_version" { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "cluster_role_arn" { type = string }
variable "node_role_arn" { type = string }
variable "ebs_csi_role_arn" {
  type    = string
  default = null
}
variable "cluster_security_group_id" {
  type    = string
  default = null
}
variable "node_security_group_id" {
  type    = string
  default = null
}
variable "enable_ebs_csi_pod_identity" {
  type    = bool
  default = false
}
variable "node_instance_types" { type = list(string) }
variable "endpoint_public_access" {
  type    = bool
  default = false
}
variable "public_access_cidrs" {
  type    = list(string)
  default = []
}
variable "node_disk_size" {
  type    = number
  default = 50
}
variable "node_desired_size" {
  type    = number
  default = 2
}
variable "node_min_size" {
  type    = number
  default = 1
}
variable "node_max_size" {
  type    = number
  default = 3
}
variable "log_retention_days" {
  type    = number
  default = 14
}
variable "tags" {
  type    = map(string)
  default = {}
}
