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
    lambda_name = optional(string, "lza-ca-notifications-slack")
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
    lambda_name = "lza-ca-notifications-slack"
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
    accounts = optional(object({
      url       = string
      role_name = optional(string, "lza-accounts")
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
