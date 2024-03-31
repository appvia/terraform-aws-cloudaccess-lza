#
## Landing Zone Resources 
#

## Provision the Landing Zone Access permissions 
module "landing_zone" {
  source = "../.."

  aws_accounts = var.aws_accounts
  region       = var.region
  tags         = var.tags

  repositories = {
    accelerator = {
      url = "<ORG>/aws-accelerator-config"
    }
    connectivity = {
      url = "<ORG>/terrafom-aws-connectivity"
    }
    firewall = {
      url = "<ORG>/terrafom-aws-firewall"
    }
    identity = {
      url = "<ORG>/terrafom-aws-identity"
    }
  }

  providers = {
    aws.management = aws.management
    aws.network    = aws.network
  }
}
