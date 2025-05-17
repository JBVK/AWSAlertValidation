data "archive_file" "dlq_alarm_zip" {
  type        = "zip"
  source_file = "${path.module}/DLQAlarm.py"
  output_path = "${path.module}/DLQAlarm.zip"
}

resource "aws_lambda_function" "dlq_alarm" {
  filename                       = data.archive_file.dlq_alarm_zip.output_path
  function_name                  = "AWSAlertValidationDLQAlarm"
  role                           = aws_iam_role.dlq_alarm_lambda_execution.arn
  handler                        = "DLQAlarm.lambda_handler"
  runtime                        = "python3.12"
  reserved_concurrent_executions = 1

  timeout          = 30
  source_code_hash = data.archive_file.dlq_alarm_zip.output_base64sha256

  dead_letter_config {
    target_arn = aws_sqs_queue.dlq_alarm.arn
  }

  tags = {
    monitoring = "true"
  }
}

resource "aws_cloudwatch_log_group" "dlq_alarm" {
  name              = "/aws/lambda/${aws_lambda_function.dlq_alarm.function_name}"
  retention_in_days = 30
}

resource "aws_iam_role" "dlq_alarm_lambda_execution" {
  name = lower("dlq_alarm_lambda_execution")
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

resource "aws_iam_role_policy" "dlq_alarm_lambda_create_logs" {
  name = lower("dlq_alarm_cloudwatch_logs")
  role = aws_iam_role.dlq_alarm_lambda_execution.id

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

resource "aws_iam_role_policy" "dlq_alarm_lambda_sqs" {
  name = lower("dlq_alarm_lambda_sqs")
  role = aws_iam_role.dlq_alarm_lambda_execution.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "sqs:SendMessage",
        ],
        Effect   = "Allow",
        Resource = aws_sqs_queue.dlq_alarm.arn
      }
    ]
  })

}

resource "aws_sqs_queue" "dlq_alarm" {
  name = "AWSAlertValidationDLQAlarm"
}
