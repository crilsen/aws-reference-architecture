output "instance_id" { value = aws_instance.this.id }
output "security_group_id" { value = aws_security_group.this.id }
output "registration_token_parameter_name" { value = var.registration_token_parameter_name }
