
## Provision a MFA policy for the IAM group 
# tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "breakglass" {
  statement {
    sid    = "AllowBasicVisibilityWithoutMfa"
    effect = "Allow"
    actions = [
      "iam:GetAccountPasswordPolicy",
      "iam:GetAccountSummary",
      "iam:ListAccountAliases",
      "iam:ListUsers",
      "iam:ListVirtualMFADevices",
    ]
    resources = ["*", ]
  }

  statement {
    sid    = "MFAPersonalCreate"
    effect = "Allow"
    actions = [
      "iam:CreateVirtualMFADevice",
      "iam:DeleteVirtualMFADevice"
    ]
    resources = [
      "arn:aws:iam::${local.account_id}:mfa/&{aws:username}",
    ]
  }

  statement {
    sid    = "AllowIndividualUserToDeactivateOnlyTheirOwnMFAOnlyWhenUsingMFA"
    effect = "Allow"
    actions = [
      "iam:DeleteVirtualMFADevice",
    ]
    resources = [
      "arn:aws:iam::${local.account_id}:mfa/&{aws:username}",
      "arn:aws:iam::${local.account_id}:user/&{aws:username}",
    ]
    condition {
      test     = "Bool"
      variable = "aws:MultiFactorAuthPresent"
      values   = ["true", ]
    }
  }

  statement {
    effect = "Allow"
    actions = [
      "iam:GetUser",
      "iam:ListGroupsForUser",
    ]
    resources = [
      "arn:aws:iam::${local.account_id}:user/&{aws:username}",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "iam:ListGroups",
    ]
    resources = [
      "arn:aws:iam::${local.account_id}:group/",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "iam:ListAttachedGroupPolicies",
      "iam:ListGroupPolicies",
    ]
    resources = [
      "arn:aws:iam::${local.account_id}:group/*",
    ]
  }

  statement {
    sid    = "AllowToListOnlyOwnMFA"
    effect = "Allow"
    actions = [
      "iam:ListMFADevices",
    ]
    resources = [
      "arn:aws:iam::*:mfa/*",
      "arn:aws:iam::*:user/&{aws:username}"
    ]
  }

  statement {
    sid    = "AllowManageOwnUserMFA"
    effect = "Allow"
    actions = [
      "iam:ChangePassword",
      "iam:CreateLoginProfile",
      "iam:GetLoginProfile",
      "iam:ListAccessKeys",
      "iam:ListAccessKeys",
      "iam:ListAttachedUserPolicies",
      "iam:ListSSHPublicKeys",
      "iam:UpdateLoginProfile",
      "iam:UpdateUser",
    ]
    resources = [
      "arn:aws:iam::${local.account_id}:user/&{aws:username}",
    ]
  }

  statement {
    sid    = "AllowUserToManageOwnMFA"
    effect = "Allow"

    actions = [
      "iam:CreateVirtualMFADevice",
      "iam:DeleteVirtualMFADevice",
      "iam:EnableMFADevice",
      "iam:ResyncMFADevice"
    ]

    resources = [
      "arn:aws:iam::*:mfa/&{aws:username}",
      "arn:aws:iam::*:user/&{aws:username}"
    ]
  }

  statement {
    sid    = "KeysAndCertificates"
    effect = "Allow"
    actions = [
      "iam:GetSSHPublicKey",
      "iam:ListSSHPublicKeys",
      "iam:ListSigningCertificates",
    ]
    resources = [
      "arn:aws:iam::${local.account_id}:user/&{aws:username}",
    ]
  }

  statement {
    sid    = "AllowUserToDeactivateOnlyOwnMFAWhenUsingMFA"
    effect = "Allow"
    actions = [
      "iam:DeactivateMFADevice"
    ]
    resources = [
      "arn:aws:iam::*:mfa/&{aws:username}",
      "arn:aws:iam::*:user/&{aws:username}"
    ]
    condition {
      test     = "Bool"
      variable = "aws:MultiFactorAuthPresent"
      values   = ["true"]
    }
  }

  statement {
    sid    = "AllowBasicVisibilityWhenLoggedInWithMFA"
    effect = "Allow"
    actions = [
      "iam:GenerateServiceLastAccessedDetails",
      "iam:GetGroup",
      "iam:GetUser",
      "iam:ListAttachedUserPolicies",
      "iam:ListGroupsForUser",
      "iam:ListPolicies",
      "iam:ListServiceSpecificCredentials",
      "iam:ListUserPolicies",
      "iam:ListUserTags",
    ]
    resources = ["*"]
    condition {
      test     = "Bool"
      variable = "aws:MultiFactorAuthPresent"
      values   = ["true", ]
    }
  }
}

## Provision the IAM policy used to enforce MFA 
resource "aws_iam_policy" "breakglass" {
  count = var.enable_breakglass ? 1 : 0

  name        = "lza-breakglass-mfa"
  description = "Ensures the user MUST use MFA to access the account, but allows basic visibility without MFA."
  policy      = data.aws_iam_policy_document.breakglass.json

  provider = aws.management
}

## Provision a group for the breakglass users 
# tfsec:ignore:aws-iam-enforce-group-mfa 
resource "aws_iam_group" "breakglass" {
  count = var.enable_breakglass ? 1 : 0

  name = "lza-breakglass"

  provider = aws.management
}

## Attach the MFA policy to the breakglass group 
resource "aws_iam_group_policy_attachment" "test-attach" {
  count = var.enable_breakglass ? 1 : 0

  group      = aws_iam_group.breakglass[0].name
  policy_arn = aws_iam_policy.breakglass[0].arn

  provider = aws.management
}

## Assign the administator policy to the breakglass group 
resource "aws_iam_group_policy_attachment" "breakglass" {
  count = var.enable_breakglass ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  group      = aws_iam_group.breakglass[0].name

  provider = aws.management
}

## Create the two breakglass users 
resource "aws_iam_user" "breakglass" {
  count = var.enable_breakglass ? var.breakglass_users : 0

  name = "lza-breakglass${count.index}"
  tags = var.tags

  provider = aws.management
}

## Attach the breakglass users to the breakglass group 
resource "aws_iam_user_group_membership" "breakglass" {
  count = var.enable_breakglass ? var.breakglass_users : 0

  user   = aws_iam_user.breakglass[count.index].name
  groups = [aws_iam_group.breakglass[0].name]

  provider = aws.management
}
