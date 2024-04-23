#
## Used to deploy a stackset to the organizational root which permits AWS support
#

## Create the default iam boundary used the pipelines
# tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_cloudformation_stack_set" "aws_support_stack" {
  count = var.enable_aws_support ? 1 : 0

  name             = local.aws_support_stack_name
  capabilities     = local.aws_support_capabilities
  description      = "Provision a role for AWS Support to access resources in the account"
  parameters       = local.aws_support_parameters
  permission_model = "SERVICE_MANAGED"
  template_body    = file("${path.module}/assets/cloudformation/aws-support-role.yml")
  tags             = var.tags

  auto_deployment {
    enabled                          = true
    retain_stacks_on_account_removal = true
  }

  operation_preferences {
    failure_tolerance_count = 0
    max_concurrent_count    = 10
  }

  provider = aws.management
}

## Deploy the stackset to the root of the organizationa root 
resource "aws_cloudformation_stack_set_instance" "aws_support_stack_instance" {
  count = var.enable_aws_support ? 1 : 0

  deployment_targets {
    organizational_unit_ids = [data.aws_organizations_organization.current.roots[0].id]
  }
  region         = local.region
  stack_set_name = local.aws_support_stack_name

  depends_on = [aws_cloudformation_stack_set.aws_support_stack]
  provider   = aws.management
}

## Deployment of same stack the management account
resource "aws_cloudformation_stack" "aws_support_stack_instance_management_account" {
  count = var.enable_aws_support ? 1 : 0

  capabilities  = local.aws_support_capabilities
  name          = local.aws_support_stack_name
  on_failure    = "ROLLBACK"
  parameters    = local.aws_support_parameters
  tags          = var.tags
  template_body = file("${path.module}/assets/cloudformation/aws-support-role.yml")

  provider = aws.management
}
