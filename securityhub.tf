
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
# tfsec:ignore:aws-iam-no-policy-wildcards
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
  version = "2.0.0"

  accounts_id_to_name            = var.accounts_id_to_name
  allowed_aws_services           = ["events.amazonaws.com", "lambda.amazonaws.com"]
  cloudwatch_log_group_retention = 3
  create_sns_topic               = true
  email                          = local.email
  enable_slack                   = true
  identity_center_role           = var.security_hub_identity_center_role
  identity_center_start_url      = var.identity_center_start_url
  slack                          = local.slack
  sns_topic_name                 = var.securityhub_sns_topic_name
  tags                           = var.tags

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

  provider = aws.audit
}

## Assign the inline policy to the lambda role
resource "aws_iam_role_policy" "securityhub_lambda_role_policy" {
  count = var.enable_securityhub_alarms ? 1 : 0

  name   = "lza-securityhub-lambda-policy"
  policy = data.aws_iam_policy_document.securityhub_notifications_policy[0].json
  role   = aws_iam_role.securityhub_lambda_role[0].name

  provider = aws.audit
}

## Assign the inline policy to the lambda role
resource "aws_iam_role_policy" "securityhub_lambda_logs_policy" {
  count = var.enable_securityhub_alarms ? 1 : 0

  name   = "lza-securityhub-lambda-logs-policy"
  policy = data.aws_iam_policy_document.securityhub_lambda_cloudwatch_logs_policy.json
  role   = aws_iam_role.securityhub_lambda_role[0].name

  provider = aws.audit
}

## Provision a cloudwatch log group to capture the logs from the lambda function
resource "aws_cloudwatch_log_group" "securityhub_lambda_log_group" {
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
  count = var.enable_securityhub_alarms ? 1 : 0

  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.securityhub_lambda_function[0].function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.securityhub_findings[0].arn
  statement_id  = "AllowExecutionFromEventBridge"

  provider = aws.audit
}

## Provision the event bridge rule to capture security hub findings, of a specific severities
resource "aws_cloudwatch_event_rule" "securityhub_findings" {
  count = var.enable_securityhub_alarms ? 1 : 0

  name        = var.securityhub_event_bridge_rule_name
  description = "Capture Security Hub findings of a specific severities and publish to the SNS topic (LZA)"
  tags        = var.tags

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
