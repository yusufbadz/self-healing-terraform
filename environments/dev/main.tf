locals {
  common_tags = {
    Project     = "self-healing-terraform"
    Environment = var.environment
    Owner       = var.owner
    ManagedBy   = "Terraform"
    CostCenter  = "CS-PROJECT-2024"
    Repository  = "github.com/yusufbadz/self-healing-terraform"
  }
}