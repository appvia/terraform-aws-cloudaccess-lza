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
  policy = templatefile("${path.module}/assets/policies/code-contributor.json", {
    management_account_id = local.management_account_id
    region                = local.region
  })
  tags = var.tags

  provider = aws.management
}

# tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_iam_policy" "code_release" {
  name        = "lza-code-release"
  description = "Provides the permissions to release the landing zone code"
  policy = templatefile("${path.module}/assets/policies/code-release.json", {
    management_account_id = local.management_account_id
    region                = local.region
  })
  tags = var.tags

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

## Provision the iam boundary within the management account
resource "aws_iam_policy" "default_permissions_boundary_management" {
  name        = var.default_permissions_boundary_name
  description = "Used by the LZA pipelines to enforce permissions"
  policy      = data.aws_iam_policy_document.default_permissions_boundary["management"].json
  tags        = var.tags

  provider = aws.management
}

## Used to provision the aws organization boundary
module "management_aws_organization" {
  count   = var.repositories.organizations != null ? 1 : 0
  source  = "appvia/oidc/aws//modules/role"
  version = "1.3.6"

  name                    = var.repositories.organizations.role_name
  description             = "Used to manage and configure the AWS organization, units and features"
  permission_boundary_arn = aws_iam_policy.default_permissions_boundary_management.arn
  repository              = var.repositories.organizations.url
  tags                    = var.tags

  shared_repositories = compact([
    var.repositories.identity,
    var.repositories.compliance,
  ])

  read_only_policy_arns = [
    "arn:aws:iam::aws:policy/AWSOrganizationsReadOnlyAccess",
    "arn:aws:iam::aws:policy/AWSSSODirectoryReadOnly",
    "arn:aws:iam::aws:policy/AWSSSOReadOnly",
    "arn:aws:iam::aws:policy/IAMReadOnlyAccess",
    "arn:aws:iam::aws:policy/ReadOnlyAccess",
  ]

  read_write_policy_arns = [
    "arn:aws:iam::aws:policy/AdministratorAccess",
  ]

  providers = {
    aws = aws.management
  }
}

## Used to provision the lz bootstrapping pipeline
module "management_aws_bootstrap" {
  count   = var.repositories.bootstrap != null ? 1 : 0
  source  = "appvia/oidc/aws//modules/role"
  version = "1.3.6"

  name                    = var.repositories.bootstrap.role_name
  description             = "Used to manage and configure landing zone bootstrapping module"
  permission_boundary_arn = aws_iam_policy.default_permissions_boundary_management.arn
  repository              = var.repositories.bootstrap.url
  tags                    = var.tags

  read_only_policy_arns = [
    "arn:aws:iam::aws:policy/AWSOrganizationsReadOnlyAccess",
    "arn:aws:iam::aws:policy/AWSCloudFormationReadOnlyAccess",
    "arn:aws:iam::aws:policy/AWSSSODirectoryReadOnly",
    "arn:aws:iam::aws:policy/AWSSSOReadOnly",
    "arn:aws:iam::aws:policy/IAMReadOnlyAccess",
    "arn:aws:iam::aws:policy/ReadOnlyAccess"
  ]

  read_write_policy_arns = [
    "arn:aws:iam::aws:policy/AWSCloudFormationFullAccess",
    "arn:aws:iam::aws:policy/AWSCloudFormationReadOnlyAccess",
    "arn:aws:iam::aws:policy/AWSOrganizationsReadOnlyAccess",
    "arn:aws:iam::aws:policy/AWSSSODirectoryReadOnly",
    "arn:aws:iam::aws:policy/AWSSSOReadOnly",
    "arn:aws:iam::aws:policy/IAMReadOnlyAccess",
    "arn:aws:iam::aws:policy/ReadOnlyAccess",
  ]

  providers = {
    aws = aws.management
  }
}

## Used to manage identity center
module "management_sso_identity" {
  count   = var.repositories.identity != null ? 1 : 0
  source  = "appvia/oidc/aws//modules/role"
  version = "1.3.6"

  name                    = var.repositories.identity.role_name
  description             = "Used to manage the identity center permissionsets and assignments"
  permission_boundary_arn = aws_iam_policy.default_permissions_boundary_management.arn
  repository              = var.repositories.identity.url
  tags                    = var.tags

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
}

## Used to manage and deploy the landing zone
module "management_landing_zone" {
  count   = var.repositories.accelerator != null ? 1 : 0
  source  = "appvia/oidc/aws//modules/role"
  version = "1.3.6"

  name                    = var.repositories.accelerator.role_name
  description             = "Used to manage and deploy the lanzing zone configuration"
  permission_boundary_arn = aws_iam_policy.default_permissions_boundary_management.arn
  repository              = var.repositories.accelerator.url
  tags                    = var.tags

  read_only_policy_arns = [
    "arn:aws:iam::${local.management_account_id}:policy/${aws_iam_policy.code_contributor.name}",
  ]

  read_write_policy_arns = [
    "arn:aws:iam::${local.management_account_id}:policy/${aws_iam_policy.code_release.name}",
  ]

  providers = {
    aws = aws.management
  }
}

# tfsec:ignore:aws-iam-no-policy-wildcards
module "cost_management" {
  count   = var.repositories.cost_management != null ? 1 : 0
  source  = "appvia/oidc/aws//modules/role"
  version = "1.3.6"

  name                    = var.repositories.cost_management.role_name
  description             = "Used to provision a collection of cost controls and notifications"
  permission_boundary_arn = aws_iam_policy.cost_iam_boundary.arn
  repository              = var.repositories.cost_management.url
  tags                    = var.tags

  read_only_inline_policies = {
    CostManagement = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "budgets:Describe*",
            "budgets:Get*",
            "budgets:List*",
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
            "budgets:*",
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
            "logs:UntagResource",
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
