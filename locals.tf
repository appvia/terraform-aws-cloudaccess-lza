
locals {
  ## The account id of the network account 
  network_account_id = var.aws_accounts.network_account_id
  ## The account id of the management account
  management_account_id = data.aws_organizations_organization.current.master_account_id
  ## The current region name 
  region = data.aws_region.current.name

  ## The name of the aws support stackset 
  aws_support_stack_name = "LZA-IAM-Support-Role"
  ## The capabilities required for the aws support stackset 
  aws_support_capabilities = ["CAPABILITY_NAMED_IAM", "CAPABILITY_AUTO_EXPAND", "CAPABILITY_IAM"]
  ## The parameters for the aws support stackset 
  aws_support_parameters = {
    "RoleName" = var.aws_support_role_name
  }

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
  identity_role_rw_name = format("%s", var.repositories.identity.role_name)
  ## The parameters for the identity stack
  identity_parameters = {
    "IdentityRoleReadOnlyName"  = local.identity_role_ro_name
    "IdentityRoleReadWriteName" = local.identity_role_rw_name
    "IdentityProviderName"      = local.identity_provider,
    "RepositoryName"            = var.repositories.identity.url
  }

  ## The configuration for the slack notification 
  slack_notification = var.enable_slack_notifications ? {
    slack = {
      channel     = jsondecode(data.aws_secretsmanager_secret_version.notification[0].secret_string).channel
      webhook_url = jsondecode(data.aws_secretsmanager_secret_version.notification[0].secret_string).webhook_url
    }
  } : {}

  ## The configuration for the teams notification
  teams_notification = var.enable_teams_notifications ? {
    teams = {
      webhook_url = jsondecode(data.aws_secretsmanager_secret_version.notification[0].secret_string).webhook_url
    }
  } : {}

  ## The configuration for the notifications
  notifications = merge(
    {
      email = {
        addresses = var.notification_emails
      }
    },
    local.slack_notification,
    local.teams_notification
  )
}
