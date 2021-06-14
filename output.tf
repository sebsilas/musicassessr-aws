output "Shiny_app_url" {
  value = "https://${aws_instance.shiny_app.public_ip}"
}