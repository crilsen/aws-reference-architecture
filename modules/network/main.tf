resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = { Name = "${var.project_name}-vpc" }
}

resource "aws_internet_gateway" "this" { vpc_id = aws_vpc.this.id }

resource "aws_subnet" "public" {
  for_each = { for index, zone in var.availability_zones : zone => index }
  vpc_id = aws_vpc.this.id
  availability_zone = each.key
  cidr_block = cidrsubnet(var.vpc_cidr, 4, each.value)
  map_public_ip_on_launch = true
  tags = { Name = "${var.project_name}-public-${each.key}", "kubernetes.io/role/elb" = "1" }
}

resource "aws_subnet" "private" {
  for_each = { for index, zone in var.availability_zones : zone => index }
  vpc_id = aws_vpc.this.id
  availability_zone = each.key
  cidr_block = cidrsubnet(var.vpc_cidr, 4, each.value + 8)
  tags = { Name = "${var.project_name}-private-${each.key}", "kubernetes.io/role/internal-elb" = "1" }
}

resource "aws_eip" "nat" { domain = "vpc" }
resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id = values(aws_subnet.public)[0].id
  depends_on = [aws_internet_gateway.this]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
}
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }
}
resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public
  subnet_id = each.value.id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private
  subnet_id = each.value.id
  route_table_id = aws_route_table.private.id
}

resource "aws_security_group" "endpoints" {
  name_prefix = "${var.project_name}-endpoints-"
  description = "Allow HTTPS from inside the lab VPC."
  vpc_id = aws_vpc.this.id
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id = aws_vpc.this.id
  service_name = "com.amazonaws.us-east-1.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids = [aws_route_table.private.id]
}
resource "aws_vpc_endpoint" "interface" {
  for_each = toset(["ecr.api", "ecr.dkr", "logs", "sts"])
  vpc_id = aws_vpc.this.id
  service_name = "com.amazonaws.us-east-1.${each.value}"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  subnet_ids = values(aws_subnet.private)[*].id
  security_group_ids = [aws_security_group.endpoints.id]
}
