data "archive_file" "high_duration_alarm_zip" {
  type        = "zip"
  source_file = "${path.module}/HighDurationAlarm.py"
  output_path = "${path.module}/HighDurationAlarm.zip"
}

resource "aws_lambda_function" "high_duration_alarm" {
  filename      = data.archive_file.high_duration_alarm_zip.output_path
  function_name = "AWSAlertValidationHighDurationAlarm"
  role          = aws_iam_role.high_duration_alarm_lambda_execution.arn
  handler       = "HighDurationAlarm.lambda_handler"
  runtime       = "python3.12"

  timeout          = 30
  source_code_hash = data.archive_file.high_duration_alarm_zip.output_base64sha256

  tags = {
    monitoring = "true"
  }
}

resource "aws_cloudwatch_log_group" "high_duration_alarm" {
  name              = "/aws/lambda/${aws_lambda_function.high_duration_alarm.function_name}"
  retention_in_days = 30
}

resource "aws_iam_role" "high_duration_alarm_lambda_execution" {
  name = lower("high_duration_alarm_lambda_execution")
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

resource "aws_iam_role_policy" "high_duration_alarm_lambda_create_logs" {
  name = lower("high_duration_alarm_cloudwatch_logs")
  role = aws_iam_role.high_duration_alarm_lambda_execution.id

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
