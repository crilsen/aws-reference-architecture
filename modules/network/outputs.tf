output "vpc_id" { value = aws_vpc.this.id }
output "public_subnet_ids" { value = values(aws_subnet.public)[*].id }
output "private_subnet_ids" { value = values(aws_subnet.private_nodes)[*].id }
output "private_endpoint_subnet_ids" { value = values(aws_subnet.private_endpoints)[*].id }
output "cluster_security_group_id" { value = aws_security_group.cluster.id }
output "node_security_group_id" { value = aws_security_group.nodes.id }
output "vpc_endpoint_security_group_id" { value = aws_security_group.vpc_endpoints.id }
output "nat_gateway_ids" { value = values(aws_nat_gateway.this)[*].id }
