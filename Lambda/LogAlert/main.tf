data "archive_file" "log_alert_zip" {
  type        = "zip"
  source_file = "${path.module}/LogAlert.py"
  output_path = "${path.module}/LogAlert.zip"
}

resource "aws_lambda_function" "log_alert" {
  filename      = data.archive_file.log_alert_zip.output_path
  function_name = "AWSAlertValidationLogAlert"
  role          = aws_iam_role.log_alert_lambda_execution.arn
  handler       = "LogAlert.lambda_handler"
  runtime       = "python3.12"

  source_code_hash = data.archive_file.log_alert_zip.output_base64sha256

  environment {
    variables = {
      LOG_LINE = "Testing log alert" # Change this to the log line you want to alert on
    }
  }

  tags = {
    monitoring = "true"
  }
}

resource "aws_cloudwatch_log_group" "log_alert" {
  name              = "/aws/lambda/${aws_lambda_function.log_alert.function_name}"
  retention_in_days = 30
}

resource "aws_iam_role" "log_alert_lambda_execution" {
  name = lower("log_alert_lambda_execution")
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

resource "aws_iam_role_policy" "log_alert_lambda_create_logs" {
  name = lower("log_alert_cloudwatch_logs")
  role = aws_iam_role.log_alert_lambda_execution.id

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
