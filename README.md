![GitHub Actions](https://img.shields.io/badge/github%20actions-%232671E5.svg?style=for-the-badge&logo=githubactions&logoColor=white)

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
| <a name="module_alarm_baseline"></a> [alarm\_baseline](#module\_alarm\_baseline) | appvia/alarm-baseline/aws | 0.0.2 |
| <a name="module_default_boundary"></a> [default\_boundary](#module\_default\_boundary) | appvia/boundary-stack/aws | 0.0.1 |
| <a name="module_management_landing_zone"></a> [management\_landing\_zone](#module\_management\_landing\_zone) | appvia/oidc/aws//modules/role | 1.1.0 |
| <a name="module_management_sso_identity"></a> [management\_sso\_identity](#module\_management\_sso\_identity) | appvia/oidc/aws//modules/role | 1.1.0 |
| <a name="module_network_inspection_vpc_admin"></a> [network\_inspection\_vpc\_admin](#module\_network\_inspection\_vpc\_admin) | appvia/oidc/aws//modules/role | 1.1.0 |
| <a name="module_network_transit_gateway_admin"></a> [network\_transit\_gateway\_admin](#module\_network\_transit\_gateway\_admin) | appvia/oidc/aws//modules/role | 1.1.0 |
| <a name="module_permissive_boundary"></a> [permissive\_boundary](#module\_permissive\_boundary) | appvia/boundary-stack/aws | 0.0.1 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.code_contributor](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.code_release](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.cost_iam_boundary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.costs_admin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.costs_viewer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.ipam_admin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.user_management](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_secretsmanager_secret.slack](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret) | data source |
| [aws_secretsmanager_secret_version.slack](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_accounts"></a> [aws\_accounts](#input\_aws\_accounts) | Map of AWS account names to their account IDs | <pre>object({<br>    management_account_id = string<br>    network_account_id    = string<br>  })</pre> | n/a | yes |
| <a name="input_cloudaccess_terraform_state_ro_policy_name"></a> [cloudaccess\_terraform\_state\_ro\_policy\_name](#input\_cloudaccess\_terraform\_state\_ro\_policy\_name) | Name of the IAM policy to attach to the CloudAccess Terraform state role | `string` | `"lza-cloudaccess-tfstate-ro"` | no |
| <a name="input_cloudaccess_terraform_state_rw_policy_name"></a> [cloudaccess\_terraform\_state\_rw\_policy\_name](#input\_cloudaccess\_terraform\_state\_rw\_policy\_name) | Name of the IAM policy to attach to the CloudAccess Terraform state role | `string` | `"lza-cloudaccess-tfstate-rw"` | no |
| <a name="input_costs_boundary_name"></a> [costs\_boundary\_name](#input\_costs\_boundary\_name) | Name of the IAM policy to use as a permissions boundary for cost-related roles | `string` | `"lza-costs-boundary"` | no |
| <a name="input_default_permissions_boundary_name"></a> [default\_permissions\_boundary\_name](#input\_default\_permissions\_boundary\_name) | Name of the default IAM policy to use as a permissions boundary | `string` | `"lza-default-boundary"` | no |
| <a name="input_enable_cis_alerts"></a> [enable\_cis\_alerts](#input\_enable\_cis\_alerts) | Indicates if we should enable CIS alerts | `bool` | `true` | no |
| <a name="input_landing_zone_repositories"></a> [landing\_zone\_repositories](#input\_landing\_zone\_repositories) | List of repository locations for the landing zone functionality | <pre>object({<br>    accelerator_repository_url  = optional(string)<br>    connectivity_repository_url = optional(string)<br>    firewall_repository_url     = optional(string)<br>    identity_repository_url     = optional(string)<br>  })</pre> | <pre>{<br>  "accelerator_repository_url": "",<br>  "connectivity_repository_url": "",<br>  "firewall_repository_url": "",<br>  "identity_repository_url": ""<br>}</pre> | no |
| <a name="input_notification_emails"></a> [notification\_emails](#input\_notification\_emails) | List of email addresses to send notifications to | `list(string)` | `[]` | no |
| <a name="input_permissive_permissions_boundary_name"></a> [permissive\_permissions\_boundary\_name](#input\_permissive\_permissions\_boundary\_name) | Name of the permissive IAM policy to use as a permissions boundary | `string` | `"lza-permissive-boundary"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region to deploy into | `string` | n/a | yes |
| <a name="input_slack_notification_channel"></a> [slack\_notification\_channel](#input\_slack\_notification\_channel) | Slack channel to send notifications to | `string` | `"cloud-notifications"` | no |
| <a name="input_slack_notification_secret_name"></a> [slack\_notification\_secret\_name](#input\_slack\_notification\_secret\_name) | Name of the secret in AWS Secrets Manager that contains the Slack webhook URL | `string` | `"notification/slack"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudaccess_terraform_state_ro_policy_name"></a> [cloudaccess\_terraform\_state\_ro\_policy\_name](#output\_cloudaccess\_terraform\_state\_ro\_policy\_name) | Name of the IAM policy to attach to the CloudAccess Terraform state role |
| <a name="output_cloudaccess_terraform_state_rw_policy_name"></a> [cloudaccess\_terraform\_state\_rw\_policy\_name](#output\_cloudaccess\_terraform\_state\_rw\_policy\_name) | Name of the IAM policy to attach to the CloudAccess Terraform state role |
| <a name="output_default_permissions_boundary_name"></a> [default\_permissions\_boundary\_name](#output\_default\_permissions\_boundary\_name) | The name of the default permissions boundary |
| <a name="output_default_permissive_boundary_name"></a> [default\_permissive\_boundary\_name](#output\_default\_permissive\_boundary\_name) | The name of the default permissive boundary |
<!-- END_TF_DOCS -->
