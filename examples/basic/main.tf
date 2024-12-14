#
## Landing Zone Resources
#

## Provision the Landing Zone Access permissions
module "landing_zone" {
  source = "../.."

  aws_accounts = var.aws_accounts
  tags         = var.tags

  enable_aws_support        = true
  enable_breakglass         = true
  enable_cis_alarms         = true
  enable_securityhub_alarms = true

  notifications = {
    slack = {
      webhook_url = "https://hooks.slack.com/services/..."
      channel     = "security-alerts"
    }
  }

  repositories = {
    accelerator = {
      url = "<ORG>/aws-accelerator-config"
    }
    identity = {
      url = "<ORG>/terrafom-aws-identity"
    }
  }

  providers = {
    aws.audit      = aws.audit
    aws.management = aws.management
  }
}
