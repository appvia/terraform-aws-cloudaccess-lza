#
## Related to provisioning the IAM boundaries used by the pipelines
#

## This is used by pipelines that need to interact with the AWS cost management APIs
resource "aws_iam_policy" "cost_iam_boundary" {
  name        = var.costs_boundary_name
  description = "IAM boundary used by the cost management pipelines"
  policy      = file("${path.module}/assets/boundaries/costs-boundary.json")
  tags        = var.tags

  provider = aws.management
}

# tfsec:ignore:aws-iam-no-policy-wildcards
module "default_boundary" {
  source  = "appvia/boundary-stack/aws"
  version = "0.1.2"

  description               = "Used to deploy the default permissions boundary for the pipelines."
  enable_management_account = true
  name                      = "LZA-IAM-DefaultBoundary"
  region                    = var.region
  tags                      = var.tags
  template                  = file("${path.module}/assets/cloudformation/default-boundary.yml")

  parameters = {
    "BoundaryName"               = var.default_permissions_boundary_name
    "TerraformStateROPolicyName" = var.cloudaccess_terraform_state_ro_policy_name
    "TerraformStateRWPolicyName" = var.cloudaccess_terraform_state_rw_policy_name
  }

  providers = {
    aws = aws.management
  }
}

# tfsec:ignore:aws-iam-no-policy-wildcards
module "permissive_boundary" {
  source  = "appvia/boundary-stack/aws"
  version = "0.1.2"

  description               = "Used to deploy the permissive permissions boundary for the pipelines."
  enable_management_account = true
  name                      = "LZA-IAM-PermissiveBoundary"
  region                    = var.region
  tags                      = var.tags
  template                  = file("${path.module}/assets/cloudformation/permissive-boundary.yml")

  parameters = {
    "BoundaryName"               = var.permissive_permissions_boundary_name
    "TerraformStateROPolicyName" = var.cloudaccess_terraform_state_ro_policy_name
    "TerraformStateRWPolicyName" = var.cloudaccess_terraform_state_rw_policy_name
  }

  providers = {
    aws = aws.management
  }
}
