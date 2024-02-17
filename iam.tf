resource "aws_iam_role" "read_lambda_iam_role" {
  name = "lambda_s3_reader_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
      },
    ]
  })
}

resource "aws_iam_role" "lambda_iam_role" {
  name = "lambda_s3_writer_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
      },
    ]
  })
}


# Policy allowing Lambda to write to S3 and use the KMS key
resource "aws_iam_policy" "lambda_s3_kms_policy" {
  name   = "lambda_s3_kms_policy"
  policy = data.aws_iam_policy_document.lambda_s3_kms_policy.json
}

# IAM policy document
data "aws_iam_policy_document" "lambda_s3_kms_policy" {
  statement {
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = [
      "${aws_s3_bucket.scheduled_objects.arn}",
      "${aws_s3_bucket.scheduled_objects.arn}/*"
    ]
  }
  statement {
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = [
      aws_kms_key.s3_kms_key.arn
    ]
  }
}

# Attach policy to the IAM role
resource "aws_iam_role_policy_attachment" "lambda_s3_kms_policy_attach" {
  role       = aws_iam_role.lambda_iam_role.name
  policy_arn = aws_iam_policy.lambda_s3_kms_policy.arn
}

# Permission for EventBridge to invoke the Lambda function
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_writer.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.lambda_schedule.arn
}

resource "aws_iam_policy" "lambda_s3_read_kms" {
  name        = "lambda_s3_read_kms_policy"
  description = "IAM policy for lambda to read from S3 and use KMS"
  policy      = data.aws_iam_policy_document.lambda_s3_read_kms_policy.json
}

resource "aws_iam_role_policy_attachment" "lambda_s3_read_kms_attach" {
  role       = aws_iam_role.read_lambda_iam_role.name
  policy_arn = aws_iam_policy.lambda_s3_read_kms.arn
}


resource "aws_lambda_permission" "api_gateway_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_reader.function_name
  principal     = "apigateway.amazonaws.com"

  # The /*/* represents any method on any resource within the API Gateway REST API
  source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}


data "aws_iam_policy_document" "lambda_s3_read_kms_policy" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = [
      "${aws_s3_bucket.scheduled_objects.arn}/*",
      "${aws_s3_bucket.scheduled_objects.arn}"
    ]
  }
  statement {
    actions = [
      "kms:Decrypt"
    ]
    resources = [
      "${aws_kms_key.s3_kms_key.arn}"
    ]
  }
}

