###############################Lambda########################


data "aws_iam_policy_document" "lambda" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    effect    = "Allow"
    resources = ["*"]
    sid       = "CreateCloudWatchLogs"
  }

  statement {
    actions = [
      "s3:GetObject"
    ]
    effect    = "Allow"
    resources = ["${aws_s3_bucket.source_bucket.arn}/*", "${aws_s3_bucket.destination_bucket.arn}/*"]
    sid       = "ReadS3Objects"
  }

  statement {
    actions = [
      "s3:PutObject", "s3:PutObjectAcl"
    ]
    effect    = "Allow"
    resources = ["${aws_s3_bucket.destination_bucket.arn}/*"]
    sid       = "PutS3Objects"
  }

}


resource "aws_iam_role" "lambda" {
  name               = "${var.project_name}-lambda-role"
  assume_role_policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
       {
           "Action": "sts:AssumeRole",
           "Principal": {
               "Service": "lambda.amazonaws.com"
           },
           "Effect": "Allow"
       }
   ]
}
 EOF
}


resource "aws_iam_policy" "lambda" {
  name   = "${var.project_name}-lambda-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.lambda.json
}


resource "aws_iam_role_policy_attachment" "lambda" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda.arn
}

###############################Cognito########################

resource "aws_iam_role" "unauth_iam_role" {
  name               = "unauth_iam_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "cognito-identity.amazonaws.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "cognito-identity.amazonaws.com:aud":"${aws_cognito_identity_pool.shiny_app.id}"
        },
        "ForAnyValue:StringLike": {
          "cognito-identity.amazonaws.com:amr": "unauthenticated"
        }
      }
    }
  ]
}
 EOF
}


data "aws_iam_policy_document" "cognito_unauth_policy" {
  statement {
    actions = [
      "s3:PutObject", "s3:PutObjectAcl"
    ]
    effect    = "Allow"
    resources = ["${aws_s3_bucket.source_bucket.arn}/*"]
    sid       = "PutS3Objects"
  }

}


resource "aws_iam_policy" "cognito_unauth_policy" {
  name   = "${var.project_name}-cognito-unauth-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.cognito_unauth_policy.json
}


resource "aws_iam_role_policy_attachment" "cognito_unauth" {
  role       = aws_iam_role.unauth_iam_role.name
  policy_arn = aws_iam_policy.cognito_unauth_policy.arn
}