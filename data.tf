
## Find the aws organization
data "aws_organizations_organization" "current" {}

## Find the current account 
data "aws_caller_identity" "current" {}

## Find the current region 
data "aws_region" "current" {}

## We need to lookup the value from secret manager
data "aws_secretsmanager_secret" "notification" {
  count = var.notification_secret_name != "" ? 1 : 0
  name  = var.notification_secret_name
}

## Retrieve the current version of the secret
data "aws_secretsmanager_secret_version" "notification" {
  count     = var.notification_secret_name != "" ? 1 : 0
  secret_id = data.aws_secretsmanager_secret.notification[0].id
}

