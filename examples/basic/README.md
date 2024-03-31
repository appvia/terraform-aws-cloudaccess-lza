<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.43.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_landing_zone"></a> [landing\_zone](#module\_landing\_zone) | ../.. | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_session_context.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_session_context) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_accounts"></a> [aws\_accounts](#input\_aws\_accounts) | Map of AWS account names to their account IDs | `map(string)` | <pre>{<br>  "management": "123456789012",<br>  "network": "123456789012"<br>}</pre> | no |
| <a name="input_provider_session_name"></a> [provider\_session\_name](#input\_provider\_session\_name) | Name of the session to use when assuming the IAM role | `string` | `"terraform-aws-cloudaccess"` | no |
| <a name="input_provider_web_identity_token_file"></a> [provider\_web\_identity\_token\_file](#input\_provider\_web\_identity\_token\_file) | Path to the web identity token file | `string` | `"/tmp/web_identity_token_file"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region to deploy resources in | `string` | `"us-west-2"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_default_permission_boundary_name"></a> [default\_permission\_boundary\_name](#output\_default\_permission\_boundary\_name) | The name of the permission boundary to attach to all roles |
| <a name="output_default_permissive_boundary_name"></a> [default\_permissive\_boundary\_name](#output\_default\_permissive\_boundary\_name) | The name of the permissive boundary to attach to all roles |
<!-- END_TF_DOCS -->