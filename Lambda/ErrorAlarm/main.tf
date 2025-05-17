data "archive_file" "error_alarm_zip" {
  type        = "zip"
  source_file = "${path.module}/ErrorAlarm.py"
  output_path = "${path.module}/ErrorAlarm.zip"
}

resource "aws_lambda_function" "error_alarm" {
  filename      = data.archive_file.error_alarm_zip.output_path
  function_name = "AWSAlertValidationErrorAlarm"
  role          = aws_iam_role.error_alarm_lambda_execution.arn
  handler       = "ErrorAlarm.lambda_handler"
  runtime       = "python3.12"

  timeout          = 30
  source_code_hash = data.archive_file.error_alarm_zip.output_base64sha256

  tags = {
    monitoring = "true"
  }
}

resource "aws_cloudwatch_log_group" "error_alarm" {
  name              = "/aws/lambda/${aws_lambda_function.error_alarm.function_name}"
  retention_in_days = 30
}

resource "aws_iam_role" "error_alarm_lambda_execution" {
  name = lower("error_alarm_lambda_execution")
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

resource "aws_iam_role_policy" "error_alarm_lambda_create_logs" {
  name = lower("error_alarm_cloudwatch_logs")
  role = aws_iam_role.error_alarm_lambda_execution.id

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
