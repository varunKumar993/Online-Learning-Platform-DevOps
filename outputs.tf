output "app_instance_ids" { value = aws_instance.app_server[*].id }
output "app_public_ips"   { value = aws_instance.app_server[*].public_ip }
output "app_private_ips"  { value = aws_instance.app_server[*].private_ip }
output "db_instance_id"   { value = aws_instance.db_server.id }
output "db_public_ip"     { value = aws_instance.db_server.public_ip }
output "db_private_ip"    { value = aws_instance.db_server.private_ip }
