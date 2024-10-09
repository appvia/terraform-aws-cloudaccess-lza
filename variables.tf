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

variable "enable_securityhub_alarms" {
  description = "Indicates if we should enable SecurityHub alarms"
  type        = bool
  default     = true
}

variable "enforcable_tags" {
  description = "List of enforceable tags"
  type        = list(string)
  default     = []
}

variable "enforcable_tagging_policy_name" {
  description = "Name of the IAM policy to use as a permissions boundary for enforceable tags"
  type        = string
  default     = "lza-enforceable-tags-boundary"
}

variable "enforcable_tagging_resources" {
  description = "List of enforceable tagging resources"
  type        = list(string)
  default = [
    "arn:aws:autoscaling:*:*:autoScalingGroup:*",
    "arn:aws:backup:*:*:backup-plan/*",
    "arn:aws:backup:*:*:backup-vault/*",
    "arn:aws:cloudtrail:*:*:trail/*",
    "arn:aws:logs:*:*:log-anomaly-detector/*",
    "arn:aws:logs:*:*:log-group/*",
    "arn:aws:ec2:*:*:client-vpn-endpoint/*",
    "arn:aws:ec2:*:*:flow-log/*",
    "arn:aws:ec2:*:*:instance/*",
    "arn:aws:ec2:*:*:internet-gateway/*",
    "arn:aws:ec2:*:*:key-pair/*",
    "arn:aws:ec2:*:*:launch-template/*",
    "arn:aws:ec2:*:*:natgateway/*",
    "arn:aws:ec2:*:*:network-acl/*",
    "arn:aws:ec2:*:*:route-table/*",
    "arn:aws:ec2:*:*:security-group/*",
    "arn:aws:ec2:*:*:snapshot/*",
    "arn:aws:ec2:*:*:transit-gateway-attachment/*",
    "arn:aws:ec2:*:*:volume/*",
    "arn:aws:ec2:*:*:vpc-endpoint/*",
    "arn:aws:ec2:*:*:vpc-peering-connection/*",
    "arn:aws:ec2:*:*:vpc/*",
    "arn:aws:ec2:*:*:vpn-connection/*",
    "arn:aws:ecs:*:*:cluster/*",
    "arn:aws:ecs:*:*:service/*",
    "arn:aws:eks:*:*:cluster/*",
    "arn:aws:elasticfilesystem:*:*:access-point/*",
    "arn:aws:elasticfilesystem:*:*:file-system/*",
    "arn:aws:elasticloadbalancing:*:*:listener/*",
    "arn:aws:elasticloadbalancing:*:*:loadbalancer/*",
    "arn:aws:elasticloadbalancing:*:*:rule/*",
    "arn:aws:elasticloadbalancing:*:*:targetgroup/*",
    "arn:aws:lambda:*:*:function:*",
    "arn:aws:rds:*:*::*",
    "arn:aws:sns:*:*:topic/*",
    "arn:aws:sqs:*:*:queue/*",
  ]
}

variable "enforcable_tagging_actions" {
  description = "List of enforceable tagging actions"
  type        = list(string)
  default = [
    "autoscaling:CreateAutoScalingGroup",
    "autoscaling:CreateOrUpdateTags",
    "backup:CreateBackupPlan",
    "backup:CreateBackupVault",
    "cloudtrail:CreateTrail",
    "logs:CreateLogAnomalyDetector",
    "logs:CreateLogGroup",
    "ec2:CreateClientVpnEndpoint",
    "ec2:CreateFlowLogs",
    "ec2:CreateInternetGateway",
    "ec2:CreateKeyPair",
    "ec2:CreateLaunchTemplate",
    "ec2:CreateNatGateway",
    "ec2:CreateNetworkAcl",
    "ec2:CreateRouteTable",
    "ec2:CreateSecurityGroup",
    "ec2:CreateSnapshots",
    "ec2:CreateTransitGatewayVpcAttachment",
    "ec2:CreateVolume",
    "ec2:CreateVpc",
    "ec2:CreateVpcEndpoint",
    "ec2:CreateVpcPeeringConnection",
    "ec2:CreateVpnConnection",
    "ecs:CreateCluster",
    "ecs:CreateService",
    "eks:CreateCluster",
    "eks:CreateFargateProfile",
    "eks:CreateNodegroup",
    "elasticfilesystem:CreateAccessPoint",
    "elasticfilesystem:CreateFileSystem",
    "elasticloadbalancing:CreateListener",
    "elasticloadbalancing:CreateLoadBalancer",
    "elasticloadbalancing:CreateRule",
    "elasticloadbalancing:CreateTargetGroup",
    "lambda:CreateFunction",
    "rds:CreateDBCluster",
    "rds:CreateDBClusterEndpoint",
    "rds:CreateDBClusterSnapshot",
    "rds:CreateDBInstance",
    "rds:CreateDBInstanceReadReplica",
    "rds:CreateGlobalCluster",
    "sns:CreateTopic",
    "sqs:CreateQueue",
  ]
}

variable "securityhub_sns_topic_name" {
  description = "Name of the SNS topic to send Security Hub findings to"
  type        = string
  default     = "lza-securityhub-alerts"
}

variable "securityhub_event_bridge_rule_name" {
  description = "Display name of the EventBridge rule for Security Hub findings"
  type        = string
  default     = "lza-securityhub-alerts"
}

variable "securityhub_severity_filter" {
  description = "Indicates if we should enable SecurityHub"
  type        = list(string)
  default     = ["CRITICAL", "HIGH"]
}

variable "securityhub_lambda_role_name" {
  description = "Name of the IAM role for the Security Hub Lambda function"
  type        = string
  default     = "lza-securityhub-lambda-role"
}

variable "securityhub_lambda_function_name" {
  description = "Name of the Security Hub Lambda function"
  type        = string
  default     = "lza-securityhub-lambda-forwarder"
}

variable "securityhub_lambda_runtime" {
  description = "Runtime for the Security Hub Lambda function"
  type        = string
  default     = "python3.12"
}

variable "securityhub_lambda_log_group_kms_alias" {
  description = "Name of the KMS alias for the CloudWatch log group"
  type        = string
  default     = "alias/accelerator/kms/cloudwatch/key"
}

variable "permissive_permissions_boundary_name" {
  description = "Name of the permissive IAM policy to use as a permissions boundary"
  type        = string
  default     = "lza-permissive-boundary"
}

variable "aws_support_role_name" {
  description = "Name of the AWS Support role"
  type        = string
  default     = "AWSSupportAccessRole"
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

variable "notifications" {
  description = "Configuration for the notifications"
  type = object({
    email = optional(object({
      addresses = list(string)
    }), null)
    slack = optional(object({
      webhook_url = string
    }), null)
    teams = optional(object({
      webhook_url = string
    }), null)
  })
  default = {
    email = {
      addresses = []
    }
    slack = null
    teams = null
  }
}

variable "breakglass_users" {
  description = "The number of breakglass users to create"
  type        = number
  default     = 2
}

variable "enable_breakglass" {
  description = "Indicates if we should enable breakglass users and group"
  type        = bool
  default     = false
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
    cost_management = optional(object({
      url       = string
      role_name = optional(string, "lza-cost-management")
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

variable "accounts_id_to_name" {
  description = "A mapping of account id and account name - used by notification lamdba to map an account ID to a human readable name"
  type        = map(string)
  default     = {}
}

variable "identity_center_start_url" {
  description = "The start URL of your Identity Center instance"
  type        = string
  default     = null
}

variable "security_hub_identity_center_role" {
  description = "The name of the role to use when redirecting through Identity Center for security hub events"
  type        = string
  default     = null
}

variable "cloudwatch_identity_center_role" {
  description = "The name of the role to use when redirecting through Identity Center for cloudwatch events"
  type        = string
  default     = null
}
