terraform {
  backend "s3" {
    key    = "terraform/twitter_search.tfstate"
    region = "ap-northeast-1"
  }
}

data "terraform_remote_state" "remote_state_lambda_layer" {
  backend = "s3"
  config = {
    bucket = "twitter-search-${var.env}-tf"
    key    = "env:/${var.profile_name}/terraform/lambda_layer.tfstate"
    region = "ap-northeast-1"
    profile = var.profile_name
  }
}