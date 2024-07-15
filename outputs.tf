output "primary_web_instance_public_ip" {
  value = aws_instance.web.public_ip
}

output "secondary_web_instance_public_ip" {
  value = aws_instance.secondary_web.public_ip
}

output "primary_app_instance_private_ip" {
  value = aws_instance.app.private_ip
}

output "secondary_app_instance_private_ip" {
  value = aws_instance.secondary_app.private_ip
}

output "primary_db_endpoint" {
  value = aws_db_instance.primary_db.endpoint
}

output "secondary_db_endpoint" {
  value = aws_db_instance.secondary_db.endpoint
}
