output "default_permission_boundary_name" {
  description = "The name of the default permissions iam boundary"
  value       = var.default_permissions_boundary_name
}

output "default_permissive_boundary_name" {
  description = "The name of the default permissive iam boundary"
  value       = var.permissive_permissions_boundary_name
}

output "cloudaccess_terraform_state_ro_policy_name" {
  description = "Name of the IAM policy to attach to the CloudAccess Terraform state role"
  value       = var.cloudaccess_terraform_state_ro_policy_name
}

output "cloudaccess_terraform_state_rw_policy_name" {
  description = "Name of the IAM policy to attach to the CloudAccess Terraform state role"
  value       = var.cloudaccess_terraform_state_rw_policy_name
}

output "identity_role_rw_name" {
  description = "The name of the IAM readwrite role which can be assumed by the identity stack in all accounts"
  value       = local.identity_role_rw_name
}

output "identity_role_ro_name" {
  description = "The name of the IAM readonly role which can be assumed by the identity stack in all accounts"
  value       = local.identity_role_ro_name
}

output "identity_stack_name" {
  description = "The name of the identity stack"
  value       = local.identity_stack_name
}

