#
## Related to the network account
#

# tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_iam_policy" "ipam_admin" {
  count = var.repositories.connectivity != null ? 1 : 0

  description = "Provides the permissions to manage the ipam service"
  name        = "lza-ipam-management"
  policy      = file("${path.module}/assets/policies/ipam-management.json")
  tags        = var.tags

  provider = aws.network
}

## Provision the iam boundary within the network account
resource "aws_iam_policy" "default_permissions_boundary_network" {
  count = var.repositories.connectivity != null || var.repositories.firewall != null ? 1 : 0

  name        = var.default_permissions_boundary_name
  description = "Used by the LZA pipelines to enforce permissions"
  policy      = data.aws_iam_policy_document.default_permissions_boundary["network"].json
  tags        = var.tags

  provider = aws.network
}

module "network_transit_gateway_admin" {
  count   = var.repositories.connectivity != null ? 1 : 0
  source  = "appvia/oidc/aws//modules/role"
  version = "1.3.4"

  name                    = var.repositories.connectivity.role_name
  description             = "Deployment role used to deploy the Transit Gateway"
  permission_boundary_arn = aws_iam_policy.default_permissions_boundary_network[0].arn
  repository              = var.repositories.connectivity.url
  tags                    = var.tags

  read_only_policy_arns = [
    "arn:aws:iam::aws:policy/AWSResourceAccessManagerReadOnlyAccess",
    "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess",
    "arn:aws:iam::aws:policy/ReadOnlyAccess",
  ]
  read_write_policy_arns = [
    "arn:aws:iam::${local.network_account_id}:policy/${aws_iam_policy.ipam_admin[0].name}",
    "arn:aws:iam::aws:policy/AWSResourceAccessManagerFullAccess",
    "arn:aws:iam::aws:policy/ReadOnlyAccess",
    "arn:aws:iam::aws:policy/job-function/NetworkAdministrator",
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
  ]

  read_write_inline_policies = {
    "endpoints" = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "route53resolver:Associate*",
            "route53resolver:Create*",
            "route53resolver:Delete*",
            "route53resolver:Disassociate*",
            "route53resolver:Get*",
            "route53resolver:List*",
            "route53resolver:Tag*",
            "route53resolver:Update*",
            "Route53resolver:UnTag*"
          ]
          Effect   = "Allow"
          Resource = "*"
        }
      ]
    })
  }

  # We can share our state with the firewall module
  shared_repositories = var.repositories.firewall != null ? [var.repositories.firewall.url] : []

  providers = {
    aws = aws.network
  }
}

# tfsec:ignore:aws-iam-no-policy-wildcards
module "network_inspection_vpc_admin" {
  count   = var.repositories.firewall != null ? 1 : 0
  source  = "appvia/oidc/aws//modules/role"
  version = "1.3.4"

  name                    = var.repositories.firewall.role_name
  description             = "Deployment role used to deploy the inspection vpc"
  permission_boundary_arn = aws_iam_policy.default_permissions_boundary_network[0].arn
  repository              = var.repositories.firewall.url
  tags                    = var.tags

  read_only_policy_arns = [
    "arn:aws:iam::aws:policy/AWSResourceAccessManagerReadOnlyAccess",
    "arn:aws:iam::aws:policy/ReadOnlyAccess",
  ]
  read_write_policy_arns = [
    "arn:aws:iam::aws:policy/AWSResourceAccessManagerFullAccess",
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
    "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess",
    "arn:aws:iam::aws:policy/CloudformationFullAccess",
    "arn:aws:iam::aws:policy/ReadOnlyAccess",
    "arn:aws:iam::aws:policy/job-function/NetworkAdministrator",
  ]

  read_write_inline_policies = {
    "additional" = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "network-firewall:Associate*",
            "network-firewall:Create*",
            "network-firewall:Delete*",
            "network-firewall:Describe*",
            "network-firewall:Disassociate*",
            "network-firewall:List*",
            "network-firewall:Put*",
            "network-firewall:Tag*",
            "network-firewall:Untag*",
            "network-firewall:Update*",
          ]
          Effect   = "Allow"
          Resource = "*"
        },
        {
          Action   = ["iam:CreateServiceLinkedRole"],
          Effect   = "Allow",
          Resource = ["arn:aws:iam::*:role/aws-service-role/network-firewall.amazonaws.com/AWSServiceRoleForNetworkFirewall"]
        },
        {
          Action   = ["logs:*"],
          Effect   = "Allow",
          Resource = ["*"]
        },
        {
          Action = [
            "network-firewall:Describe*",
            "network-firewall:List*"
          ]
          Effect   = "Allow"
          Resource = "*"
        },
        {
          Action = [
            "logs:Get*",
            "logs:List*",
            "logs:Describe*",
          ],
          Effect   = "Allow",
          Resource = ["*"]
        }
      ]
    })
  }

  read_only_inline_policies = {
    "additional" = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "network-firewall:Describe*",
            "network-firewall:List*"
          ]
          Effect   = "Allow"
          Resource = "*"
        },
        {
          Action = [
            "logs:Describe*",
            "logs:Get*",
            "logs:List*",
          ],
          Effect   = "Allow",
          Resource = ["*"]
        }
      ]
    })
  }


  providers = {
    aws = aws.network
  }
}
