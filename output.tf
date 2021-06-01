output "Shiny_app_url" {
  value = aws_lb.front-end.dns_name
}