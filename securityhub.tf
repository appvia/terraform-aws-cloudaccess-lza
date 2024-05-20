
## Provision the event bridge rule to capture security hub findings, of a specific severities
resource "aws_cloudwatch_event_rule" "security_hub_findings" {
  count       = var.enable_securityhub_alarms ? 1 : 0
  name        = var.securityhub_event_bridge_rule_name
  description = "Capture Security Hub findings of a specific severities and publish to the SNS topic (LZA)"
  event_pattern = jsonencode({
    source = ["aws.securityhub"]
    detail = {
      findings = {
        Severity = {
          Label = ["CRITICAL", "HIGH"]
        },
        Workflow = ["NEW"]
      }
    }
  })
  tags = var.tags

  provider = aws.audit
}

## Provision the notifications to forward the security hub findings to the messaging channel 
module "securityhub_notifications" {
  count   = var.enable_securityhub_alarms ? 1 : 0
  source  = "appvia/notifications/aws"
  version = "0.1.5"

  allowed_aws_services = ["events.amazonaws.com", "lambda.amazonaws.com"]
  email                = local.email
  slack                = local.slack
  sns_topic_name       = var.securityhub_sns_topic_name
  tags                 = var.tags

  providers = {
    aws = aws.audit
  }
}

## Provision a target to the event bridge rule, to publish messages to the SNS topic 
resource "aws_cloudwatch_event_target" "security_hub_findings_target" {
  count = var.enable_securityhub_alarms ? 1 : 0

  arn       = module.securityhub_notifications[0].sns_topic_arn
  rule      = aws_cloudwatch_event_rule.security_hub_findings[0].name
  target_id = "security_hub_findings_target"

  provider = aws.audit
}

