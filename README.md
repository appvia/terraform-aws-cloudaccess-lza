![Github Actions](../../actions/workflows/terraform.yml/badge.svg)

# Terraform AWS Landing Zone Baseline

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
| <a name="requirement_archive"></a> [archive](#requirement\_archive) | ~> 2.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | 2.4.2 |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.49.0 |
| <a name="provider_aws.audit"></a> [aws.audit](#provider\_aws.audit) | 5.49.0 |
| <a name="provider_aws.management"></a> [aws.management](#provider\_aws.management) | 5.49.0 |
| <a name="provider_aws.network"></a> [aws.network](#provider\_aws.network) | 5.49.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_alarm_baseline"></a> [alarm\_baseline](#module\_alarm\_baseline) | appvia/alarm-baseline/aws | 0.1.7 |
| <a name="module_cost_management"></a> [cost\_management](#module\_cost\_management) | appvia/oidc/aws//modules/role | 1.3.0 |
| <a name="module_default_boundary"></a> [default\_boundary](#module\_default\_boundary) | appvia/boundary-stack/aws | 0.1.6 |
| <a name="module_management_landing_zone"></a> [management\_landing\_zone](#module\_management\_landing\_zone) | appvia/oidc/aws//modules/role | 1.3.0 |
| <a name="module_management_sso_identity"></a> [management\_sso\_identity](#module\_management\_sso\_identity) | appvia/oidc/aws//modules/role | 1.3.0 |
| <a name="module_network_inspection_vpc_admin"></a> [network\_inspection\_vpc\_admin](#module\_network\_inspection\_vpc\_admin) | appvia/oidc/aws//modules/role | 1.3.0 |
| <a name="module_network_transit_gateway_admin"></a> [network\_transit\_gateway\_admin](#module\_network\_transit\_gateway\_admin) | appvia/oidc/aws//modules/role | 1.3.0 |
| <a name="module_permissive_boundary"></a> [permissive\_boundary](#module\_permissive\_boundary) | appvia/boundary-stack/aws | 0.1.6 |
| <a name="module_securityhub_notifications"></a> [securityhub\_notifications](#module\_securityhub\_notifications) | appvia/notifications/aws | 0.1.5 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudformation_stack.aws_support_stack_instance_management_account](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudformation_stack) | resource |
| [aws_cloudformation_stack_set.aws_support_stack](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudformation_stack_set) | resource |
| [aws_cloudformation_stack_set.identity_stackset](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudformation_stack_set) | resource |
| [aws_cloudformation_stack_set_instance.aws_support_stack_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudformation_stack_set_instance) | resource |
| [aws_cloudformation_stack_set_instance.identity_stack](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudformation_stack_set_instance) | resource |
| [aws_cloudwatch_event_rule.security_hub_findings](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.security_hub_findings_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_iam_group.breakglass](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group) | resource |
| [aws_iam_group_policy_attachment.breakglass](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group_policy_attachment) | resource |
| [aws_iam_group_policy_attachment.test-attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group_policy_attachment) | resource |
| [aws_iam_policy.breakglass](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.code_contributor](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.code_release](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.cost_iam_boundary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.costs_admin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.costs_viewer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.ipam_admin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.user_management](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.securityhub_lambda_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.securityhub_lambda_cloudwatch_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_user.breakglass](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user) | resource |
| [aws_iam_user_group_membership.breakglass](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_group_membership) | resource |
| [aws_lambda_function.securityhub_lambda_function](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [archive_file.securityhub_lambda_package](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.breakglass](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.lambda_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.securityhub_notifications_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_organizations_organization.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/organizations_organization) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_accounts"></a> [aws\_accounts](#input\_aws\_accounts) | Map of AWS account names to their account IDs | <pre>object({<br>    network_account_id      = optional(string, "")<br>    remoteaccess_account_id = optional(string, "")<br>  })</pre> | n/a | yes |
| <a name="input_aws_support_role_name"></a> [aws\_support\_role\_name](#input\_aws\_support\_role\_name) | Name of the AWS Support role | `string` | `"AWSSupportAccess"` | no |
| <a name="input_breakglass_users"></a> [breakglass\_users](#input\_breakglass\_users) | The number of breakglass users to create | `number` | `2` | no |
| <a name="input_cloudaccess_terraform_state_ro_policy_name"></a> [cloudaccess\_terraform\_state\_ro\_policy\_name](#input\_cloudaccess\_terraform\_state\_ro\_policy\_name) | Name of the IAM policy to attach to the CloudAccess Terraform state role | `string` | `"lza-cloudaccess-tfstate-ro"` | no |
| <a name="input_cloudaccess_terraform_state_rw_policy_name"></a> [cloudaccess\_terraform\_state\_rw\_policy\_name](#input\_cloudaccess\_terraform\_state\_rw\_policy\_name) | Name of the IAM policy to attach to the CloudAccess Terraform state role | `string` | `"lza-cloudaccess-tfstate-rw"` | no |
| <a name="input_costs_boundary_name"></a> [costs\_boundary\_name](#input\_costs\_boundary\_name) | Name of the IAM policy to use as a permissions boundary for cost-related roles | `string` | `"lza-costs-boundary"` | no |
| <a name="input_default_permissions_boundary_name"></a> [default\_permissions\_boundary\_name](#input\_default\_permissions\_boundary\_name) | Name of the default IAM policy to use as a permissions boundary | `string` | `"lza-default-boundary"` | no |
| <a name="input_enable_aws_support"></a> [enable\_aws\_support](#input\_enable\_aws\_support) | Indicates if we should enable AWS Support role | `bool` | `true` | no |
| <a name="input_enable_breakglass"></a> [enable\_breakglass](#input\_enable\_breakglass) | Indicates if we should enable breakglass users and group | `bool` | `false` | no |
| <a name="input_enable_cis_alarms"></a> [enable\_cis\_alarms](#input\_enable\_cis\_alarms) | Indicates if we should enable CIS alerts | `bool` | `true` | no |
| <a name="input_enable_securityhub_alarms"></a> [enable\_securityhub\_alarms](#input\_enable\_securityhub\_alarms) | Indicates if we should enable SecurityHub alarms | `bool` | `true` | no |
| <a name="input_notifications"></a> [notifications](#input\_notifications) | Configuration for the notifications | <pre>object({<br>    email = optional(object({<br>      addresses = list(string)<br>    }), null)<br>    slack = optional(object({<br>      webhook_url = string<br>      channel     = string<br>    }), null)<br>    teams = optional(object({<br>      webhook_url = string<br>    }), null)<br>  })</pre> | <pre>{<br>  "email": {<br>    "addresses": []<br>  },<br>  "slack": null,<br>  "teams": null<br>}</pre> | no |
| <a name="input_permissive_permissions_boundary_name"></a> [permissive\_permissions\_boundary\_name](#input\_permissive\_permissions\_boundary\_name) | Name of the permissive IAM policy to use as a permissions boundary | `string` | `"lza-permissive-boundary"` | no |
| <a name="input_repositories"></a> [repositories](#input\_repositories) | List of repository locations for the pipelines | <pre>object({<br>    accelerator = optional(object({<br>      url       = string<br>      role_name = optional(string, "lza-accelerator")<br>    }), null)<br>    connectivity = optional(object({<br>      url       = string<br>      role_name = optional(string, "lza-connectivity")<br>    }), null)<br>    cost_management = optional(object({<br>      url       = string<br>      role_name = optional(string, "lza-cost-management")<br>    }), null)<br>    firewall = optional(object({<br>      url       = string<br>      role_name = optional(string, "lza-firewall")<br>    }), null)<br>    identity = optional(object({<br>      url       = string<br>      role_name = optional(string, "lza-identity")<br>    }), null)<br>  })</pre> | `{}` | no |
| <a name="input_scm_name"></a> [scm\_name](#input\_scm\_name) | Name of the source control management system (github or gitlab) | `string` | `"github"` | no |
| <a name="input_securityhub_event_bridge_rule_name"></a> [securityhub\_event\_bridge\_rule\_name](#input\_securityhub\_event\_bridge\_rule\_name) | Display name of the EventBridge rule for Security Hub findings | `string` | `"lza-securityhub-alerts"` | no |
| <a name="input_securityhub_severity_filter"></a> [securityhub\_severity\_filter](#input\_securityhub\_severity\_filter) | Indicates if we should enable SecurityHub | `list(string)` | <pre>[<br>  "CRITICAL",<br>  "HIGH"<br>]</pre> | no |
| <a name="input_securityhub_sns_topic_name"></a> [securityhub\_sns\_topic\_name](#input\_securityhub\_sns\_topic\_name) | Name of the SNS topic to send Security Hub findings to | `string` | `"lza-securityhub-alerts"` | no |
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
