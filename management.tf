#
## Permissions related to the management account
#

locals {
  management_account_id = var.aws_accounts.management_account_id
}

# tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_iam_policy" "user_management" {
  name        = "lza-user-management"
  description = "Provides the permissions to manage users in identity center"
  policy      = file("${path.module}/assets/policies/user-management.json")
  provider    = aws.management
  tags        = var.tags
}

# tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_iam_policy" "code_contributor" {
  name        = "lza-code-contributor"
  description = "Provides the permissions to validate the landing zone code"
  policy      = file("${path.module}/assets/policies/code-contributor.json")
  provider    = aws.management
  tags        = var.tags
}

# tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_iam_policy" "code_release" {
  name        = "lza-code-release"
  description = "Provides the permissions to release the landing zone code"
  policy      = file("${path.module}/assets/policies/code-release.json")
  provider    = aws.management
  tags        = var.tags
}

# tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_iam_policy" "costs_admin" {
  name        = "lza-costs-admin"
  description = "Provides the permissions to manage costs in the management account"
  policy      = file("${path.module}/assets/policies/costs-admin.json")
  provider    = aws.management
  tags        = var.tags
}

# tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_iam_policy" "costs_viewer" {
  name        = "lza-costs-viewer"
  description = "Provides the permissions to view costs in the management account"
  policy      = file("${path.module}/assets/policies/costs-viewer.json")
  provider    = aws.management
  tags        = var.tags
}

## Used to manage identity center
module "management_sso_identity" {
  count   = var.repositories.identity != null ? 1 : 0
  source  = "appvia/oidc/aws//modules/role"
  version = "1.1.0"

  name                = var.repositories.identity.role_name
  common_provider     = var.scm_name
  description         = "Role is used to manage the identity center"
  permission_boundary = var.permissive_permissions_boundary_name
  repository          = var.repositories.identity.url
  tags                = var.tags

  read_only_policy_arns = [
    "arn:aws:iam::aws:policy/AWSSSODirectoryReadOnly",
    "arn:aws:iam::aws:policy/AWSSSOReadOnly",
    "arn:aws:iam::aws:policy/IAMReadOnlyAccess",
    "arn:aws:iam::aws:policy/ReadOnlyAccess"
  ]

  read_write_policy_arns = [
    "arn:aws:iam::${local.management_account_id}:policy/${aws_iam_policy.user_management.name}",
    "arn:aws:iam::aws:policy/AWSSSODirectoryReadOnly",
    "arn:aws:iam::aws:policy/AWSSSOReadOnly",
    "arn:aws:iam::aws:policy/ReadOnlyAccess",
    "arn:aws:iam::aws:policy/IAMFullAccess",
  ]

  providers = {
    aws = aws.management
  }

  depends_on = [
    module.default_boundary,
    module.permissive_boundary
  ]
}

## Used to manage and deploy the landing zone
module "management_landing_zone" {
  count   = var.repositories.accelerator != null ? 1 : 0
  source  = "appvia/oidc/aws//modules/role"
  version = "1.1.0"

  name                = var.repositories.accelerator.role_name
  common_provider     = var.scm_name
  description         = "Used to manage and deploy the lanzing zone configuration"
  permission_boundary = var.default_permissions_boundary_name
  repository          = var.repositories.accelerator.url
  tags                = var.tags

  read_only_policy_arns = [
    "arn:aws:iam::${local.management_account_id}:policy/${aws_iam_policy.code_contributor.name}",
  ]

  read_write_policy_arns = [
    "arn:aws:iam::${local.management_account_id}:policy/${aws_iam_policy.code_release.name}",
  ]

  providers = {
    aws = aws.management
  }

  depends_on = [
    module.default_boundary,
    module.permissive_boundary
  ]
}
