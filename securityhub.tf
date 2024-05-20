
## Craft an IAM policy document to allow the lambda function to assume the role 
data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

## Craft and IAM polciy perform access to publish messages to the SNS topic 
data "aws_iam_policy_document" "securityhub_notifications_policy" {
  count = var.enable_securityhub_alarms ? 1 : 0

  statement {
    sid       = "AllowPublish"
    actions   = ["sns:Publish"]
    effect    = "Allow"
    resources = [module.securityhub_notifications[0].sns_topic_arn]
  }
}

## Create the lambda function package from the source code
data "archive_file" "securityhub_lambda_package" {
  count = var.enable_securityhub_alarms ? 1 : 0

  type        = "zip"
  source_file = "${path.module}/assets/functions/securityhub.py"
  output_path = "./builds/securityhub-findings-forwarder.zip"
}

## Provision the notifications to forward the security hub findings to the messaging channel 
module "securityhub_notifications" {
  count   = var.enable_securityhub_alarms ? 1 : 0
  source  = "appvia/notifications/aws"
  version = "0.1.5"

  allowed_aws_services = ["events.amazonaws.com", "lambda.amazonaws.com"]
  create_sns_topic     = true
  email                = local.email
  slack                = local.slack
  sns_topic_name       = var.securityhub_sns_topic_name
  tags                 = var.tags

  providers = {
    aws = aws.audit
  }
}

## Provision an IAM role for the lambda function to run under 
resource "aws_iam_role" "securityhub_lambda_role" {
  count = var.enable_securityhub_alarms ? 1 : 0

  name               = var.securityhub_lambda_role_name
  tags               = var.tags
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json

  inline_policy {
    name   = "lza-securityhub-lambda-policy"
    policy = data.aws_iam_policy_document.securityhub_notifications_policy[0].json
  }

  provider = aws.audit
}

## Attach the managed permission to allow lambda to send logs to cloudwatch 
resource "aws_iam_role_policy_attachment" "securityhub_lambda_cloudwatch_logs" {
  count = var.enable_securityhub_alarms ? 1 : 0

  role       = aws_iam_role.securityhub_lambda_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"

  provider = aws.audit
}

## Provision the lamda function to forward the security hub findings to the messaging channel  
# tfsec:ignore:aws-lambda-enable-tracing
resource "aws_lambda_function" "securityhub_lambda_function" {
  count = var.enable_securityhub_alarms ? 1 : 0

  filename         = "./builds/securityhub-findings-forwarder.zip"
  function_name    = var.securityhub_lambda_function_name
  handler          = "lambda_function.lambda_handler"
  role             = aws_iam_role.securityhub_lambda_role[0].arn
  runtime          = var.securityhub_lambda_runtime
  source_code_hash = data.archive_file.securityhub_lambda_package[0].output_base64sha256
  tags             = var.tags
  timeout          = 5

  environment {
    variables = {
      "SNS_TOPIC_ARN" = module.securityhub_notifications[0].sns_topic_arn
    }
  }

  depends_on = [data.archive_file.securityhub_lambda_package]
  provider   = aws.audit
}

## Provision the event bridge rule to capture security hub findings, of a specific severities
resource "aws_cloudwatch_event_rule" "security_hub_findings" {
  count       = var.enable_securityhub_alarms ? 1 : 0
  name        = var.securityhub_event_bridge_rule_name
  description = "Capture Security Hub findings of a specific severities and publish to the SNS topic (LZA)"
  event_pattern = jsonencode({
    detail = {
      findings = {
        Compliance = {
          Status = ["FAILED"]
        },
        RecordState = ["ACTIVE"],
        Severity = {
          Label = var.securityhub_severity_filter
        },
        Workflow = {
          Status = ["NEW"]
        }
      }
    },
    detail-type = ["Security Hub Findings - Imported"],
    source      = ["aws.securityhub"]
  })
  tags = var.tags

  provider = aws.audit
}


## Provision a target to the event bridge rule, to publish messages to the SNS topic 
resource "aws_cloudwatch_event_target" "security_hub_findings_target" {
  count = var.enable_securityhub_alarms ? 1 : 0

  arn       = aws_lambda_function.securityhub_lambda_function.arn
  rule      = aws_cloudwatch_event_rule.security_hub_findings[0].name
  target_id = "security_hub_findings_target"

  provider = aws.audit
}

