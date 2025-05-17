data "archive_file" "timeout_alarm_zip" {
  type        = "zip"
  source_file = "${path.module}/TimeoutAlarm.py"
  output_path = "${path.module}/TimeoutAlarm.zip"
}

resource "aws_lambda_function" "timeout_alarm" {
  filename      = data.archive_file.timeout_alarm_zip.output_path
  function_name = "AWSAlertValidationTimeoutAlarm"
  role          = aws_iam_role.timeout_alarm_lambda_execution.arn
  handler       = "TimeoutAlarm.lambda_handler"
  runtime       = "python3.12"

  timeout          = 15
  source_code_hash = data.archive_file.timeout_alarm_zip.output_base64sha256

  tags = {
    monitoring = "true"
  }
}

resource "aws_cloudwatch_log_group" "timeout_alarm" {
  name              = "/aws/lambda/${aws_lambda_function.timeout_alarm.function_name}"
  retention_in_days = 30
}

resource "aws_iam_role" "timeout_alarm_lambda_execution" {
  name = lower("timeout_alarm_lambda_execution")
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

resource "aws_iam_role_policy" "timeout_alarm_lambda_create_logs" {
  name = lower("timeout_alarm_cloudwatch_logs")
  role = aws_iam_role.timeout_alarm_lambda_execution.id

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
