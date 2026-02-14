
locals {
  ## The account id for the audit account
  audit_account_id = var.aws_accounts.audit_account_id
  ## The account id of the management account
  management_account_id = data.aws_organizations_organization.current.master_account_id
  ## The current region name
  region = data.aws_region.current.region
  ## The current account id
  account_id = data.aws_caller_identity.current.account_id

  ## The name of the aws support stackset
  aws_support_stack_name = var.aws_support_stack_name
  ## The capabilities required for the aws support stackset
  aws_support_capabilities = ["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM"]
  ## The parameters for the aws support stackset
  aws_support_parameters = {
    "RoleName" = var.aws_support_role_name
  }

  ## The tags to apply to all resources
  tags = var.tags

  ## The configuration for slack notifications
  notifications_slack = can(var.notifications.slack.webhook_url) ? {
    lambda_name        = "lza-slack-ca-notifications-${local.region}"
    lambda_description = "Lambda function to forward notifications to slack to an SNS topic"
    webhook_url        = var.notifications.slack.webhook_url
  } : null

  ## The configuration for ms team notifications
  notifications_teams = can(var.notifications.teams.webhook_url) ? {
    lambda_name        = "lza-teams-ca-notifications-${local.region}"
    lambda_description = "Lambda function to forward notifications to teams to an SNS topic"
    webhook_url        = var.notifications.teams.webhook_url
  } : null

  ## The configuration for email notifications
  notifications_email = can(var.notifications.email.addresses) ? {
    addresses = var.notifications.email.addresses
  } : null

  ## Name of the sns topic for notifications for budget and cost alerts
  notifications_sns_topic_name = "lza-cloudaccess-notifications"
}
