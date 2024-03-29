#
## Related to CloudWatch Alarms 
#

locals {
  # notification for email  
  notification = {
    email = {
      addresses = var.notification_emails
    }
    slack = {
      channel     = var.slack_notification_channel
      webhook_url = data.aws_secretsmanager_secret_version.slack.secret_string
    }
  }
}

#
## We need to lookup the value from secret manager
#
data "aws_secretsmanager_secret" "slack" {
  name = var.slack_notification_secret_name
}

#
## Retrieve the current version of the secret
#
data "aws_secretsmanager_secret_version" "slack" {
  secret_id = data.aws_secretsmanager_secret.slack.id
}

## Provision the CIS AWS Foundations CloudWatch Alarms
module "alarm_baseline" {
  count   = var.enable_cis_alarms ? 1 : 0
  source  = "appvia/alarm-baseline/aws"
  version = "0.0.2"

  enable_iam_changes                  = false
  enable_mfa_console_signin_allow_sso = true
  enable_organizations_changes        = false
  enable_cis_alarms                   = local.notification
  tags                                = var.tags
}

