
## Provision the iam boundary within the audit account
resource "aws_iam_policy" "default_permissions_boundary_audit" {
  name        = var.default_permissions_boundary_name
  description = "Used by the LZA pipelines to enforce permissions"
  policy      = data.aws_iam_policy_document.default_permissions_boundary["audit"].json
  tags        = local.tags

  provider = aws.audit
}

## Used to provision the aws compliance security stack
module "audit_compliance" {
  count   = var.repositories.compliance != null ? 1 : 0
  source  = "appvia/oidc/aws//modules/role"
  version = "3.2.0"

  name                       = var.repositories.compliance.role_name
  description                = "Used to manage and configure the compliance security stack"
  permission_boundary_arn    = aws_iam_policy.default_permissions_boundary_audit.arn
  repository                 = var.repositories.compliance.url
  read_only_inline_policies  = var.repositories.compliance.additional_read_permissions
  read_write_inline_policies = var.repositories.compliance.additional_write_permissions
  shared_repositories        = var.repositories.compliance.shared
  tags                       = local.tags

  common_provider             = var.common_provider
  azuredevops_organization_id = var.azuredevops_organization_id
  # This role runs in the audit account, a spoke of the management-account hub where the Azure
  # DevOps OIDC provider is federated. When common_provider is "azuredevops", it trusts its
  # counterpart role in the management account (module.audit_compliance_management) via
  # sts:AssumeRole instead of federating OIDC directly - see terraform-aws-lza-bootstrap's
  # iam_roles_azuredevops vs iam_roles_azuredevops_management split for the same pattern.
  azuredevops_primary_role_account_id = var.common_provider == "azuredevops" ? local.management_account_id : null

  read_only_policy_arns = [
    "arn:aws:iam::aws:policy/AWSSSODirectoryReadOnly",
    "arn:aws:iam::aws:policy/AWSSSOReadOnly",
    "arn:aws:iam::aws:policy/IAMReadOnlyAccess",
    "arn:aws:iam::aws:policy/ReadOnlyAccess"
  ]

  read_write_policy_arns = [
    "arn:aws:iam::aws:policy/AdministratorAccess",
  ]

  providers = {
    aws = aws.audit
  }
}
