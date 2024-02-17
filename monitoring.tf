resource "aws_cloudwatch_metric_alarm" "rate_limit_exceeded_alarm" {
  alarm_name          = "rate_limit_exceeded"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "RateLimitExceeded"
  namespace           = "AWS/ApiGateway"
  period              = 600
  statistic           = "Sum"
  threshold           = "210"
  alarm_description   = "This metric monitors for rate limit exceeded"
  dimensions = {
    ApiName = aws_api_gateway_rest_api.api.name
    Stage   = aws_api_gateway_deployment.api_deployment.stage_name
  }
  alarm_actions = [aws_sns_topic.alarm_topic.arn]
}


resource "aws_sns_topic" "alarm_topic" {
  name = "api-gateway-rate-limit-alarm-topic"
}


resource "aws_sns_topic_subscription" "alarm_topic_subscription" {
  topic_arn = aws_sns_topic.alarm_topic.arn
  protocol  = "email"
  endpoint  = var.alarm_email_address
}


resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging_policy"
  description = "IAM policy for logging from a lambda to CloudWatch Logs"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "write_lambda_logs_attach" {
  role       = aws_iam_role.lambda_iam_role.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

resource "aws_iam_role_policy_attachment" "read_lambda_logs_attach" {
  role       = aws_iam_role.read_lambda_iam_role.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}
