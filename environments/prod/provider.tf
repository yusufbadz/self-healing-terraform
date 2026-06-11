provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Project   = "self-healing-terraform"
      ManagedBy = "Terraform"
    }
  }
}