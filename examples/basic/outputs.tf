output "default_permission_boundary_name" {
  description = "The name of the permission boundary to attach to all roles"
  value       = module.landing_zone.default_permission_boundary_name
}

output "default_permissive_boundary_name" {
  description = "The name of the permissive boundary to attach to all roles"
  value       = module.landing_zone.default_permissive_boundary_name
}
