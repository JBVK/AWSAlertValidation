data "archive_file" "throttling_alarm_zip" {
  type        = "zip"
  source_file = "${path.module}/ThrottlingAlarm.py"
  output_path = "${path.module}/ThrottlingAlarm.zip"
}

resource "aws_lambda_function" "throttling_alarm" {
  filename                       = data.archive_file.throttling_alarm_zip.output_path
  function_name                  = "AWSAlertValidationThrottlingAlarm"
  role                           = aws_iam_role.throttling_alarm_lambda_execution.arn
  handler                        = "ThrottlingAlarm.lambda_handler"
  runtime                        = "python3.12"
  reserved_concurrent_executions = 1

  timeout          = 30
  source_code_hash = data.archive_file.throttling_alarm_zip.output_base64sha256

  tags = {
    monitoring = "true"
  }
}

resource "aws_cloudwatch_log_group" "throttling_alarm" {
  name              = "/aws/lambda/${aws_lambda_function.throttling_alarm.function_name}"
  retention_in_days = 30
}

resource "aws_iam_role" "throttling_alarm_lambda_execution" {
  name = lower("throttling_alarm_lambda_execution")
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

resource "aws_iam_role_policy" "throttling_alarm_lambda_create_logs" {
  name = lower("throttling_alarm_cloudwatch_logs")
  role = aws_iam_role.throttling_alarm_lambda_execution.id

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
