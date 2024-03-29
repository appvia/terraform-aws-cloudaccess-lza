
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  alias  = "management"
  region = "us-east-1"
}

provider "aws" {
  alias  = "network"
  region = "us-east-1"
}

module "test" {
  source = "../"

  aws_accounts = {
    management_account_id = "123456789012"
    network_account_id    = "123456789012"
  }
  region = "us-east-1"
  tags = {
    Name = "test"
  }

  providers = {
    aws.management = aws.management
    aws.network    = aws.network
  }
}
