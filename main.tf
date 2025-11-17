
## Provision the notifications sns topics and destinations
module "notifications" {
  source  = "appvia/notify/aws"
  version = "0.0.7"

  allowed_aws_services = [
    "budgets.amazonaws.com",
    "cloudwatch.amazonaws.com",
    "cloudtrail.amazonaws.com",
    "events.amazonaws.com",
  ]

  create_sns_topic = true
  email            = local.notifications_email
  slack            = local.notifications_slack
  sns_topic_name   = local.notifications_sns_topic_name
  tags             = local.tags
  teams            = local.notifications_teams

  providers = {
    aws = aws.management
  }
}

## Provision the CIS AWS Foundations CloudWatch Alarms
module "alarm_baseline" {
  count   = var.enable_cis_alarms ? 1 : 0
  source  = "appvia/alarm-baseline/aws"
  version = "0.3.3"

  enable_iam_changes                             = false
  enable_mfa_console_signin_allow_sso            = true
  enable_organizations_changes                   = false
  sns_topic_arn                                  = module.notifications.sns_topic_arn
  tags                                           = local.tags
  unauthorized_api_calls_extra_excluded_services = var.unauthorized_api_calls_extra_excluded_services

  providers = {
    aws = aws.management
  }
}
