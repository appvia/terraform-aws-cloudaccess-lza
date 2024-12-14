variable "aws_accounts" {
  description = "Map of AWS account names to their account IDs"
  type = object({
    audit_account_id = string
  })
}

variable "aws_support_stack_name" {
  description = "Name of the stackset used to deploy the aws support role"
  type        = string
  default     = "lza-aws-support-role"
}

variable "costs_boundary_name" {
  description = "Name of the IAM policy to use as a permissions boundary for cost-related roles"
  type        = string
  default     = "lza-costs-boundary"
}

variable "default_permissions_boundary_name" {
  description = "Name of the default IAM policy used by roles we provision"
  type        = string
  default     = "lza-base-default-boundary"
}

variable "enable_securityhub_alarms" {
  description = "Indicates if we should enable SecurityHub alarms"
  type        = bool
  default     = false
}

variable "securityhub_sns_topic_name" {
  description = "Name of the SNS topic to send Security Hub findings to"
  type        = string
  default     = "lza-securityhub-alerts"
}

variable "securityhub_event_bridge_rule_name" {
  description = "Display name of the EventBridge rule for Security Hub findings"
  type        = string
  default     = "lza-securityhub-alerts"
}

variable "securityhub_severity_filter" {
  description = "Indicates if we should enable SecurityHub"
  type        = list(string)
  default     = ["CRITICAL", "HIGH"]
}

variable "securityhub_lambda_role_name" {
  description = "Name of the IAM role for the Security Hub Lambda function"
  type        = string
  default     = "lza-securityhub-lambda-role"
}

variable "securityhub_lambda_function_name" {
  description = "Name of the Security Hub Lambda function"
  type        = string
  default     = "lza-securityhub-lambda-forwarder"
}

variable "securityhub_lambda_runtime" {
  description = "Runtime for the Security Hub Lambda function"
  type        = string
  default     = "python3.12"
}

variable "aws_support_role_name" {
  description = "Name of the AWS Support role"
  type        = string
  default     = "AWSSupportAccessRole"
}

variable "enable_aws_support" {
  description = "Indicates if we should enable AWS Support role"
  type        = bool
  default     = true
}

variable "enable_cis_alarms" {
  description = "Indicates if we should enable CIS alerts"
  type        = bool
  default     = true
}

variable "notifications" {
  description = "Configuration for the notifications"
  type = object({
    lamdba_name = optional(string, "lza-ca-notifications-slack")
    email = optional(object({
      addresses = list(string)
    }), null)
    slack = optional(object({
      webhook_url = string
    }), null)
    teams = optional(object({
      webhook_url = string
    }), null)
  })
  default = {
    lamdba_name = "lza-ca-notifications-slack"
    email = {
      addresses = []
    }
    slack = null
    teams = null
  }
}

variable "breakglass_users" {
  description = "The number of breakglass users to create"
  type        = number
  default     = 2
}

variable "enable_breakglass" {
  description = "Indicates if we should enable breakglass users and group"
  type        = bool
  default     = false
}

variable "repositories" {
  description = "List of repository locations for the pipelines"
  type = object({
    accelerator = optional(object({
      url       = string
      role_name = optional(string, "lza-accelerator")
    }), null)
    bootstrap = optional(object({
      url       = string
      role_name = optional(string, "lza-bootstrap")
    }), null)
    compliance = optional(object({
      url       = string
      role_name = optional(string, "lza-compliance")
    }), null)
    cost_management = optional(object({
      url       = string
      role_name = optional(string, "lza-cost-management")
    }), null)
    identity = optional(object({
      url       = string
      role_name = optional(string, "lza-identity")
    }), null)
    organizations = optional(object({
      url       = string
      role_name = optional(string, "lza-organization")
    }), null)
  })
  default = {}
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
}

variable "accounts_id_to_name" {
  description = "A mapping of account id and account name - used by notification lamdba to map an account ID to a human readable name"
  type        = map(string)
  default     = {}
}

variable "identity_center_start_url" {
  description = "The start URL of your Identity Center instance"
  type        = string
  default     = null
}

variable "security_hub_identity_center_role" {
  description = "The name of the role to use when redirecting through Identity Center for security hub events"
  type        = string
  default     = null
}

variable "cloudwatch_identity_center_role" {
  description = "The name of the role to use when redirecting through Identity Center for cloudwatch events"
  type        = string
  default     = null
}
