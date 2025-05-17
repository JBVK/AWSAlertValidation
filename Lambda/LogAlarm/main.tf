data "archive_file" "log_alarm_zip" {
  type        = "zip"
  source_file = "${path.module}/LogAlarm.py"
  output_path = "${path.module}/LogAlarm.zip"
}

resource "aws_lambda_function" "log_alarm" {
  filename      = data.archive_file.log_alarm_zip.output_path
  function_name = "AWSAlertValidationLogAlarm"
  role          = aws_iam_role.log_alarm_lambda_execution.arn
  handler       = "LogAlarm.lambda_handler"
  runtime       = "python3.12"

  source_code_hash = data.archive_file.log_alarm_zip.output_base64sha256

  environment {
    variables = {
      LOG_LINE = "Testing log alarm" # Change this to the log line you want to alarm on
    }
  }

  tags = {
    monitoring = "true"
  }
}

resource "aws_cloudwatch_log_group" "log_alarm" {
  name              = "/aws/lambda/${aws_lambda_function.log_alarm.function_name}"
  retention_in_days = 30
}

resource "aws_iam_role" "log_alarm_lambda_execution" {
  name = lower("log_alarm_lambda_execution")
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

resource "aws_iam_role_policy" "log_alarm_lambda_create_logs" {
  name = lower("log_alarm_cloudwatch_logs")
  role = aws_iam_role.log_alarm_lambda_execution.id

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
