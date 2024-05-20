
## Find the aws organization
data "aws_organizations_organization" "current" {}

## Find the current account 
data "aws_caller_identity" "current" {}

## Find the current region 
data "aws_region" "current" {}

## Find the kms for the cloudwatch logs 
data "aws_kms_alias" "cloudwatch_logs" {
  count = local.enable_log_group_encryption != "" ? 1 : 0

  name = var.securityhub_lambda_log_group_kms_alias
}

