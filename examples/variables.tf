variable "aws_accounts" {
  description = "Map of AWS account names to their account IDs"
  type        = map(string)
}

variable "provider_session_name" {
  description = "Name of the session to use when assuming the IAM role"
  type        = string
  default     = "terraform-aws-cloudaccess"
}

variable "provider_web_identity_token_file" {
  description = "Path to the web identity token file"
  type        = string
  default     = "/tmp/web_identity_token_file"
}

variable "region" {
  description = "AWS Region to deploy resources in"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
}
