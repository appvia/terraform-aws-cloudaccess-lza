
locals {
  ## The account id for the audit account
  audit_account_id = var.aws_accounts.audit_account_id
  ## The account id of the management account
  management_account_id = data.aws_organizations_organization.current.master_account_id
  ## The current region name
  region = data.aws_region.current.name
  ## The current account id
  account_id = data.aws_caller_identity.current.account_id

  ## The name of the aws support stackset
  aws_support_stack_name = "LZA-IAM-Support-Role"
  ## The capabilities required for the aws support stackset
  aws_support_capabilities = ["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM"]
  ## The parameters for the aws support stackset
  aws_support_parameters = {
    "RoleName" = var.aws_support_role_name
  }

  ## Is the log group used the lambda function encrypted
  enable_log_group_encryption = var.securityhub_lambda_log_group_kms_alias != ""

  ## Indicates if the notifications for slack are enabled
  enable_slack_notifications = var.notifications.slack != null
  ## Indicates if the notifications for email are enabled
  enable_email_notifications = length(var.notifications.email.addresses) > 0

  ## The configuration for the slack notification
  slack = local.enable_slack_notifications ? {
    lambda_name = "lza-ca-notifications-slack"
    webhook_url = var.notifications.slack.webhook_url
  } : null

  email = {
    addresses = var.notifications.email.addresses
  }

  notifications = {
    email = (local.enable_email_notifications ? local.email : null)
    slack = (local.enable_slack_notifications ? local.slack : null)
  }
}
