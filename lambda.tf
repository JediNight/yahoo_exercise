data "archive_file" "lambda_s3reader" {
  type        = "zip"
  source_file = "${path.module}/functions/http_reader.py"
  output_path = "${path.module}/functions/http_reader.zip"
}

data "archive_file" "lambda_upload" {
  type        = "zip"
  source_file = "${path.module}/functions/upload.py"
  output_path = "${path.module}/functions/upload.zip"
}


resource "aws_cloudwatch_event_rule" "lambda_schedule" {
  name                = "every-10-minutes"
  description         = "Trigger Lambda every 10 minutes"
  schedule_expression = "cron(*/10 * * * ? *)"
}

# EventBridge target for the Lambda function
resource "aws_cloudwatch_event_target" "lambda_target" {
  rule = aws_cloudwatch_event_rule.lambda_schedule.name
  arn  = aws_lambda_function.s3_writer.arn
}


resource "aws_lambda_function" "s3_writer" {
  function_name = "s3_writer"
  source_code_hash = data.archive_file.lambda_upload.output_base64sha256
  handler       = "upload.lambda_handler"
  runtime       = "python3.8"
  role          = aws_iam_role.lambda_iam_role.arn
  filename      = "${path.module}/functions/upload.zip"


  environment {
    variables = {
      BUCKET_NAME = "${aws_s3_bucket.scheduled_objects.bucket}"
      KMS_KEY_ARN = "${aws_kms_key.s3_kms_key.arn}"
    }
  }
}

resource "aws_lambda_function" "s3_reader" {
  function_name = "http_s3_reader"
  source_code_hash = data.archive_file.lambda_s3reader.output_base64sha256
  handler       = "http_reader.lambda_handler"
  runtime       = "python3.8"
  role          = aws_iam_role.read_lambda_iam_role.arn
  filename      = "${path.module}/functions/http_reader.zip"

  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.scheduled_objects.bucket
      KMS_KEY_ARN = "${aws_kms_key.s3_kms_key.arn}"
    }
  }
}
