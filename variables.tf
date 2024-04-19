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

variable "region" {
  description = "AWS region to deploy into"
  type        = string
}

variable "notification_emails" {
  description = "List of email addresses to send notifications to"
  type        = list(string)
  default     = []
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

variable "enable_slack_notifications" {
  description = "Indicates if we should enable Slack notifications"
  type        = bool
  default     = false
}

variable "enable_teams_notifications" {
  description = "Indicates if we should enable Teams notifications"
  type        = bool
  default     = false
}

variable "notification_secret_name" {
  description = "Name of the secret in AWS Secrets Manager that contains the secrets for notifications"
  type        = string
  default     = ""
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
