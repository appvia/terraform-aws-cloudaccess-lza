![Github Actions](../../actions/workflows/terraform.yml/badge.svg)

# Terraform AWS CloudAccess LZA

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
    network    = var.aws_accounts["network"]
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
    network    = aws.network
  }
}
```

## CIS Alarms & Notifications

This module can configure CIS alarms and notifications. To enable this functionality, set the `enable_cis_alarms` variable to `true`. These will use a CloudWatch log group, defaulting to the AWS Control Tower organizational trail. In order to receive notifications on this events

1. Use the `notifications_emails` variable to specify a list of email addresses to send notifications to.

```hcl
enable_cis_alarms = true
notifications_emails = ["security@example.com"]
```

For notifications to slack

1. Create a JSON secret `lza/cloudaccess/alarms` in AWS Secrets Manager with the following format:

```json
{
  "webhook_url": "https://hooks.slack.com/services/..."
  "channel": "cloud-notifications"
}
```

2. Use the `slack_notification_secret_name` variable to specify the name of the secret in AWS Secrets Manager that contains the Slack webhook URL.

```hcl
enable_cis_alarms = true
notification_secret_name = "lza/cloudaccess/alarms"
```

## Update Documentation

The `terraform-docs` utility is used to generate this README. Follow the below steps to update:

1. Make changes to the `.terraform-docs.yml` file
2. Fetch the `terraform-docs` binary (https://terraform-docs.io/user-guide/installation/)
3. Run `terraform-docs markdown table --output-file ${PWD}/README.md --output-mode inject .`

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.4 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.43.0 |
| <a name="provider_aws.management"></a> [aws.management](#provider\_aws.management) | 5.43.0 |
| <a name="provider_aws.network"></a> [aws.network](#provider\_aws.network) | 5.43.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_alarm_baseline"></a> [alarm\_baseline](#module\_alarm\_baseline) | appvia/alarm-baseline/aws | 0.0.3 |
| <a name="module_default_boundary"></a> [default\_boundary](#module\_default\_boundary) | appvia/boundary-stack/aws | 0.0.1 |
| <a name="module_management_landing_zone"></a> [management\_landing\_zone](#module\_management\_landing\_zone) | appvia/oidc/aws//modules/role | 1.2.0 |
| <a name="module_management_sso_identity"></a> [management\_sso\_identity](#module\_management\_sso\_identity) | appvia/oidc/aws//modules/role | 1.2.0 |
| <a name="module_network_inspection_vpc_admin"></a> [network\_inspection\_vpc\_admin](#module\_network\_inspection\_vpc\_admin) | appvia/oidc/aws//modules/role | 1.2.0 |
| <a name="module_network_transit_gateway_admin"></a> [network\_transit\_gateway\_admin](#module\_network\_transit\_gateway\_admin) | appvia/oidc/aws//modules/role | 1.2.0 |
| <a name="module_permissive_boundary"></a> [permissive\_boundary](#module\_permissive\_boundary) | appvia/boundary-stack/aws | 0.0.1 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudformation_stack_set.identity_stackset](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudformation_stack_set) | resource |
| [aws_cloudformation_stack_set_instance.identity_stack](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudformation_stack_set_instance) | resource |
| [aws_iam_policy.code_contributor](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.code_release](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.cost_iam_boundary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.costs_admin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.costs_viewer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.ipam_admin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.user_management](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_organizations_organization.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/organizations_organization) | data source |
| [aws_secretsmanager_secret.notification](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret) | data source |
| [aws_secretsmanager_secret_version.notification](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_accounts"></a> [aws\_accounts](#input\_aws\_accounts) | Map of AWS account names to their account IDs | <pre>object({<br>    network_account_id      = optional(string, "")<br>    remoteaccess_account_id = optional(string, "")<br>  })</pre> | n/a | yes |
| <a name="input_cloudaccess_terraform_state_ro_policy_name"></a> [cloudaccess\_terraform\_state\_ro\_policy\_name](#input\_cloudaccess\_terraform\_state\_ro\_policy\_name) | Name of the IAM policy to attach to the CloudAccess Terraform state role | `string` | `"lza-cloudaccess-tfstate-ro"` | no |
| <a name="input_cloudaccess_terraform_state_rw_policy_name"></a> [cloudaccess\_terraform\_state\_rw\_policy\_name](#input\_cloudaccess\_terraform\_state\_rw\_policy\_name) | Name of the IAM policy to attach to the CloudAccess Terraform state role | `string` | `"lza-cloudaccess-tfstate-rw"` | no |
| <a name="input_costs_boundary_name"></a> [costs\_boundary\_name](#input\_costs\_boundary\_name) | Name of the IAM policy to use as a permissions boundary for cost-related roles | `string` | `"lza-costs-boundary"` | no |
| <a name="input_default_permissions_boundary_name"></a> [default\_permissions\_boundary\_name](#input\_default\_permissions\_boundary\_name) | Name of the default IAM policy to use as a permissions boundary | `string` | `"lza-default-boundary"` | no |
| <a name="input_enable_cis_alarms"></a> [enable\_cis\_alarms](#input\_enable\_cis\_alarms) | Indicates if we should enable CIS alerts | `bool` | `true` | no |
| <a name="input_enable_slack_notifications"></a> [enable\_slack\_notifications](#input\_enable\_slack\_notifications) | Indicates if we should enable Slack notifications | `bool` | `false` | no |
| <a name="input_enable_teams_notifications"></a> [enable\_teams\_notifications](#input\_enable\_teams\_notifications) | Indicates if we should enable Teams notifications | `bool` | `false` | no |
| <a name="input_notification_emails"></a> [notification\_emails](#input\_notification\_emails) | List of email addresses to send notifications to | `list(string)` | `[]` | no |
| <a name="input_notification_secret_name"></a> [notification\_secret\_name](#input\_notification\_secret\_name) | Name of the secret in AWS Secrets Manager that contains the secrets for notifications | `string` | `""` | no |
| <a name="input_permissive_permissions_boundary_name"></a> [permissive\_permissions\_boundary\_name](#input\_permissive\_permissions\_boundary\_name) | Name of the permissive IAM policy to use as a permissions boundary | `string` | `"lza-permissive-boundary"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region to deploy into | `string` | n/a | yes |
| <a name="input_repositories"></a> [repositories](#input\_repositories) | List of repository locations for the pipelines | <pre>object({<br>    accelerator = optional(object({<br>      url       = string<br>      role_name = optional(string, "lza-accelerator")<br>    }), null)<br>    connectivity = optional(object({<br>      url       = string<br>      role_name = optional(string, "lza-connectivity")<br>    }), null)<br>    firewall = optional(object({<br>      url       = string<br>      role_name = optional(string, "lza-firewall")<br>    }), null)<br>    identity = optional(object({<br>      url       = string<br>      role_name = optional(string, "lza-identity")<br>    }), null)<br>  })</pre> | `{}` | no |
| <a name="input_scm_name"></a> [scm\_name](#input\_scm\_name) | Name of the source control management system (github or gitlab) | `string` | `"github"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudaccess_terraform_state_ro_policy_name"></a> [cloudaccess\_terraform\_state\_ro\_policy\_name](#output\_cloudaccess\_terraform\_state\_ro\_policy\_name) | Name of the IAM policy to attach to the CloudAccess Terraform state role |
| <a name="output_cloudaccess_terraform_state_rw_policy_name"></a> [cloudaccess\_terraform\_state\_rw\_policy\_name](#output\_cloudaccess\_terraform\_state\_rw\_policy\_name) | Name of the IAM policy to attach to the CloudAccess Terraform state role |
| <a name="output_default_permission_boundary_name"></a> [default\_permission\_boundary\_name](#output\_default\_permission\_boundary\_name) | The name of the default permissions iam boundary |
| <a name="output_default_permissive_boundary_name"></a> [default\_permissive\_boundary\_name](#output\_default\_permissive\_boundary\_name) | The name of the default permissive iam boundary |
| <a name="output_identity_role_ro_name"></a> [identity\_role\_ro\_name](#output\_identity\_role\_ro\_name) | The name of the IAM readonly role which can be assumed by the identity stack in all accounts |
| <a name="output_identity_role_rw_name"></a> [identity\_role\_rw\_name](#output\_identity\_role\_rw\_name) | The name of the IAM readwrite role which can be assumed by the identity stack in all accounts |
| <a name="output_identity_stack_name"></a> [identity\_stack\_name](#output\_identity\_stack\_name) | The name of the identity stack |
<!-- END_TF_DOCS -->
