resource "aws_cognito_identity_pool" "shiny_app" {
  identity_pool_name               = "${var.project_name}-identity-pool"
  allow_unauthenticated_identities = true

}