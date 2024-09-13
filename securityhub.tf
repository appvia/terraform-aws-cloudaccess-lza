
## Craft an IAM policy document to allow the lambda function to assume the role 
data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    sid     = "AllowLambdaAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

## Craft an IAM polciy to push logs to cloudwatch log group 
# See also the following AWS managed policy: AWSLambdaBasicExecutionRole
data "aws_iam_policy_document" "securityhub_lambda_cloudwatch_logs_policy" {
  statement {
    sid    = "AllowLogging"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }
}

## Craft an IAM polciy perform access to publish messages to the SNS topic 
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
  source_file = "${path.module}/assets/functions/lambda_function.py"
  output_path = "./builds/securityhub-findings-forwarder.zip"
}

## Provision the notifications to forward the security hub findings to the messaging channel 
module "securityhub_notifications" {
  count   = var.enable_securityhub_alarms ? 1 : 0
  source  = "appvia/notifications/aws"
  version = "1.0.4"

  allowed_aws_services = ["events.amazonaws.com", "lambda.amazonaws.com"]
  create_sns_topic     = true
  sns_topic_name       = var.securityhub_sns_topic_name

  email = local.email

  cloudwatch_log_group_retention = 3
  enable_slack                   = true
  slack                          = local.slack

  tags                      = var.tags
  accounts_id_to_name       = var.accounts_id_to_name
  identity_center_start_url = var.identity_center_start_url
  identity_center_role      = var.identity_center_role

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

  inline_policy {
    name   = "lza-securityhub-lambda-logs-policy"
    policy = data.aws_iam_policy_document.securityhub_lambda_cloudwatch_logs_policy.json
  }

  provider = aws.audit
}

## Provision a cloudwatch log group to capture the logs from the lambda function 
resource "aws_cloudwatch_log_group" "securityhub_lambda_log_group" {
  kms_key_id        = local.enable_log_group_encryption ? data.aws_kms_alias.securityhub_kms_key[0].id : null
  log_group_class   = "STANDARD"
  name              = "/aws/lambda/${var.securityhub_lambda_function_name}"
  retention_in_days = 3
  tags              = var.tags

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

  depends_on = [
    data.archive_file.securityhub_lambda_package,
    aws_cloudwatch_log_group.securityhub_lambda_log_group,
  ]

  provider = aws.audit
}

## Allow eventbridge to invoke the lambda function
resource "aws_lambda_permission" "securityhub_event_bridge" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.securityhub_lambda_function[0].function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.securityhub_findings[0].arn
  statement_id  = "AllowExecutionFromEventBridge"

  provider = aws.audit
}

## Provision the event bridge rule to capture security hub findings, of a specific severities
resource "aws_cloudwatch_event_rule" "securityhub_findings" {
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

  arn       = aws_lambda_function.securityhub_lambda_function[0].arn
  rule      = aws_cloudwatch_event_rule.securityhub_findings[0].name
  target_id = "security_hub_findings_target"

  provider = aws.audit
}
