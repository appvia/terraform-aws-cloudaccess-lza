
## Provision the CIS AWS Foundations CloudWatch Alarms
module "alarm_baseline" {
  count   = var.enable_cis_alarms ? 1 : 0
  source = "github.com/appvia/terraform-aws-alarm-baseline.git?ref=20e1354e13dc1b410566834dad9134fa8c3857b5"

  accounts_id_to_name_parameter_arn   = var.accounts_id_to_name_parameter_arn
  cloudwatch_log_group_retention      = 3
  create_sns_topic                    = true
  enable_iam_changes                  = false
  enable_mfa_console_signin_allow_sso = true
  enable_organizations_changes        = false
  identity_center_role                = var.cloudwatch_identity_center_role
  identity_center_start_url           = var.identity_center_start_url
  notification                        = local.notifications
  tags                                = var.tags

  providers = {
    aws = aws.management
  }
}
