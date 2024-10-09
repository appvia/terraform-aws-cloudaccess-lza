#
## Related to provisioning the IAM boundaries used by the pipelines
#

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

# tfsec:ignore:aws-iam-no-policy-wildcards
module "default_boundary" {
  source  = "appvia/boundary-stack/aws"
  version = "0.1.7"

  description               = "Used to deploy the default permissions boundary for the pipelines."
  enable_management_account = true
  name                      = local.boundary_default_stack_name
  parameters                = local.boundary_default_stack_parameters
  region                    = local.region
  tags                      = var.tags

  template = templatefile("${path.module}/assets/cloudformation/default-boundary.yml", {
    additional_policy = ""
  })

  providers = {
    aws = aws.management
  }
}

# tfsec:ignore:aws-iam-no-policy-wildcards
module "permissive_boundary" {
  source  = "appvia/boundary-stack/aws"
  version = "0.1.7"

  description               = "Used to deploy the permissive permissions boundary for the pipelines."
  enable_management_account = true
  name                      = local.boundary_permissive_stack_name
  parameters                = local.boundary_permissive_stack_parameters
  region                    = local.region
  tags                      = var.tags

  template = templatefile("${path.module}/assets/cloudformation/permissive-boundary.yml", {
    additional_policy = ""
  })

  providers = {
    aws = aws.management
  }
}
