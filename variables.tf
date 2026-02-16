variable "aws_accounts" {
  description = "Map of AWS account names to their account IDs"
  type = object({
    audit_account_id = string
  })
}

variable "aws_support_stack_name" {
  description = "Name of the stackset used to deploy the aws support role"
  type        = string
  default     = "lz-aws-support-role"
}

variable "costs_boundary_name" {
  description = "Name of the IAM policy to use as a permissions boundary for cost-related roles"
  type        = string
  default     = "lz-costs-boundary"
}

variable "default_permissions_boundary_name" {
  description = "Name of the default IAM policy used by roles we provision"
  type        = string
  default     = "lz-base-default-boundary"
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
    lambda_name = optional(string, "lz-ca-notifications-slack")
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
    lambda_name = "lz-ca-notifications-slack"
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
      role_name = optional(string, "lz-aws-accelerator")
      shared    = optional(list(string), [])
    }), null)
    accounts = optional(object({
      url       = string
      role_name = optional(string, "lz-aws-accounts")
      shared    = optional(list(string), [])
    }), null)
    bootstrap = optional(object({
      url       = string
      role_name = optional(string, "lz-aws-bootstrap")
      shared    = optional(list(string), [])
    }), null)
    compliance = optional(object({
      url       = string
      role_name = optional(string, "lz-aws-compliance")
      shared    = optional(list(string), [])
    }), null)
    cost_management = optional(object({
      url       = string
      role_name = optional(string, "lz-aws-cost-management")
      shared    = optional(list(string), [])
    }), null)
    identity = optional(object({
      url       = string
      role_name = optional(string, "lz-aws-identity")
      shared    = optional(list(string), [])
    }), null)
    organizations = optional(object({
      url       = string
      role_name = optional(string, "lz-aws-organizations")
      shared    = optional(list(string), [])
    }), null)
  })
  default = {}
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "organization_log_group_name" {
  description = "The name of the CloudWatch log group for the AWS Organization. If not provided, will use the default log group."
  type        = string
  default     = "aws-controltower/CloudTrailLogs"
}

variable "unauthorized_api_calls_extra_excluded_services" {
  description = "Optional list of additional AWS services to exclude from unauthorized API call metric filter."
  type        = list(string)
  default     = []
}
