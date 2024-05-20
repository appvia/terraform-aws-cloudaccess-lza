variable "aws_accounts" {
  description = "Map of AWS account names to their account IDs"
  type        = map(string)
  default = {
    management = "123456789012"
    network    = "123456789012"
  }
}

variable "region" {
  description = "AWS Region to deploy resources in"
  type        = string
  default     = "us-west-2"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
