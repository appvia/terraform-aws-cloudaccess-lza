<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_landing_zone"></a> [landing\_zone](#module\_landing\_zone) | ../.. | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_accounts"></a> [aws\_accounts](#input\_aws\_accounts) | Map of AWS account names to their account IDs | `map(string)` | <pre>{<br/>  "management": "123456789012",<br/>  "network": "123456789012"<br/>}</pre> | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region to deploy resources in | `string` | `"us-west-2"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->