
locals {
  # Get all the accounts in the organization
  accounts = {
    for x in data.aws_organizations_organizational_unit_descendant_accounts.this.accounts :
    x.name => x.id if x.status == "ACTIVE"
  }
  # The default boundary created by the lza module, this SHOULD be used by the majority 
  # of pipelines. The boundary restrictes changes to crucial resources
  default_permissions_boundary_name = module.landing_zone.default_permissions_boundary.name
  # The default permissive boundary created by the lza module - this can be used by 
  # pipelines that need to create additional IAM roles
  permissive_permissions_boundary_name = module.landing_zone.default_permissive_boundary_name
}

