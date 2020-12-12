#####################################
#Common Settings
#####################################
env                               = ""
account_id                        = ""
region                            = "ap-northeast-1"
profile_name                      = ""

#####################################
# Role for Lambda
#####################################
lambda_role_arn                   = ""
lambda_memory                     = "1024"
lambda_sg_ids                     = ["sg-"]
lambda_subnet_ids                 = ["subnet-", "subnet-"]

lambda_variable_log_level                       = "DEBUG"
lambda_variable_secret_name                     = ""
lambda_variable_keyword                         = ""
lambda_variable_slack_webhook_url               = ""