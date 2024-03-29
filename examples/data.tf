## Retrieve the current AWS account ID and ARN 
data "aws_caller_identity" "current" {}
## Retrieve the current AWS IAM session context
data "aws_iam_session_context" "current" {
  arn = data.aws_caller_identity.current.arn
}

## Retrieve the current AWS Organizations organization
data "aws_organizations_organization" "current" {}
## Retrieve all the active accounts under the current AWS Organizations organization
data "aws_organizations_organizational_unit_descendant_accounts" "this" {
  parent_id = data.aws_organizations_organization.this.roots[0].id
}
