
locals {
  ## The account id of the network account 
  network_account_id = var.aws_accounts.network_account_id
  ## The account id of the management account
  management_account_id = data.aws_organizations_organization.current.master_account_id
  ## The current region name 
  region = data.aws_region.current.name
  ## The current account id 
  account_id = data.aws_caller_identity.current.account_id

  ## Indicates we have to inject the enforcement of tagging into the 
  ## IAM boundaries we create 
  enforce_tagging_enforcement = length(var.enforcable_tags) > 0

  ## The name of the aws support stackset 
  aws_support_stack_name = "LZA-IAM-Support-Role"
  ## The capabilities required for the aws support stackset 
  aws_support_capabilities = ["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM"]
  ## The parameters for the aws support stackset 
  aws_support_parameters = {
    "RoleName" = var.aws_support_role_name
  }

  ## Is the log group used the lambda function encrypted 
  enable_log_group_encryption = var.securityhub_lambda_log_group_kms_alias != ""

  ## Indicates if the notifications for slack are enabled 
  enable_slack_notifications = var.notifications.slack != null
  ## Indicates if the notifications for email are enabled 
  enable_email_notifications = length(var.notifications.email.addresses) > 0

  ## The name of the default iam boundary used the pipelines 
  boundary_default_stack_name = "LZA-IAM-DefaultBoundary"
  ## The name of the permissive boundary used the pipelines 
  boundary_permissive_stack_name = "LZA-IAM-PermissiveBoundary"
  ## The boundary stack parameters 
  boundary_default_stack_parameters = {
    "BoundaryName"               = var.default_permissions_boundary_name
    "TerraformStateROPolicyName" = var.cloudaccess_terraform_state_ro_policy_name
    "TerraformStateRWPolicyName" = var.cloudaccess_terraform_state_rw_policy_name
  }
  boundary_permissive_stack_parameters = {
    "BoundaryName"               = var.permissive_permissions_boundary_name
    "TerraformStateROPolicyName" = var.cloudaccess_terraform_state_ro_policy_name
    "TerraformStateRWPolicyName" = var.cloudaccess_terraform_state_rw_policy_name
  }


  # Is the stack name of the tagging enforcement iam boundary
  boundary_tagging_stack_name = "LZA-IAM-TaggingBoundary"
  # The parameters for the tagging enforcement boundary_tagging_stack_name
  boundary_tagging_stack_parameters = {
    "BoundaryName" = var.enforcable_tagging_policy_name
  }

  ## The name of the identity stack 
  identity_stack_name = "LZA-Identity-Permissions"
  ## The capabilities required for the identity stack
  identity_capabilities = ["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM"]
  ## The name of the identity provider if github is used
  identity_github_provider = var.scm_name == "github" ? "token.actions.githubusercontent.com" : null
  ## The name of the identity provider if gitlab is used
  identity_gitlab_provider = var.scm_name == "gitlab" ? "gitlab.com" : null
  ## The name of the identity provider depending on the on the scm_name
  identity_provider = coalesce(local.identity_github_provider, local.identity_gitlab_provider)
  ## The name of the read only role for the identity stack 
  identity_role_ro_name = format("%s-ro", var.repositories.identity.role_name)
  ## The name of the read write role for the identity stack 
  identity_role_rw_name = format("%s", var.repositories.identity.role_name)
  ## The parameters for the identity stack
  identity_parameters = {
    "IdentityRoleReadOnlyName"  = local.identity_role_ro_name
    "IdentityRoleReadWriteName" = local.identity_role_rw_name
    "IdentityProviderName"      = local.identity_provider,
    "RepositoryName"            = var.repositories.identity.url
  }

  ## The configuration for the slack notification 
  slack = local.enable_slack_notifications ? {
    lambda_name = "lza-ca-notifications-slack"
    webhook_url = var.notifications.slack.webhook_url
  } : null

  email = {
    addresses = var.notifications.email.addresses
  }

  notifications = {
    email = (local.enable_email_notifications ? local.email : null)
    slack = (local.enable_slack_notifications ? local.slack : null)
  }
}
