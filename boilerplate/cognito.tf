resource "aws_cognito_identity_pool" "shiny_app" {
  identity_pool_name               = "${var.project_name}-identity-pool"
  allow_unauthenticated_identities = true
}


resource "aws_cognito_identity_pool_roles_attachment" "shiny_app" {
  identity_pool_id = aws_cognito_identity_pool.shiny_app.id

  roles = {
    unauthenticated = "${aws_iam_role.unauth_iam_role.arn}"
  }
}