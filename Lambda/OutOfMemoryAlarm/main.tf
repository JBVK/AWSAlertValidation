data "archive_file" "out_of_memory_alarm_zip" {
  type        = "zip"
  source_file = "${path.module}/OutOfMemoryAlarm.py"
  output_path = "${path.module}/OutOfMemoryAlarm.zip"
}

resource "aws_lambda_function" "out_of_memory_alarm" {
  filename         = data.archive_file.out_of_memory_alarm_zip.output_path
  function_name    = "AWSAlertValidationOutOfMemoryAlarm"
  role             = aws_iam_role.out_of_memory_alarm_lambda_execution.arn
  handler          = "OutOfMemoryAlarm.lambda_handler"
  runtime          = "python3.12"
  memory_size      = 128
  timeout          = 30
  source_code_hash = data.archive_file.out_of_memory_alarm_zip.output_base64sha256

  environment {
    variables = {
      LAMBDA_FUNCTION_MEMORY_SIZE = "128"
    }
  }

  tags = {
    monitoring = "true"
  }
}

resource "aws_cloudwatch_log_group" "out_of_memory_alarm" {
  name              = "/aws/lambda/${aws_lambda_function.out_of_memory_alarm.function_name}"
  retention_in_days = 30
}

resource "aws_iam_role" "out_of_memory_alarm_lambda_execution" {
  name = lower("out_of_memory_alarm_lambda_execution")
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

resource "aws_iam_role_policy" "out_of_memory_alarm_lambda_create_logs" {
  name = lower("out_of_memory_alarm_cloudwatch_logs")
  role = aws_iam_role.out_of_memory_alarm_lambda_execution.id

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
