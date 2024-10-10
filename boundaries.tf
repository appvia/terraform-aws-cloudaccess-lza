#
## Related to provisioning the IAM boundaries used by the pipelines
#

## Craft a permissions boundary that is used by the pipelines we provision here 
# tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "default_permissions_boundary" {
  statement {
    sid       = "AllowAdminAccess"
    effect    = "Allow"
    actions   = ["*"]
    resources = ["*"]
  }

  statement {
    sid    = "DenyPermBoundaryIAMPolicyAlteration"
    effect = "Deny"
    actions = [
      "iam:CreatePolicyVersion",
      "iam:DeletePolicy",
      "iam:DeletePolicyVersion",
      "iam:SetDefaultPolicyVersion"
    ]
    resources = [
      "arn:aws:iam:${local.account_id}:policy/${var.default_permissions_boundary_name}"
    ]
  }

  statement {
    sid       = "ProtectDynamoDBRemoteStateLock"
    effect    = "Deny"
    actions   = ["dynamoDB:DeleteTable"]
    resources = ["arn:aws:dynamodb:*:${local.account_id}:table/${local.account_id}-*-tflock"]
  }

  statement {
    sid       = "ProtectS3RemoteState"
    effect    = "Deny"
    actions   = ["s3:DeleteBucket"]
    resources = ["arn:aws:s3:::${local.account_id}-*-tfstate"]
  }
}

## This is used by pipelines that need to interact with the AWS cost management APIs
# tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_iam_policy" "cost_iam_boundary" {
  name        = var.costs_boundary_name
  description = "IAM boundary used by the cost management pipelines"
  policy = templatefile("${path.module}/assets/boundaries/costs-boundary.json", {
    account_id    = local.management_account_id
    boundary_name = var.costs_boundary_name
  })
  tags = var.tags

  provider = aws.management
}
