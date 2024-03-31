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
  ## The name of the read only role for the identity stack 
  identity_role_ro_name = format("%s-ro", var.repositories.identity.role_name)
  ## The name of the read write role for the identity stack 
  identity_role_rw_name = format("%s-rw", var.repositories.identity.role_name)
  ## The parameters for the identity stack
  identity_parameters = {
    "IdentityRoleReadOnlyName"  = local.identity_role_ro_name
    "IdentityRoleReadWriteName" = local.identity_role_rw_name
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

  auto_deployment {
    enabled                          = true
    retain_stacks_on_account_removal = true
  }

  managed_execution {
    active = true
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
