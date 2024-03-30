variable "aws_accounts" {
  description = "Map of AWS account names to their account IDs"
  type = object({
    management_account_id = string
    network_account_id    = string
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

variable "enable_cis_alarms" {
  description = "Indicates if we should enable CIS alerts"
  type        = bool
  default     = true
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
  description = "Name of the secret in AWS Secrets Manager that contains the secrets"
  type        = string
  default     = ""
}

variable "landing_zone_repositories" {
  description = "List of repository locations for the landing zone functionality"
  type = object({
    accelerator_repository_url  = optional(string)
    connectivity_repository_url = optional(string)
    firewall_repository_url     = optional(string)
    identity_repository_url     = optional(string)
  })
  default = {
    accelerator_repository_url  = ""
    connectivity_repository_url = ""
    firewall_repository_url     = ""
    identity_repository_url     = ""
  }
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
}
