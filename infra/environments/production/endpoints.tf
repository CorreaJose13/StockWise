module "metrics_endpoint" {
  source             = "../../modules/lambda_api_integration/"
  lambda_source_path = "${path.module}/../../../backend/internal/functions/metrics/main.go"
  s3_bucket          = module.lambda_bucket.bucket
  lambda_role        = module.lambda_role.arn
  timeout            = 10
  memory_size        = 128
  log_retention_days = 7

  env_vars = { DB_URL = var.DB_URL }

  endpoint_name     = "metrics"
  rest_api_id       = module.api_gateway.id
  rest_api_exec_arn = module.api_gateway.execution_arn
  parent_id         = module.api_gateway.root_resource_id
  endpoint_path     = "metrics"
  http_method       = "GET"
  stage             = var.stage
}

module "analyze_endpoint" {
  source             = "../../modules/lambda_api_integration/"
  lambda_source_path = "${path.module}/../../../backend/internal/functions/analysis/main.go"
  s3_bucket          = module.lambda_bucket.bucket
  lambda_role        = module.lambda_role.arn
  timeout            = 10
  memory_size        = 128
  log_retention_days = 7
  env_vars           = { DB_URL = var.DB_URL }

  endpoint_name     = "analyze"
  rest_api_id       = module.api_gateway.id
  rest_api_exec_arn = module.api_gateway.execution_arn
  parent_id         = module.api_gateway.root_resource_id
  endpoint_path     = "analyze"
  http_method       = "GET"
  stage             = var.stage
}

module "stocks_endpoint" {
  source             = "../../modules/lambda_api_integration/"
  lambda_source_path = "${path.module}/../../../backend/internal/functions/stocks/main.go"
  s3_bucket          = module.lambda_bucket.bucket
  lambda_role        = module.lambda_role.arn
  timeout            = 12
  memory_size        = 128
  log_retention_days = 7
  env_vars           = { DB_URL = var.DB_URL }

  endpoint_name     = "stocks"
  rest_api_id       = module.api_gateway.id
  rest_api_exec_arn = module.api_gateway.execution_arn
  parent_id         = module.api_gateway.root_resource_id
  endpoint_path     = "stocks"
  http_method       = "GET"
  stage             = var.stage
}

module "chart_endpoint" {
  source             = "../../modules/lambda_api_integration/"
  lambda_source_path = "${path.module}/../../../backend/internal/functions/chart/main.go"
  s3_bucket          = module.lambda_bucket.bucket
  lambda_role        = module.lambda_role.arn
  timeout            = 12
  memory_size        = 128
  log_retention_days = 7
  env_vars           = { API_KEY = var.API_KEY }

  endpoint_name     = "chart"
  rest_api_id       = module.api_gateway.id
  rest_api_exec_arn = module.api_gateway.execution_arn
  parent_id         = module.api_gateway.root_resource_id
  endpoint_path     = "chart"
  http_method       = "GET"
  stage             = var.stage
}

// TO DO: Improve redeployment strategy
resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = module.api_gateway.id

  depends_on = [module.api_gateway, module.metrics_endpoint, module.analyze_endpoint, module.stocks_endpoint]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "stage" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = module.api_gateway.id
  stage_name    = var.stage
}

output "invoke_url" {
  value = aws_api_gateway_stage.stage.invoke_url
}
