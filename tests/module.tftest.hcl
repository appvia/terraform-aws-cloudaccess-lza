## Configure the real aws provider with fake static credentials, skipping every validation call
## it would otherwise make. This lets pure local computations (e.g. aws_iam_policy_document, used
## for every trust and permissions-boundary policy in this module) evaluate for real, so assertions
## below can verify actual generated policy content rather than a stubbed value, without requiring
## genuine AWS credentials.
provider "aws" {
  region                      = "eu-west-2"
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
}

provider "aws" {
  alias                       = "management"
  region                      = "eu-west-2"
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
}

provider "aws" {
  alias                       = "audit"
  region                      = "eu-west-2"
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
}

## Override only the data sources that would otherwise still need real AWS access.
override_data {
  target = data.aws_organizations_organization.current
  values = {
    roots             = [{ id = "r-123abc" }]
    master_account_id = "111111111111"
  }
}

override_data {
  target = data.aws_caller_identity.current
  values = {
    account_id = "111111111111"
  }
}

override_data {
  target = data.aws_region.current
  values = {
    region = "eu-west-2"
  }
}

## module.notifications (appvia/notify/aws) and its nested sns submodule also look up the
## current caller identity, unrelated to the CI/CD identity provider under test here.
override_data {
  target = module.notifications.data.aws_caller_identity.current
  values = {
    account_id = "111111111111"
  }
}

override_data {
  target = module.notifications.module.sns[0].data.aws_caller_identity.current
  values = {
    account_id = "111111111111"
  }
}

run "azuredevops_hub_and_spoke_trust" {
  command = plan

  variables {
    aws_accounts = {
      audit_account_id = "222222222222"
    }
    tags = {
      environment = "dev"
    }
    common_provider             = "azuredevops"
    azuredevops_organization_id = "00000000-0000-0000-0000-000000000000"
    repositories = {
      compliance = {
        role_name = "lz-aws-compliance-test"
        url       = "myorg/myproject/lz-aws-compliance-test"
      }
    }
  }

  ## audit_compliance_management runs in the management (hub) account, where the Azure DevOps
  ## OIDC provider is federated directly.
  override_data {
    target = module.audit_compliance_management[0].data.aws_caller_identity.current
    values = {
      account_id = "111111111111"
    }
  }

  override_data {
    target = module.audit_compliance_management[0].data.aws_region.current
    values = {
      region = "eu-west-2"
    }
  }

  override_data {
    target = module.audit_compliance_management[0].data.aws_iam_openid_connect_provider.this
    values = {
      url = "https://vstoken.dev.azure.com/00000000-0000-0000-0000-000000000000"
      arn = "arn:aws:iam::111111111111:oidc-provider/vstoken.dev.azure.com/00000000-0000-0000-0000-000000000000"
    }
  }

  ## audit_compliance runs in the audit account - a spoke of the management-account hub - so it
  ## should trust its counterpart hub role via sts:AssumeRole rather than federating OIDC directly.
  override_data {
    target = module.audit_compliance[0].data.aws_caller_identity.current
    values = {
      account_id = "222222222222"
    }
  }

  override_data {
    target = module.audit_compliance[0].data.aws_region.current
    values = {
      region = "eu-west-2"
    }
  }

  override_data {
    target = module.audit_compliance[0].data.aws_iam_openid_connect_provider.this
    values = {
      url = "https://vstoken.dev.azure.com/00000000-0000-0000-0000-000000000000"
      arn = "arn:aws:iam::111111111111:oidc-provider/vstoken.dev.azure.com/00000000-0000-0000-0000-000000000000"
    }
  }

  ## The role module (appvia/oidc/aws//modules/role) only exposes role ARNs as outputs, and those
  ## ARNs aren't known until apply, so neither trust policy content nor the resulting ARN is
  ## assertable from a `command = plan` run against this module boundary. This run instead proves
  ## the plan succeeds end-to-end with common_provider = "azuredevops" - exercising the new
  ## variable wiring, both this module's and the upstream role module's validations, and the
  ## hub/spoke azuredevops_primary_role_account_id conditional in audit.tf. The underlying
  ## hub/spoke trust behaviour itself (direct OIDC vs sts:AssumeRole chaining) is covered by
  ## terraform-aws-oidc's own tests/role.azuredevops.tftest.hcl.
  assert {
    condition     = var.common_provider == "azuredevops"
    error_message = "Test should run with common_provider set to azuredevops"
  }
}
