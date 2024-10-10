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
