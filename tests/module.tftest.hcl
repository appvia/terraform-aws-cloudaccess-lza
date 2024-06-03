mock_provider "aws" {
  mock_data "aws_organizations_organization" {
    defaults = {
      roots = [
        {
          id = "r-123abc"
        }
      ]
      master_account_id = "123456789123"
    }
  }
  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Principal\":{\"Service\":\"lambda.amazonaws.com\"},\"Effect\":\"Allow\",\"Sid\":\"\"}]}"
    }
  }
}

mock_provider "aws" {
  alias = "management"

  override_data {
    target = module.default_boundary.data.aws_organizations_organization.current
    values = {
      roots = [
        {
          id = "r-123abc"
        }
      ]
    }
  }
  override_data {
    target = module.permissive_boundary.data.aws_organizations_organization.current
    values = {
      roots = [
        {
          id = "r-123abc"
        }
      ]
    }
  }
}

mock_provider "aws" {
  alias = "network"
}

mock_provider "aws" {
  alias = "audit"
}

run "basic" {
  command = plan

  variables {
    aws_accounts = {
      network_account_id      = "135791357913"
      remoteaccess_account_id = "246824682468"
    }
    tags = {
      environment = "dev"
    }
    repositories = {
      identity = {
        role_name = "terrafom-aws-identity"
        url       = "terrafom-aws-connectivity"
      }
    }
  }
}
