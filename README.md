<!-- markdownlint-disable -->
<a href="https://www.appvia.io/"><img src="https://github.com/appvia/terraform-aws-cloudaccess-lza/blob/main/appvia_banner.jpg?raw=true" alt="Appvia Banner"/></a><br/><p align="right"> <a href="https://registry.terraform.io/modules/appvia/cloudaccess-lza/aws/latest"><img src="https://img.shields.io/static/v1?label=APPVIA&message=Terraform%20Registry&color=191970&style=for-the-badge" alt="Terraform Registry"/></a></a> <a href="https://github.com/appvia/terraform-aws-cloudaccess-lza/releases/latest"><img src="https://img.shields.io/github/release/appvia/terraform-aws-cloudaccess-lza.svg?style=for-the-badge&color=006400" alt="Latest Release"/></a> <a href="https://appvia-community.slack.com/join/shared_invite/zt-1s7i7xy85-T155drryqU56emm09ojMVA#/shared-invite/email"><img src="https://img.shields.io/badge/Slack-Join%20Community-purple?style=for-the-badge&logo=slack" alt="Slack Community"/></a> <a href="https://github.com/appvia/terraform-aws-cloudaccess-lza/graphs/contributors"><img src="https://img.shields.io/github/contributors/appvia/terraform-aws-cloudaccess-lza.svg?style=for-the-badge&color=FF8C00" alt="Contributors"/></a>

<!-- markdownlint-restore -->
<!--
  ***** CAUTION: DO NOT EDIT ABOVE THIS LINE ******
-->

![Github Actions](https://github.com/appvia/terraform-aws-cloudaccess-lza/actions/workflows/terraform.yml/badge.svg)

## Description

This Terraform module provisions the baseline infrastructure and access controls for an AWS Landing Zone environment. It establishes secure pipeline access patterns using OIDC authentication, implements IAM permission boundaries, and configures security monitoring through CIS CloudWatch alarms.

### Key Features

- **OIDC-based Pipeline Access**: Creates IAM roles with OIDC authentication for secure CI/CD pipeline access to AWS resources
- **IAM Permission Boundaries**: Enforces security guardrails on pipeline roles in both Management and Audit accounts
- **CIS CloudWatch Alarms**: Monitors and alerts on security events based on CIS AWS Foundations Benchmark
- **Multi-channel Notifications**: Supports email, Slack, and Microsoft Teams notifications for security alerts
- **Breakglass Access**: Optional emergency access users with MFA enforcement
- **AWS Support Integration**: Deploys AWS Support role across all accounts via CloudFormation StackSets
- **Cost Management**: Dedicated IAM policies and roles for cost visibility and management

### Supported Pipeline Types

The module supports creating OIDC roles for the following pipeline types:

- **Accelerator**: Manages landing zone configuration and deployment
- **Accounts**: Provisions and manages AWS accounts via Organizations
- **Bootstrap**: Handles initial landing zone setup
- **Compliance**: Manages security and compliance configurations
- **Cost Management**: Controls costs and budgets
- **Identity**: Manages IAM Identity Center (formerly AWS SSO)
- **Organizations**: Configures AWS Organizations structure

## Usage

### Basic Example

```hcl
module "landing_zone" {
  source  = "appvia/cloudaccess-lza/aws"
  version = "0.0.1"

  aws_accounts = {
    audit_account_id = "123456789012"
  }

  repositories = {
    accelerator = {
      url = "https://github.com/your-org/aws-accelerator-config"
    }
    identity = {
      url = "https://github.com/your-org/terraform-aws-identity"
    }
  }

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }

  providers = {
    aws.audit      = aws.audit
    aws.management = aws.management
  }
}
```

### Complete Example with All Features

```hcl
module "landing_zone" {
  source  = "appvia/cloudaccess-lza/aws"
  version = "0.0.1"

  aws_accounts = {
    audit_account_id = "123456789012"
  }

  enable_aws_support = true
  enable_breakglass  = true
  enable_cis_alarms  = true
  breakglass_users   = 2

  notifications = {
    email = {
      addresses = ["security@example.com", "ops@example.com"]
    }
    slack = {
      webhook_url = "https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
    }
  }

  repositories = {
    accelerator = {
      url       = "https://github.com/your-org/aws-accelerator-config"
      role_name = "lz-aws-accelerator"
      shared    = ["https://github.com/your-org/shared-repo"]
    }
    identity = {
      url       = "https://github.com/your-org/terraform-aws-identity"
      role_name = "lz-aws-identity"
    }
    compliance = {
      url = "https://github.com/your-org/aws-compliance"
    }
    cost_management = {
      url = "https://github.com/your-org/aws-cost-management"
    }
  }

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }

  providers = {
    aws.audit      = aws.audit
    aws.management = aws.management
  }
}
```

## CIS Alarms & Notifications

This module implements CIS AWS Foundations Benchmark security monitoring using CloudWatch alarms. The alarms monitor CloudTrail logs for security-relevant events and send notifications through your configured channels.

### Enabling CIS Alarms

CIS alarms are enabled by default (`enable_cis_alarms = true`). They monitor the AWS Control Tower organizational CloudTrail trail by default.

### Email Notifications

Configure email notifications to receive alerts:

```hcl
module "landing_zone" {
  source = "appvia/cloudaccess-lza/aws"

  enable_cis_alarms = true

  notifications = {
    email = {
      addresses = ["security@example.com", "compliance@example.com"]
    }
  }

  # ... other configuration
}
```

### Slack Notifications

Configure Slack notifications using an Incoming Webhook:

```hcl
module "landing_zone" {
  source = "appvia/cloudaccess-lza/aws"

  enable_cis_alarms = true

  notifications = {
    slack = {
      webhook_url = "https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXX"
    }
  }

  # ... other configuration
}
```

### Microsoft Teams Notifications

Configure Microsoft Teams notifications using an Incoming Webhook:

```hcl
module "landing_zone" {
  source = "appvia/cloudaccess-lza/aws"

  enable_cis_alarms = true

  notifications = {
    teams = {
      webhook_url = "https://outlook.office.com/webhook/..."
    }
  }

  # ... other configuration
}
```

### Multiple Notification Channels

You can configure multiple notification channels simultaneously:

```hcl
module "landing_zone" {
  source = "appvia/cloudaccess-lza/aws"

  enable_cis_alarms = true

  notifications = {
    email = {
      addresses = ["security@example.com"]
    }
    slack = {
      webhook_url = "https://hooks.slack.com/services/..."
    }
    teams = {
      webhook_url = "https://outlook.office.com/webhook/..."
    }
  }

  # ... other configuration
}
```

### Custom CloudWatch Log Group

By default, the module uses the AWS Control Tower organizational trail log group (`aws-controltower/CloudTrailLogs`). You can specify a different log group:

```hcl
module "landing_zone" {
  source = "appvia/cloudaccess-lza/aws"

  enable_cis_alarms             = true
  organization_log_group_name   = "my-custom-cloudtrail-logs"

  # ... other configuration
}
```

### Excluding Services from Unauthorized API Call Alerts

Some AWS services may generate false positives for unauthorized API call alerts. You can exclude additional services:

```hcl
module "landing_zone" {
  source = "appvia/cloudaccess-lza/aws"

  enable_cis_alarms = true
  unauthorized_api_calls_extra_excluded_services = [
    "s3.amazonaws.com",
    "dynamodb.amazonaws.com"
  ]

  # ... other configuration
}
```

## Breakglass Users

The module can provision emergency "breakglass" IAM users with administrator access to the management account. These users are intended for emergency access when normal authentication methods fail.

### Features

- **MFA Enforcement**: Breakglass users must use MFA for all operations (except MFA device management)
- **Administrator Access**: Full administrative privileges when authenticated with MFA
- **Configurable Count**: Create multiple breakglass users (default: 2)

### Enabling Breakglass Users

```hcl
module "landing_zone" {
  source = "appvia/cloudaccess-lza/aws"

  enable_breakglass = true
  breakglass_users  = 2  # Creates lza-breakglass0 and lza-breakglass1

  # ... other configuration
}
```

**Security Note**: After deployment, you must manually:
1. Configure MFA devices for each breakglass user
2. Securely store credentials in a separate system (e.g., password manager, vault)
3. Regularly rotate credentials according to your security policy

## AWS Support Role

The module can deploy the AWS Support Access role across all accounts in your organization using CloudFormation StackSets.

### Enabling AWS Support

```hcl
module "landing_zone" {
  source = "appvia/cloudaccess-lza/aws"

  enable_aws_support     = true
  aws_support_role_name  = "AWSSupportAccessRole"  # Default value
  aws_support_stack_name = "lz-aws-support-role"   # Default value

  # ... other configuration
}
```

This creates:
- A CloudFormation StackSet in the management account
- StackSet instances deployed to all accounts in the organization root
- An IAM role in each account allowing AWS Support to access resources

## Permission Boundaries

The module creates IAM permission boundaries to enforce security guardrails on pipeline roles:

### Default Permissions Boundary

Applied to all pipeline roles (except cost management). This boundary:
- Allows full administrative access
- Denies modification of the boundary policy itself
- Protects Terraform remote state S3 buckets from deletion
- Protects Terraform state lock DynamoDB tables from deletion

```hcl
module "landing_zone" {
  source = "appvia/cloudaccess-lza/aws"

  default_permissions_boundary_name = "lz-base-default-boundary"  # Default value

  # ... other configuration
}
```

### Cost Management Boundary

A separate boundary for cost management roles with restricted permissions:

```hcl
module "landing_zone" {
  source = "appvia/cloudaccess-lza/aws"

  costs_boundary_name = "lz-costs-boundary"  # Default value

  # ... other configuration
}
```

## Repository Configuration

Each repository configuration supports the following options:

```hcl
repositories = {
  <pipeline_type> = {
    # Required: Git repository URL (must be HTTPS)
    url = "https://github.com/your-org/repo-name"

    # Optional: IAM role name (defaults vary by pipeline type)
    role_name = "custom-role-name"

    # Optional: Additional repositories that can assume this role
    shared = [
      "https://github.com/your-org/shared-repo-1",
      "https://github.com/your-org/shared-repo-2"
    ]

    # Optional: Additional read-only IAM policy statements
    additional_read_permissions = {
      CustomReadPolicy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect   = "Allow"
            Action   = ["s3:GetObject", "s3:ListBucket"]
            Resource = "*"
          }
        ]
      })
    }

    # Optional: Additional read-write IAM policy statements
    additional_write_permissions = {
      CustomWritePolicy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect   = "Allow"
            Action   = ["dynamodb:PutItem", "dynamodb:DeleteItem"]
            Resource = "*"
          }
        ]
      })
    }
  }
}
```

## Provider Configuration

This module requires two AWS provider configurations:

```hcl
provider "aws" {
  alias  = "management"
  region = "us-east-1"
  # Configure for your management account
}

provider "aws" {
  alias  = "audit"
  region = "us-east-1"
  # Configure for your audit/security account
  assume_role {
    role_arn = "arn:aws:iam::123456789012:role/OrganizationAccountAccessRole"
  }
}

module "landing_zone" {
  source = "appvia/cloudaccess-lza/aws"

  # ... configuration

  providers = {
    aws.audit      = aws.audit
    aws.management = aws.management
  }
}
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
| <a name="input_notifications"></a> [notifications](#input\_notifications) | Configuration for the notifications | <pre>object({<br/>    # The name of the Lambda function to use for notifications<br/>    lambda_name = optional(string, "lz-ca-notifications-slack")<br/>    # A list of email addresses to send notifications to<br/>    email = optional(object({<br/>      # A list of email addresses to send notifications to<br/>      addresses = list(string)<br/>    }), null)<br/>    # The configuration for Slack notifications<br/>    slack = optional(object({<br/>      # The webhook URL for Slack notifications<br/>      webhook_url = string<br/>    }), null)<br/>    # The configuration for Microsoft Teams notifications<br/>    teams = optional(object({<br/>      # The webhook URL for Microsoft Teams notifications<br/>      webhook_url = string<br/>    }), null)<br/>  })</pre> | <pre>{<br/>  "email": {<br/>    "addresses": []<br/>  },<br/>  "lambda_name": "lz-ca-notifications-slack",<br/>  "slack": null,<br/>  "teams": null<br/>}</pre> | no |
| <a name="input_organization_log_group_name"></a> [organization\_log\_group\_name](#input\_organization\_log\_group\_name) | The name of the CloudWatch log group for the AWS Organization. If not provided, will use the default log group. | `string` | `"aws-controltower/CloudTrailLogs"` | no |
| <a name="input_repositories"></a> [repositories](#input\_repositories) | List of repository locations for the pipelines | <pre>object({<br/>    accelerator = optional(object({<br/>      # The URL for the repository containing the accelerator pipeline code. This should be a Git repository URL.<br/>      url = string<br/>      # The name of the IAM role to use when accessing the permissions<br/>      role_name = optional(string, "lz-aws-accelerator")<br/>      # A list of other repositories whom should have access to the terraform state<br/>      shared = optional(list(string), [])<br/>      # A map of additional permissions (in the form of IAM policy actions) that should be added to the role<br/>      additional_read_permissions = optional(map(string), {})<br/>      # A map of additional permissions (in the form of IAM policy actions) that should be added to the role<br/>      additional_write_permissions = optional(map(string), {})<br/>    }), null)<br/>    accounts = optional(object({<br/>      # The URL for the repository containing the accounts pipeline code. This should be a Git repository URL.<br/>      url = string<br/>      # The name of the IAM role to use when accessing the permissions<br/>      role_name = optional(string, "lz-aws-accounts")<br/>      # A list of other repositories whom should have access to the terraform state<br/>      shared = optional(list(string), [])<br/>      # A map of additional permissions (in the form of IAM policy actions) that should be added to the role<br/>      additional_read_permissions = optional(map(string), {})<br/>      # A map of additional permissions (in the form of IAM policy actions) that should be added to the role<br/>      additional_write_permissions = optional(map(string), {})<br/>    }), null)<br/>    bootstrap = optional(object({<br/>      # The URL for the repository containing the bootstrap pipeline code. This should be a Git repository URL.<br/>      url = string<br/>      # The name of the IAM role to use when accessing the permissions<br/>      role_name = optional(string, "lz-aws-bootstrap")<br/>      # A list of other repositories whom should have access to the terraform state<br/>      shared = optional(list(string), [])<br/>      # A map of additional permissions (in the form of IAM policy actions) that should be added to the role<br/>      additional_read_permissions = optional(map(string), {})<br/>      # A map of additional permissions (in the form of IAM policy actions) that should be added to the role<br/>      additional_write_permissions = optional(map(string), {})<br/>    }), null)<br/>    compliance = optional(object({<br/>      # The URL for the repository containing the compliance pipeline code. This should be a Git repository URL.<br/>      url = string<br/>      # The name of the IAM role to use when accessing the permissions<br/>      role_name = optional(string, "lz-aws-compliance")<br/>      # A list of other repositories whom should have access to the terraform state<br/>      shared = optional(list(string), [])<br/>      # A map of additional permissions (in the form of IAM policy actions) that should be added to the role<br/>      additional_read_permissions = optional(map(string), {})<br/>      # A map of additional permissions (in the form of IAM policy actions) that should be added to the role<br/>      additional_write_permissions = optional(map(string), {})<br/>    }), null)<br/>    cost_management = optional(object({<br/>      # The URL for the repository containing the cost management pipeline code. This should be a Git repository URL.<br/>      url = string<br/>      # The name of the IAM role to use when accessing the permissions<br/>      role_name = optional(string, "lz-aws-cost-management")<br/>      # A list of other repositories whom should have access to the terraform state <br/>      shared = optional(list(string), [])<br/>      # A map of additional permissions (in the form of IAM policy actions) that should be added to the role<br/>      additional_read_permissions = optional(map(string), {})<br/>      # A map of additional permissions (in the form of IAM policy actions) that should be added to the role<br/>      additional_write_permissions = optional(map(string), {})<br/>    }), null)<br/>    identity = optional(object({<br/>      # The URL for the repository containing the identity pipeline code. This should be a Git repository URL.<br/>      url = string<br/>      # The name of the IAM role to use when accessing the permissions<br/>      role_name = optional(string, "lz-aws-identity")<br/>      # A list of other repositories whom should have access to the terraform state<br/>      shared = optional(list(string), [])<br/>      # A map of additional permissions (in the form of IAM policy actions) that should be added to the role<br/>      additional_read_permissions = optional(map(string), {})<br/>      # A map of additional permissions (in the form of IAM policy actions) that should be added to the role<br/>      additional_write_permissions = optional(map(string), {})<br/>    }), null)<br/>    organizations = optional(object({<br/>      # The URL for the repository containing the organizations pipeline code. This should be a Git repository URL.<br/>      url = string<br/>      # The name of the IAM role to use when accessing the permissions<br/>      role_name = optional(string, "lz-aws-organizations")<br/>      # A list of other repositories whom should have access to the terraform state<br/>      shared = optional(list(string), [])<br/>      # A map of additional permissions (in the form of IAM policy actions) that should be added to the role<br/>      additional_read_permissions = optional(map(string), {})<br/>      # A map of additional permissions (in the form of IAM policy actions) that should be added to the role<br/>      additional_write_permissions = optional(map(string), {})<br/>    }), null)<br/>  })</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources | `map(string)` | `{}` | no |
| <a name="input_unauthorized_api_calls_extra_excluded_services"></a> [unauthorized\_api\_calls\_extra\_excluded\_services](#input\_unauthorized\_api\_calls\_extra\_excluded\_services) | Optional list of additional AWS services to exclude from unauthorized API call metric filter. | `list(string)` | `[]` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
