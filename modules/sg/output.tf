output "security_group_id_ssh" {
  description = "The ID to security group created to allow ssh"
  value       = aws_security_group.sg["ssh"].id
}
output "security_group_id_http" {
  description = "The ID to security group created to allow http"
  value       = aws_security_group.sg["http"].id
}
output "security_group_id_https" {
  description = "The ID to security group created to allow https"
  value       = aws_security_group.sg["https"].id
}