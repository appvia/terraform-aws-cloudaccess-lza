#
## Permissions related to the management account
#

# tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_iam_policy" "user_management" {
  name        = "lza-user-management"
  description = "Provides the permissions to manage users in identity center"
  policy      = file("${path.module}/assets/policies/user-management.json")
  tags        = var.tags

  provider = aws.management
}

# tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_iam_policy" "code_contributor" {
  name        = "lza-code-contributor"
  description = "Provides the permissions to validate the landing zone code"
  policy      = file("${path.module}/assets/policies/code-contributor.json")
  tags        = var.tags

  provider = aws.management
}

# tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_iam_policy" "code_release" {
  name        = "lza-code-release"
  description = "Provides the permissions to release the landing zone code"
  policy      = file("${path.module}/assets/policies/code-release.json")
  tags        = var.tags

  provider = aws.management
}

# tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_iam_policy" "costs_admin" {
  name        = "lza-costs-admin"
  description = "Provides the permissions to manage costs in the management account"
  policy      = file("${path.module}/assets/policies/costs-admin.json")
  tags        = var.tags

  provider = aws.management
}

# tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_iam_policy" "costs_viewer" {
  name        = "lza-costs-viewer"
  description = "Provides the permissions to view costs in the management account"
  policy      = file("${path.module}/assets/policies/costs-viewer.json")
  tags        = var.tags

  provider = aws.management
}

## Used to manage identity center
module "management_sso_identity" {
  count   = var.repositories.identity != null ? 1 : 0
  source  = "appvia/oidc/aws//modules/role"
  version = "1.2.2"

  name                = var.repositories.identity.role_name
  common_provider     = var.scm_name
  description         = "Used to manage the identity center permissionsets and assignments"
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

  read_write_inline_policies = {
    "additional" = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "sso:DeleteInlinePolicyFromPermissionSet",
            "sso:PutInlinePolicyToPermissionSet",
          ]
          Effect   = "Allow"
          Resource = "*"
        },
      ]
    })
  }

  providers = {
    aws = aws.management
  }

  depends_on = [
    module.permissive_boundary,
  ]
}

## Used to manage and deploy the landing zone
module "management_landing_zone" {
  count   = var.repositories.accelerator != null ? 1 : 0
  source  = "appvia/oidc/aws//modules/role"
  version = "1.2.2"

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
  ]
}

# tfsec:ignore:aws-iam-no-policy-wildcards
module "cost_management" {
  count   = var.repositories.cost_management != null ? 1 : 0
  source  = "appvia/oidc/aws//modules/role"
  version = "1.2.2"

  name                    = var.repositories.cost_management.role_name
  description             = "Used to provision a collection of cost controls and notifications"
  repository              = var.repositories.cost_management.url
  tags                    = var.tags
  permission_boundary_arn = aws_iam_policy.cost_iam_boundary.arn

  read_only_inline_policies = {
    CostManagement = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "ce:Describe*",
            "ce:Get*",
            "logs:Describe*",
            "logs:Get*",
            "logs:List*",
            "secretsmanager:DescribeSecret",
            "secretsmanager:GetResourcePolicy",
            "secretsmanager:GetSecretValue",
            "sns:Describe*",
            "sns:Get*",
            "sns:List*",
          ]
          Effect   = "Allow"
          Resource = "*"
        },
      ]
    })
  }

  read_write_inline_policies = {
    CostManagement = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "ce:CreateAnomalyMonitor",
            "ce:CreateAnomalySubscription",
            "ce:DeleteAnomalyMonitor",
            "ce:DeleteAnomalySubscription",
            "ce:Describe*",
            "ce:Get*",
            "logs:CreateLogGroup",
            "logs:DeleteLogGroup",
            "logs:Describe*",
            "logs:Get*",
            "logs:List*",
            "logs:TagResource",
            "secretsmanager:DescribeSecret",
            "secretsmanager:GetResourcePolicy",
            "secretsmanager:GetSecretValue",
          ]
          Effect   = "Allow"
          Resource = "*"
        },
      ]
    })
  }

  read_only_policy_arns = [
    "arn:aws:iam::aws:policy/AWSBillingConductorReadOnlyAccess",
    "arn:aws:iam::aws:policy/AWSBillingReadOnlyAccess",
    "arn:aws:iam::aws:policy/AWSLambda_ReadOnlyAccess",
    "arn:aws:iam::aws:policy/AmazonSNSReadOnlyAccess",
    "arn:aws:iam::aws:policy/CostOptimizationHubReadOnlyAccess",
    "arn:aws:iam::aws:policy/IAMReadOnlyAccess",
  ]

  read_write_policy_arns = [
    "arn:aws:iam::${local.management_account_id}:policy/${aws_iam_policy.costs_admin.name}",
    "arn:aws:iam::aws:policy/AWSBillingReadOnlyAccess",
    "arn:aws:iam::aws:policy/AWSLambda_FullAccess",
    "arn:aws:iam::aws:policy/AmazonSNSFullAccess",
    "arn:aws:iam::aws:policy/CostOptimizationHubAdminAccess",
    "arn:aws:iam::aws:policy/IAMFullAccess",
    "arn:aws:iam::aws:policy/job-function/Billing",
  ]

  providers = {
    aws = aws.management
  }
}
