
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
  version = "2.0.2"

  name                    = var.repositories.compliance.role_name
  description             = "Used to manage and configure the compliance security stack"
  permission_boundary_arn = aws_iam_policy.default_permissions_boundary_audit.arn
  repository              = var.repositories.compliance.url
  shared_repositories     = var.repositories.compliance.shared
  tags                    = local.tags

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
