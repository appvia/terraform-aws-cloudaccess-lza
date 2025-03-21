
## Provision the notifications sns topics and destinations
#trivy:ignore:AVD-AWS-0057 - (https://avd.aquasec.com/misconfig/aws/iam/avd-aws-0057)
#trivy:ignore:AVD-DS-0002
#trivy:ignore:AVD-DS-0013
#trivy:ignore:AVD-DS-0015
#trivy:ignore:AVD-DS-0026
module "notifications" {
  source  = "appvia/notifications/aws"
  version = "2.0.1"

  allowed_aws_services = ["lambda.amazonaws.com", "events.amazonaws.com"]
  create_sns_topic     = true
  email                = local.notifications_email
  enable_slack         = local.enable_slack_notifications
  enable_teams         = local.enable_teams_notifications
  slack                = local.notifications_slack
  sns_topic_name       = local.notifications_sns_topic_name
  tags                 = local.tags
  teams                = local.notifications_teams

  providers = {
    aws = aws.management
  }
}

## Provision the CIS AWS Foundations CloudWatch Alarms
module "alarm_baseline" {
  count   = var.enable_cis_alarms ? 1 : 0
  source  = "appvia/alarm-baseline/aws"
  version = "0.3.0"

  enable_iam_changes                  = false
  enable_mfa_console_signin_allow_sso = true
  enable_organizations_changes        = false
  sns_topic_arn                       = module.notifications.sns_topic_arn
  tags                                = local.tags

  providers = {
    aws = aws.management
  }
}
