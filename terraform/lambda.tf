#####################################
# Lambda
#####################################
resource "aws_lambda_function" "twitter_search" {
  filename         = "../twitter_search.zip"
  function_name    = "twitter_search"
  role             = var.lambda_role_arn
  description      = "Post Slack Tweet search"
  handler          = "lambda_function.lambda_handler"
  timeout          = 300
  runtime          = "python3.7"
  memory_size      = var.lambda_memory
  source_code_hash = data.archive_file.twitter_search_lambda_zip.output_base64sha256
  publish          = var.publish
  layers           = [data.terraform_remote_state.remote_state_lambda_layer.outputs.requests_layer_arn]


  vpc_config {
    security_group_ids = var.lambda_sg_ids
    subnet_ids         = var.lambda_subnet_ids
  }

  environment {
    variables = {
      LOG_LEVEL                   = var.lambda_variable_log_level
      SECRET_NAME                 = var.lambda_variable_secret_name
      KEYWORD                     = var.lambda_variable_keyword
      SLACK_WEBHOOK_URL           = var.lambda_variable_slack_webhook_url
    }
  }
  tracing_config {
    mode = "Active"
  }
}

data "archive_file" "twitter_search_lambda_zip" {
  type        = "zip"
  source_dir  = "../workspace"
  output_path = "../twitter_search.zip"
}

resource "aws_lambda_alias" "twitter_search_alias" {
  name             = "PRD"
  description      = "publish production environment"
  function_name    = aws_lambda_function.twitter_search.arn
  function_version = aws_lambda_function.twitter_search.version
}

resource "aws_lambda_permission" "twitter_search_allow_cloudwatch" {
  statement_id  = "twitter_search_permission"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.twitter_search.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.twitter_search_rule.arn
  qualifier     = aws_lambda_alias.twitter_search_alias.name
}