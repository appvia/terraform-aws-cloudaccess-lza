#
## Related to CloudWatch Alarms 
#

locals {
  slack_notification = var.enable_slack_notifications ? {
    slack = {
      channel     = jsondecode(data.aws_secretsmanager_secret_version.notification[0].secret_string).channel
      webhook_url = jsondecode(data.aws_secretsmanager_secret_version.notification[0].secret_string).webhook_url
    }
  } : {}

  teams_notification = var.enable_teams_notifications ? {
    teams = {
      webhook_url = jsondecode(data.aws_secretsmanager_secret_version.notification[0].secret_string).webhook_url
    }
  } : {}

  notifications = merge(
    {
      email = {
        addresses = var.notification_emails
      }
    },
    local.slack_notification,
    local.teams_notification
  )
}

#
## We need to lookup the value from secret manager
#
data "aws_secretsmanager_secret" "notification" {
  count = var.notification_secret_name != "" ? 1 : 0
  name  = var.notification_secret_name
}

#
## Retrieve the current version of the secret
#
data "aws_secretsmanager_secret_version" "notification" {
  count     = var.notification_secret_name != "" ? 1 : 0
  secret_id = data.aws_secretsmanager_secret.notification[0].id
}

## Provision the CIS AWS Foundations CloudWatch Alarms
module "alarm_baseline" {
  count  = var.enable_cis_alarms ? 1 : 0
  source = "github.com/appvia/terraform-aws-alarm-baseline?ref=main"

  enable_iam_changes                  = false
  enable_mfa_console_signin_allow_sso = true
  enable_organizations_changes        = false
  notification                        = local.notifications
  tags                                = var.tags
}

