#
## Landing Zone Resources
#

## Provision the Landing Zone Access permissions, trusting Azure DevOps as the CI/CD identity
## provider instead of GitHub/GitLab. Each repository's "url" is the Azure DevOps
## "<organisation-name>/<project-name>/<service-connection-name>" triple rather than a git URL -
## the read-write role trusts the service connection as given, and the read-only role trusts a
## dedicated "<service-connection-name>-ro" connection (derived automatically), since Azure
## DevOps OIDC subjects carry no branch/tag/environment claim to otherwise separate the two.
module "landing_zone" {
  source = "../.."

  aws_accounts = var.aws_accounts
  tags         = var.tags

  enable_aws_support = true
  enable_breakglass  = true
  enable_cis_alarms  = true

  common_provider             = "azuredevops"
  azuredevops_organization_id = var.azuredevops_organization_id

  notifications = {
    slack = {
      webhook_url = "https://hooks.slack.com/services/..."
      channel     = "security-alerts"
    }
  }

  repositories = {
    accelerator = {
      url = "<AZDO_ORG>/<AZDO_PROJECT>/aws-accelerator-config"
    }
    identity = {
      url = "<AZDO_ORG>/<AZDO_PROJECT>/terraform-aws-identity"
    }
  }

  providers = {
    aws.audit      = aws.audit
    aws.management = aws.management
  }
}
