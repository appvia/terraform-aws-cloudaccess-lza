#
## Used to deploy a stackset to the organizational root which permits the role 
## to create policies 
#
locals {
  ## The name of the identity stack 
  identity_stack_name = "LZA-Identity-Permissions"
  ## The capabilities required for the identity stack
  identity_capabilities = ["CAPABILITY_NAMED_IAM", "CAPABILITY_AUTO_EXPAND", "CAPABILITY_IAM"]
  ## The name of the identity provider if github is used
  identity_github_provider = var.scm_name == "github" ? "token.actions.githubusercontent.com" : null
  ## The name of the identity provider if gitlab is used
  identity_gitlab_provider = var.scm_name == "gitlab" ? "gitlab.com" : null
  ## The name of the identity provider depending on the on the scm_name
  identity_provider = coalesce(local.identity_github_provider, local.identity_gitlab_provider)
  ## The name of the read write role which can be assumed on all accounts 
  identity_role_rw_name = "lza-identity-permissions-rw"
  ## The name of the read only role which can be assumed on all accounts 
  identity_role_ro_name = "lza-identity-permissions-ro"
  ## The parameters required for the identity stack
  identity_parameters = {
    "IdentityRoleReadOnlyName"  = local.identity_role_ro_name,
    "IdentityRoleReadWriteName" = local.identity_role_rw_name,
    "IdentityProviderName"      = local.identity_provider,
    "RepositoryName"            = var.repositories.identity.url
  }
}

data "aws_organizations_organization" "current" {}

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

  operation_preferences {
    failure_tolerance_count = 0
    max_concurrent_count    = 10
  }

  auto_deployment {
    enabled                          = true
    retain_stacks_on_account_removal = true
  }
}

## Deploy the permissive boundary to the organizational root 
resource "aws_cloudformation_stack_set_instance" "identity_stack" {
  deployment_targets {
    organizational_unit_ids = [data.aws_organizations_organization.current.roots[0].id]
  }
  region         = var.region
  stack_set_name = local.identity_stack_name
}

## Deployment of same stacko the management account
resource "aws_cloudformation_stack" "management" {
  capabilities  = local.identity_capabilities
  name          = local.identity_stack_name
  on_failure    = "ROLLBACK"
  parameters    = local.identity_parameters
  tags          = var.tags
  template_body = file("${path.module}/assets/cloudformation/${var.scm_name}-identity.yml")
}
