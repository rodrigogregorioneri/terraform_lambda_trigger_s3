resource "aws_s3_bucket" "cloudwatch-error-file-log-bucket" {
  bucket = "cloudwatch-error-file-log-bucket"
  acl    = "private"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}


resource "aws_s3_bucket_notification" "bucket_notification_neri_dev" {
    bucket =  "${aws_s3_bucket.cloudwatch-error-file-log-bucket.id}"

    lambda_function {
        lambda_function_arn =  "${aws_lambda_function.test_lambda_dev.arn}"
        events = ["s3:ObjectCreated:*"]
        filter_prefix = "files/"
    }
} 


resource "aws_iam_role" "iam_for_cloudwatch-error-file-log-bucket" {
  name = "iam_for_lambda"

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

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.test_lambda_dev.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.cloudwatch-error-file-log-bucket.arn
}

