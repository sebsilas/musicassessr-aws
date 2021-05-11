###############################ECS########################
data "aws_iam_policy_document" "ecs_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}


data "aws_iam_policy_document" "ecs_task_execution_role_policy" {
  statement {
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
    "logs:PutLogEvents"]
    resources = ["*"]

  }
}


resource "aws_iam_policy" "ecs_task_execution_role_policy" {
  name   = "ecs_task_execution_role_policy"
  policy = data.aws_iam_policy_document.ecs_task_execution_role_policy.json
}


resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${var.project_name}-${local.stage}-ecs-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role_policy.json
}


resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_task_execution_role_policy.arn
}

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
      "s3:PutObject","s3:PutObjectAcl"
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
      "s3:PutObject","s3:PutObjectAcl"
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
