import {
  to = aws_s3_bucket.destination_bucket
 
  id = local.s3_destination_bucket_name
}

import {
  to = aws_s3_bucket.source_bucket
  id = local.s3_source_bucket_name
}

import {
  to = aws_iam_role.lambda
  id = "${var.project_name}-lambda-role"
}

import {
  to = aws_iam_role.unauth_iam_role
  id = "unauth_iam_role"
}

import {
  to = aws_iam_policy.lambda
  id = "arn:aws:iam::544536681621:policy/shinny-app-lambda-policy"
}

import {
  to = aws_iam_policy.cognito_unauth_policy
  id = "arn:aws:iam::544536681621:policy/shinny-app-cognito-unauth-policy"
}

import {
  to = aws_ecr_repository.sonic_pyin
  id = "${var.project_name}_sonic_pyin"
}

import {
  to = aws_cognito_identity_pool.shiny_app
  id = "us-east-1:feecdf7e-cdf6-416f-94d0-a6de428c8c6b"
}

import {
  to = aws_cognito_identity_pool_roles_attachment.shiny_app
  id = "us-east-1:feecdf7e-cdf6-416f-94d0-a6de428c8c6b"
}


import {
  to = aws_api_gateway_rest_api.sonic_pyin
  id = "255uxe6ajl"
}