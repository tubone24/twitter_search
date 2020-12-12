resource "aws_secretsmanager_secret" "twitter_search_secret" {
  name                = "twitter_api_token"
  description         = "Twitter API Token"
}