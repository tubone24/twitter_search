#####################################
#Common Settings
#####################################
variable "env" {}
variable "account_id" {}
variable "region" {}
variable "profile_name" {}
variable "publish" {}

######################################
## Setting for Lambda
######################################
variable "lambda_role_arn" {}
variable "lambda_memory" {}
variable "lambda_sg_ids" { type = list(string) }
variable "lambda_subnet_ids" { type = list(string) }
variable "lambda_variable_log_level" {}
variable "lambda_variable_secret_name" {}
variable "lambda_variable_keyword" {}
variable "lambda_variable_slack_webhook_url" {}
