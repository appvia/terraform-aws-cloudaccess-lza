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
    # The name of the Lambda function to use for notifications
    lambda_name = optional(string, "lz-ca-notifications-slack")
    # A list of email addresses to send notifications to
    email = optional(object({
      # A list of email addresses to send notifications to
      addresses = list(string)
    }), null)
    # The configuration for Slack notifications
    slack = optional(object({
      # The webhook URL for Slack notifications
      webhook_url = string
    }), null)
    # The configuration for Microsoft Teams notifications
    teams = optional(object({
      # The webhook URL for Microsoft Teams notifications
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
      # The URL for the repository containing the accelerator pipeline code. This should be a Git repository URL.
      url = string
      # The name of the IAM role to use when accessing the permissions
      role_name = optional(string, "lz-aws-accelerator")
      # A list of other repositories whom should have access to the terraform state
      shared = optional(list(string), [])
      # A map of additional permissions (in the form of IAM policy actions) that should be added to the role
      additional_read_permissions = optional(map(string), {})
      # A map of additional permissions (in the form of IAM policy actions) that should be added to the role
      additional_write_permissions = optional(map(string), {})
    }), null)
    accounts = optional(object({
      # The URL for the repository containing the accounts pipeline code. This should be a Git repository URL.
      url = string
      # The name of the IAM role to use when accessing the permissions
      role_name = optional(string, "lz-aws-accounts")
      # A list of other repositories whom should have access to the terraform state
      shared = optional(list(string), [])
      # A map of additional permissions (in the form of IAM policy actions) that should be added to the role
      additional_read_permissions = optional(map(string), {})
      # A map of additional permissions (in the form of IAM policy actions) that should be added to the role
      additional_write_permissions = optional(map(string), {})
    }), null)
    bootstrap = optional(object({
      # The URL for the repository containing the bootstrap pipeline code. This should be a Git repository URL.
      url = string
      # The name of the IAM role to use when accessing the permissions
      role_name = optional(string, "lz-aws-bootstrap")
      # A list of other repositories whom should have access to the terraform state
      shared = optional(list(string), [])
      # A map of additional permissions (in the form of IAM policy actions) that should be added to the role
      additional_read_permissions = optional(map(string), {})
      # A map of additional permissions (in the form of IAM policy actions) that should be added to the role
      additional_write_permissions = optional(map(string), {})
    }), null)
    compliance = optional(object({
      # The URL for the repository containing the compliance pipeline code. This should be a Git repository URL.
      url = string
      # The name of the IAM role to use when accessing the permissions
      role_name = optional(string, "lz-aws-compliance")
      # A list of other repositories whom should have access to the terraform state
      shared = optional(list(string), [])
      # A map of additional permissions (in the form of IAM policy actions) that should be added to the role
      additional_read_permissions = optional(map(string), {})
      # A map of additional permissions (in the form of IAM policy actions) that should be added to the role
      additional_write_permissions = optional(map(string), {})
    }), null)
    cost_management = optional(object({
      # The URL for the repository containing the cost management pipeline code. This should be a Git repository URL.
      url = string
      # The name of the IAM role to use when accessing the permissions
      role_name = optional(string, "lz-aws-cost-management")
      # A list of other repositories whom should have access to the terraform state 
      shared = optional(list(string), [])
      # A map of additional permissions (in the form of IAM policy actions) that should be added to the role
      additional_read_permissions = optional(map(string), {})
      # A map of additional permissions (in the form of IAM policy actions) that should be added to the role
      additional_write_permissions = optional(map(string), {})
    }), null)
    identity = optional(object({
      # The URL for the repository containing the identity pipeline code. This should be a Git repository URL.
      url = string
      # The name of the IAM role to use when accessing the permissions
      role_name = optional(string, "lz-aws-identity")
      # A list of other repositories whom should have access to the terraform state
      shared = optional(list(string), [])
      # A map of additional permissions (in the form of IAM policy actions) that should be added to the role
      additional_read_permissions = optional(map(string), {})
      # A map of additional permissions (in the form of IAM policy actions) that should be added to the role
      additional_write_permissions = optional(map(string), {})
    }), null)
    organizations = optional(object({
      # The URL for the repository containing the organizations pipeline code. This should be a Git repository URL.
      url = string
      # The name of the IAM role to use when accessing the permissions
      role_name = optional(string, "lz-aws-organizations")
      # A list of other repositories whom should have access to the terraform state
      shared = optional(list(string), [])
      # A map of additional permissions (in the form of IAM policy actions) that should be added to the role
      additional_read_permissions = optional(map(string), {})
      # A map of additional permissions (in the form of IAM policy actions) that should be added to the role
      additional_write_permissions = optional(map(string), {})
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
