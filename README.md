<!-- markdownlint-disable -->
<a href="https://www.appvia.io/"><img src="https://github.com/appvia/terraform-aws-cloudaccess-lza/blob/main/appvia_banner.jpg?raw=true" alt="Appvia Banner"/></a><br/><p align="right"> <a href="https://registry.terraform.io/modules/appvia/cloudaccess-lza/aws/latest"><img src="https://img.shields.io/static/v1?label=APPVIA&message=Terraform%20Registry&color=191970&style=for-the-badge" alt="Terraform Registry"/></a></a> <a href="https://github.com/appvia/terraform-aws-cloudaccess-lza/releases/latest"><img src="https://img.shields.io/github/release/appvia/terraform-aws-cloudaccess-lza.svg?style=for-the-badge&color=006400" alt="Latest Release"/></a> <a href="https://appvia-community.slack.com/join/shared_invite/zt-1s7i7xy85-T155drryqU56emm09ojMVA#/shared-invite/email"><img src="https://img.shields.io/badge/Slack-Join%20Community-purple?style=for-the-badge&logo=slack" alt="Slack Community"/></a> <a href="https://github.com/appvia/terraform-aws-cloudaccess-lza/graphs/contributors"><img src="https://img.shields.io/github/contributors/appvia/terraform-aws-cloudaccess-lza.svg?style=for-the-badge&color=FF8C00" alt="Contributors"/></a>

<!-- markdownlint-restore -->
<!--
  ***** CAUTION: DO NOT EDIT ABOVE THIS LINE ******
-->

![Github Actions](https://github.com/appvia/terraform-aws-cloudaccess-lza/actions/workflows/terraform.yml/badge.svg)

## Description

The purpose of this module is to provision the baseline requirements for a landing zone environment, and to provide a pattern moving forward for pipeline access.

## Usage

Add example usage here

```hcl
## Provision the Landing Zone Access permissions
module "landing_zone" {
  source  = "appvia/cloudaccess-lza/aws"
  version = "0.0.1"

  aws_accounts = {
    management = var.aws_accounts["management"]
  }
  repositories = {
    accelerator_repository_url  = var.landing_zone_repositories.accelerator_repository_url
    connectivity_repository_url = var.landing_zone_repositories.connectivity_repository_url
    firewall_repository_url     = var.landing_zone_repositories.firewall_repository_url
    identity_repository_url     = var.landing_zone_repositories.identity_repository_url
  }
  tags = var.tags

  providers = {
    management = aws.management
  }
}
```

## CIS Alarms & Notifications

This module can configure CIS alarms and notifications. To enable this functionality, set the `enable_cis_alarms` variable to `true`. These will use a CloudWatch log group, defaulting to the AWS Control Tower organizational trail. In order to receive notifications on this events

1. Use the `notifications_emails` variable to specify a list of email addresses to send notifications to.

```hcl
enable_cis_alarms = true
enable_email_notifications = true
notifications = {
  email = {
    addresses = ["security@example.com"]
  }
}
```

For notifications to slack

1. Configuration the notifications block accordingly

```hcl
enable_email_notifications = true
notifications = {
  slack = {
    webhook_url = "https://hooks.slack.com/services/..."
    channel = "cloud-notifications"
  }
}
accounts_id_to_name = {
  "1234567890" = "mgmt"
}
cloudwatch_log_group_retention = 3
identity_center_start_url = "<your identity center start url - if relevant>"
identity_center_role = "<your your identity center role - consistent across accounts typically read only - if relevant>"
```

## Update Documentation

The `terraform-docs` utility is used to generate this README. Follow the below steps to update:

1. Make changes to the `.terraform-docs.yml` file
2. Fetch the `terraform-docs` binary (https://terraform-docs.io/user-guide/installation/)
3. Run `terraform-docs markdown table --output-file ${PWD}/README.md --output-mode inject .`

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.0.0 |
| <a name="provider_aws.audit"></a> [aws.audit](#provider\_aws.audit) | >= 6.0.0 |
| <a name="provider_aws.management"></a> [aws.management](#provider\_aws.management) | >= 6.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_accounts"></a> [aws\_accounts](#input\_aws\_accounts) | Map of AWS account names to their account IDs | <pre>object({<br/>    audit_account_id = string<br/>  })</pre> | n/a | yes |
| <a name="input_aws_support_role_name"></a> [aws\_support\_role\_name](#input\_aws\_support\_role\_name) | Name of the AWS Support role | `string` | `"AWSSupportAccessRole"` | no |
| <a name="input_aws_support_stack_name"></a> [aws\_support\_stack\_name](#input\_aws\_support\_stack\_name) | Name of the stackset used to deploy the aws support role | `string` | `"lz-aws-support-role"` | no |
| <a name="input_breakglass_users"></a> [breakglass\_users](#input\_breakglass\_users) | The number of breakglass users to create | `number` | `2` | no |
| <a name="input_costs_boundary_name"></a> [costs\_boundary\_name](#input\_costs\_boundary\_name) | Name of the IAM policy to use as a permissions boundary for cost-related roles | `string` | `"lz-costs-boundary"` | no |
| <a name="input_default_permissions_boundary_name"></a> [default\_permissions\_boundary\_name](#input\_default\_permissions\_boundary\_name) | Name of the default IAM policy used by roles we provision | `string` | `"lz-base-default-boundary"` | no |
| <a name="input_enable_aws_support"></a> [enable\_aws\_support](#input\_enable\_aws\_support) | Indicates if we should enable AWS Support role | `bool` | `true` | no |
| <a name="input_enable_breakglass"></a> [enable\_breakglass](#input\_enable\_breakglass) | Indicates if we should enable breakglass users and group | `bool` | `false` | no |
| <a name="input_enable_cis_alarms"></a> [enable\_cis\_alarms](#input\_enable\_cis\_alarms) | Indicates if we should enable CIS alerts | `bool` | `true` | no |
| <a name="input_notifications"></a> [notifications](#input\_notifications) | Configuration for the notifications | <pre>object({<br/>    lambda_name = optional(string, "lz-ca-notifications-slack")<br/>    email = optional(object({<br/>      addresses = list(string)<br/>    }), null)<br/>    slack = optional(object({<br/>      webhook_url = string<br/>    }), null)<br/>    teams = optional(object({<br/>      webhook_url = string<br/>    }), null)<br/>  })</pre> | <pre>{<br/>  "email": {<br/>    "addresses": []<br/>  },<br/>  "lambda_name": "lz-ca-notifications-slack",<br/>  "slack": null,<br/>  "teams": null<br/>}</pre> | no |
| <a name="input_repositories"></a> [repositories](#input\_repositories) | List of repository locations for the pipelines | <pre>object({<br/>    accelerator = optional(object({<br/>      url       = string<br/>      role_name = optional(string, "lz-aws-accelerator")<br/>      shared    = optional(list(string), [])<br/>    }), null)<br/>    accounts = optional(object({<br/>      url       = string<br/>      role_name = optional(string, "lz-aws-accounts")<br/>      shared    = optional(list(string), [])<br/>    }), null)<br/>    bootstrap = optional(object({<br/>      url       = string<br/>      role_name = optional(string, "lz-aws-bootstrap")<br/>      shared    = optional(list(string), [])<br/>    }), null)<br/>    compliance = optional(object({<br/>      url       = string<br/>      role_name = optional(string, "lz-aws-compliance")<br/>      shared    = optional(list(string), [])<br/>    }), null)<br/>    cost_management = optional(object({<br/>      url       = string<br/>      role_name = optional(string, "lz-aws-cost-management")<br/>      shared    = optional(list(string), [])<br/>    }), null)<br/>    identity = optional(object({<br/>      url       = string<br/>      role_name = optional(string, "lz-aws-identity")<br/>      shared    = optional(list(string), [])<br/>    }), null)<br/>    organizations = optional(object({<br/>      url       = string<br/>      role_name = optional(string, "lz-aws-organizations")<br/>      shared    = optional(list(string), [])<br/>    }), null)<br/>  })</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources | `map(string)` | `{}` | no |
| <a name="input_unauthorized_api_calls_extra_excluded_services"></a> [unauthorized\_api\_calls\_extra\_excluded\_services](#input\_unauthorized\_api\_calls\_extra\_excluded\_services) | Optional list of additional AWS services to exclude from unauthorized API call metric filter. | `list(string)` | `[]` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
