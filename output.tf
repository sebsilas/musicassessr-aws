output "Shiny_app_url" {
  value = "https://${aws_instance.shiny_app.public_ip}"
}

output "rds_endpont" {
  value = aws_db_instance.shiny-db.address
}