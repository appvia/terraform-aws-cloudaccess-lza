variable "aws_accounts" {
  description = "Map of AWS account names to their account IDs"
  type = object({
    network_account_id      = optional(string, "")
    remoteaccess_account_id = optional(string, "")
  })
}

variable "costs_boundary_name" {
  description = "Name of the IAM policy to use as a permissions boundary for cost-related roles"
  type        = string
  default     = "lza-costs-boundary"
}

variable "cloudaccess_terraform_state_ro_policy_name" {
  description = "Name of the IAM policy to attach to the CloudAccess Terraform state role"
  type        = string
  default     = "lza-cloudaccess-tfstate-ro"
}

variable "cloudaccess_terraform_state_rw_policy_name" {
  description = "Name of the IAM policy to attach to the CloudAccess Terraform state role"
  type        = string
  default     = "lza-cloudaccess-tfstate-rw"
}

variable "default_permissions_boundary_name" {
  description = "Name of the default IAM policy to use as a permissions boundary"
  type        = string
  default     = "lza-default-boundary"
}

variable "enable_securityhub_alarms" {
  description = "Indicates if we should enable SecurityHub alarms"
  type        = bool
  default     = true
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

variable "permissive_permissions_boundary_name" {
  description = "Name of the permissive IAM policy to use as a permissions boundary"
  type        = string
  default     = "lza-permissive-boundary"
}

variable "aws_support_role_name" {
  description = "Name of the AWS Support role"
  type        = string
  default     = "AWSSupportAccess"
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
    email = optional(object({
      addresses = list(string)
    }), null)
    slack = optional(object({
      webhook_url = string
      channel     = string
    }), null)
    teams = optional(object({
      webhook_url = string
    }), null)
  })
  default = {
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

variable "scm_name" {
  description = "Name of the source control management system (github or gitlab)"
  type        = string
  default     = "github"

  validation {
    condition     = can(regex("^(github|gitlab)$", var.scm_name))
    error_message = "SCM name must be either 'github' or 'gitlab'"
  }
}

variable "repositories" {
  description = "List of repository locations for the pipelines"
  type = object({
    accelerator = optional(object({
      url       = string
      role_name = optional(string, "lza-accelerator")
    }), null)
    connectivity = optional(object({
      url       = string
      role_name = optional(string, "lza-connectivity")
    }), null)
    cost_management = optional(object({
      url       = string
      role_name = optional(string, "lza-cost-management")
    }), null)
    firewall = optional(object({
      url       = string
      role_name = optional(string, "lza-firewall")
    }), null)
    identity = optional(object({
      url       = string
      role_name = optional(string, "lza-identity")
    }), null)
  })
  default = {}
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
}
