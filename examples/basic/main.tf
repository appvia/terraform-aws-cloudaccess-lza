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
      url = "github.com/<ORG>/aws-accelerator-config"
    }
    connectivity = {
      url = "github.com/<ORG>/terrafom-aws-connectivity"
    }
    firewall = {
      url = "github.com/<ORG>/terrafom-aws-firewall"
    }
    identity = {
      url = "github.com/<ORG>/terrafom-aws-identity"
    }
  }

  providers = {
    aws.management = aws.management
    aws.network    = aws.network
  }
}
