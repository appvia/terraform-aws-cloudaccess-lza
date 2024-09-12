
## Provision the CIS AWS Foundations CloudWatch Alarms
module "alarm_baseline" {
  count   = var.enable_cis_alarms ? 1 : 0
  source  = "appvia/alarm-baseline/aws"
  version = "0.2.4"

  create_sns_topic                    = true
  enable_iam_changes                  = false
  enable_mfa_console_signin_allow_sso = true
  enable_organizations_changes        = false
  notification                        = local.notifications
  tags                                = var.tags
  accounts_id_to_name                 = var.accounts_id_to_name
  cloudwatch_log_group_retention      = 3

  providers = {
    aws = aws.management
  }
}

