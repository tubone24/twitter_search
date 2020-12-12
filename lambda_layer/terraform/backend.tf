terraform {
  backend "s3" {
    key    = "terraform/lambda_layer.tfstate"
    region = "ap-northeast-1"
  }
}

