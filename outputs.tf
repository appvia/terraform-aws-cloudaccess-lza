output "default_permissions_boundary_name" {
  description = "The name of the default permissions boundary"
  value       = var.default_permissions_boundary_name
}

output "default_permissive_boundary_name" {
  description = "The name of the default permissive boundary"
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

