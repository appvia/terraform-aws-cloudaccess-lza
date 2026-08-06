
provider "aws" {
  alias   = "management"
  region  = var.region
  profile = "appvia-io-master"
}

provider "aws" {
  alias   = "audit"
  region  = var.region
  profile = "appvia-io-audit"
}
