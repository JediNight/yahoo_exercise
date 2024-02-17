# API Gateway for the HTTP endpoint
resource "aws_api_gateway_rest_api" "api" {
  name = "TimestampAPI"
}

# API Gateway resource for the HTTP endpoint
resource "aws_api_gateway_resource" "api_resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "timestamp"
}

# API Gateway method for the HTTP endpoint
resource "aws_api_gateway_method" "get_timestamp" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.api_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

# API Gateway integration with the Lambda function
# Integration between API Gateway and the Lambda function
resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.api_resource.id
  http_method             = aws_api_gateway_method.get_timestamp.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.s3_reader.invoke_arn
}

resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on = [
    aws_api_gateway_integration.lambda_integration
  ]

  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = "v1"
}


resource "aws_api_gateway_usage_plan" "usage_plan" {
  name        = "RateLimited"
  description = "Usage plan for limiting request rate"
  api_stages {
    api_id = aws_api_gateway_rest_api.api.id
    stage  = aws_api_gateway_deployment.api_deployment.stage_name
  }

  throttle_settings {
    rate_limit  = 21
    burst_limit = 210
  }
}




