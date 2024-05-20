
## Draft a SNS resource policy allowing event bridge to publish messages to the SNS topic 
data "aws_iam_policy_document" "sns_policy" {
  statement {
    actions = ["sns:Publish"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
    resources = ["*"]
  }
}

## Provision a SNS topic used to receive messages from the event bridge rule 
module "security_hub_alerts" {
  count   = var.enable_securityhub_alarms ? 1 : 0
  source  = "terraform-aws-modules/sns/aws"
  version = "6.0.1"

  name                          = var.securityhub_sns_topic_name
  source_topic_policy_documents = [data.aws_iam_policy_document.sns_policy.json]
  tags                          = var.tags

  providers = {
    aws = aws.audit
  }
}

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

## Provision a target to the event bridge rule, to publish messages to the SNS topic 
resource "aws_cloudwatch_event_target" "security_hub_findings_target" {
  count = var.enable_securityhub_alarms ? 1 : 0

  arn       = module.security_hub_alerts[0].topic_arn
  rule      = aws_cloudwatch_event_rule.security_hub_findings[0].name
  target_id = "security_hub_findings_target"

  provider = aws.audit
}

## Provision the notifications to forward the security hub findings to the messaging channel 
module "notifications" {
  count   = var.enable_securityhub_alarms ? 1 : 0
  source  = "appvia/notifications/aws"
  version = "0.1.4"

  allowed_aws_services = ["events.amazonaws.com"]
  create_sns_topic     = false
  email                = local.email
  slack                = local.slack
  sns_topic_name       = module.security_hub_alerts[0].topic_name
  tags                 = var.tags

  providers = {
    aws = aws.audit
  }
}
