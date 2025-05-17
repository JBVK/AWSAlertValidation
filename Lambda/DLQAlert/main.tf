data "archive_file" "dlq_alert_zip" {
  type        = "zip"
  source_file = "${path.module}/DLQAlert.py"
  output_path = "${path.module}/DLQAlert.zip"
}

resource "aws_lambda_function" "dlq_alert" {
  filename                       = data.archive_file.dlq_alert_zip.output_path
  function_name                  = "AWSAlertValidationDLQAlert"
  role                           = aws_iam_role.dlq_alert_lambda_execution.arn
  handler                        = "DLQAlert.lambda_handler"
  runtime                        = "python3.12"
  reserved_concurrent_executions = 1

  timeout          = 30
  source_code_hash = data.archive_file.dlq_alert_zip.output_base64sha256

  dead_letter_config {
    target_arn = aws_sqs_queue.dlq_alert.arn
  }

  tags = {
    monitoring = "true"
  }
}

resource "aws_cloudwatch_log_group" "dlq_alert" {
  name              = "/aws/lambda/${aws_lambda_function.dlq_alert.function_name}"
  retention_in_days = 30
}

resource "aws_iam_role" "dlq_alert_lambda_execution" {
  name = lower("dlq_alert_lambda_execution")
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

resource "aws_iam_role_policy" "dlq_alert_lambda_create_logs" {
  name = lower("dlq_alert_cloudwatch_logs")
  role = aws_iam_role.dlq_alert_lambda_execution.id

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

resource "aws_iam_role_policy" "dlq_alert_lambda_sqs" {
  name = lower("dlq_alert_lambda_sqs")
  role = aws_iam_role.dlq_alert_lambda_execution.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "sqs:SendMessage",
        ],
        Effect   = "Allow",
        Resource = aws_sqs_queue.dlq_alert.arn
      }
    ]
  })

}

resource "aws_sqs_queue" "dlq_alert" {
  name = "AWSAlertValidationDLQAlert"
}
