#
## Used to deploy a stackset to the organizational root which permits the role 
## to create policies 
#

## Create the default iam boundary used the pipelines
# tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_cloudformation_stack_set" "identity_stackset" {
  name             = local.identity_stack_name
  capabilities     = local.identity_capabilities
  description      = "Provision a role within the account allowing the identity repository to manage IAM policies"
  parameters       = local.identity_parameters
  permission_model = "SERVICE_MANAGED"
  template_body    = file("${path.module}/assets/cloudformation/${var.scm_name}-identity.yml")
  tags             = var.tags

  auto_deployment {
    enabled                          = true
    retain_stacks_on_account_removal = true
  }

  operation_preferences {
    failure_tolerance_count = 0
    max_concurrent_count    = 10
  }
}

## Deploy the stackset to the root of the organizationa root 
resource "aws_cloudformation_stack_set_instance" "identity_stack" {
  deployment_targets {
    organizational_unit_ids = [data.aws_organizations_organization.current.roots[0].id]
  }
  region         = var.region
  stack_set_name = local.identity_stack_name
}
