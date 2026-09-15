locals {
  subnet_azs     = { for index, zone in var.availability_zones : zone => index }
  primary_az     = var.availability_zones[0]
  nat_azs        = var.single_nat_gateway ? { (local.primary_az) = local.subnet_azs[local.primary_az] } : local.subnet_azs
  create_nat_eip = var.nat_eip_allocation_id == null
  common_tags    = merge(var.tags, { Project = var.project_name, ManagedBy = "Terraform" })
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = merge(local.common_tags, { Name = "${var.project_name}-vpc" })
}
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags   = merge(local.common_tags, { Name = "${var.project_name}-igw" })
}
resource "aws_subnet" "public" {
  for_each                = local.subnet_azs
  vpc_id                  = aws_vpc.this.id
  availability_zone       = each.key
  cidr_block              = cidrsubnet(var.vpc_cidr, 4, each.value)
  map_public_ip_on_launch = false
  tags                    = merge(local.common_tags, { Name = "${var.project_name}-public-${each.key}", "kubernetes.io/role/elb" = "1" })
}
resource "aws_subnet" "private_nodes" {
  for_each          = local.subnet_azs
  vpc_id            = aws_vpc.this.id
  availability_zone = each.key
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, each.value + 4)
  tags              = merge(local.common_tags, { Name = "${var.project_name}-private-nodes-${each.key}", "kubernetes.io/role/internal-elb" = "1" })
}
resource "aws_subnet" "private_endpoints" {
  for_each          = local.subnet_azs
  vpc_id            = aws_vpc.this.id
  availability_zone = each.key
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, each.value + 8)
  tags              = merge(local.common_tags, { Name = "${var.project_name}-private-endpoints-${each.key}" })
}
resource "aws_eip" "nat" {
  for_each = local.create_nat_eip ? local.nat_azs : {}
  domain   = "vpc"
  tags     = merge(local.common_tags, { Name = "${var.project_name}-nat-eip-${each.key}" })
}
resource "aws_nat_gateway" "this" {
  for_each      = local.nat_azs
  allocation_id = var.nat_eip_allocation_id != null ? var.nat_eip_allocation_id : aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.public[each.key].id
  depends_on    = [aws_internet_gateway.this]
  tags          = merge(local.common_tags, { Name = "${var.project_name}-nat-${each.key}" })

  lifecycle {
    precondition {
      condition     = var.nat_eip_allocation_id == null || var.single_nat_gateway
      error_message = "A supplied NAT EIP can be used only when single_nat_gateway is true."
    }
  }
}
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
  tags = merge(local.common_tags, { Name = "${var.project_name}-rt-public" })
}
resource "aws_route_table" "private" {
  for_each = local.subnet_azs
  vpc_id   = aws_vpc.this.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this[var.single_nat_gateway ? local.primary_az : each.key].id
  }
  tags = merge(local.common_tags, { Name = "${var.project_name}-rt-private-${each.key}" })
}
resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "private_nodes" {
  for_each       = aws_subnet.private_nodes
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}
resource "aws_route_table_association" "private_endpoints" {
  for_each       = aws_subnet.private_endpoints
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}
resource "aws_vpc_endpoint" "s3" {
  count             = var.enable_vpc_endpoints ? 1 : 0
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = values(aws_route_table.private)[*].id
  tags              = merge(local.common_tags, { Name = "${var.project_name}-vpce-s3" })
}
resource "aws_vpc_endpoint" "interface" {
  for_each            = var.enable_vpc_endpoints ? toset(["ecr.api", "ecr.dkr", "sts", "logs", "ec2", "eks", "eks-auth", "elasticloadbalancing"]) : toset([])
  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.${var.aws_region}.${each.value}"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = values(aws_subnet.private_endpoints)[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  tags                = merge(local.common_tags, { Name = "${var.project_name}-vpce-${replace(each.value, ".", "-")}" })
}
