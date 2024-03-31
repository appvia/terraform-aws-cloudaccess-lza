## Retrieve the current AWS account ID and ARN 
data "aws_caller_identity" "current" {}
## Retrieve the current AWS IAM session context
data "aws_iam_session_context" "current" {
  arn = data.aws_caller_identity.current.arn
}
