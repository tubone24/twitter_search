#####################################
# CloudWatch LogGroup
#####################################
resource "aws_cloudwatch_log_group" "twitter_search_log_group" {
  name = "/aws/lambda/twitter_search"
}

#####################################
# CloudWatch MetricFilter
#####################################
resource "aws_cloudwatch_log_metric_filter" "twitter_search_log_group_error_metric" {
  name           = "error"
  pattern        = "\"ERROR :\""
  log_group_name = aws_cloudwatch_log_group.twitter_search_log_group.name

  metric_transformation {
    name      = "error_twitter_search"
    namespace = "LogMetrics"
    value     = "1"
  }
}

resource "aws_cloudwatch_log_metric_filter" "twitter_search_log_group_warn_metric" {
  name           = "warn"
  pattern        = "\"WARN :\""
  log_group_name = aws_cloudwatch_log_group.twitter_search_log_group.name

  metric_transformation {
    name      = "warn_twitter_search"
    namespace = "LogMetrics"
    value     = "1"
  }
}

resource "aws_cloudwatch_event_rule" "twitter_search_rule" {
  name                = "twitter_search_cron_rule"
  description         = "Fires every 1 hour"
  schedule_expression = "cron(0 * ? * * *)"
}

resource "aws_cloudwatch_event_target" "twitter_search_target" {
  target_id = "twitter_search"
  rule      = "twitter_search_cron_rule"
  depends_on  = [aws_cloudwatch_event_rule.twitter_search_rule]
  arn       = aws_lambda_alias.twitter_search_alias.arn
}