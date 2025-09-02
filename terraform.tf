
terraform {
  required_version = ">= 1.1.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.11"
      configuration_aliases = [
        aws.audit,
        aws.management,
      ]
    }
  }
}
