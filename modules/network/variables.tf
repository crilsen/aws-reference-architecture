variable "project_name" { type = string }
variable "vpc_cidr" { type = string }
variable "availability_zones" { type = list(string) }
variable "aws_region" {
  type    = string
  default = "us-east-1"
}
variable "single_nat_gateway" {
  type    = bool
  default = false
}
variable "enable_vpc_endpoints" {
  type    = bool
  default = true
}
variable "nat_eip_allocation_id" {
  description = "Existing Elastic IP allocation ID to associate with a single NAT Gateway."
  type        = string
  default     = null
}
variable "tags" {
  type    = map(string)
  default = {}
}
