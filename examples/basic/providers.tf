
provider "aws" {
  alias   = "management"
  region  = var.region
  profile = "appvia-io-master"
}

provider "aws" {
  alias   = "network"
  region  = var.region
  profile = "appvia-io-network"
}

provider "aws" {
  alias   = "audit"
  region  = var.region
  profile = "appvia-io-audit"
}
