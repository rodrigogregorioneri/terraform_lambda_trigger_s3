resource "aws_iam_role" "iam_for_lambda" {
  name = "teste-neri"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}



resource "aws_lambda_function" "test_lambda_dev" {
  filename      = "lambdas/cloudwatch-error-file-log.zip"
  function_name = "lambda-cloudwatch-error-file-log-dev" 
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "handler.lambda_function"



#     function_name      = "lambda-cloudwatch-error-file-log"
#   filename            = 
#   description        = "description should be here"
#   handler            = "handler.lambda_function"
#   runtime            = "python3.8"
#   memory_size        = "128"
#   concurrency        = "5"
#   lambda_timeout     = "20"
#   log_retention      = "1"
#   role_arn           = "some-role-arn"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = base64sha256("lambdas/cloudwatch-error-file-log.zip")

  runtime = "python3.8"

  timeout = 900

  memory_size = 128

  environment {
    variables = {
      foo = "bar"
    }
  }
}





resource "aws_cloudwatch_log_group" "example" {
  name              = "/aws/lambda/${aws_lambda_function.test_lambda_dev.function_name}"
  retention_in_days = 14
}

# See also the following AWS managed policy: AWSLambdaBasicExecutionRole
resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

