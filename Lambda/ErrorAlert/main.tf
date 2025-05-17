data "archive_file" "error_alert_zip" {
  type        = "zip"
  source_file = "${path.module}/ErrorAlert.py"
  output_path = "${path.module}/ErrorAlert.zip"
}

resource "aws_lambda_function" "error_alert" {
  filename      = data.archive_file.error_alert_zip.output_path
  function_name = "AWSAlertValidationErrorAlert"
  role          = aws_iam_role.error_alert_lambda_execution.arn
  handler       = "ErrorAlert.lambda_handler"
  runtime       = "python3.12"

  timeout          = 30
  source_code_hash = data.archive_file.error_alert_zip.output_base64sha256

  tags = {
    monitoring = "true"
  }
}

resource "aws_cloudwatch_log_group" "error_alert" {
  name              = "/aws/lambda/${aws_lambda_function.error_alert.function_name}"
  retention_in_days = 30
}

resource "aws_iam_role" "error_alert_lambda_execution" {
  name = lower("error_alert_lambda_execution")
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "error_alert_lambda_create_logs" {
  name = lower("error_alert_cloudwatch_logs")
  role = aws_iam_role.error_alert_lambda_execution.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:logs:*:*:log-group:*"
      }
    ]
  })
}
