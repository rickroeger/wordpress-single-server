terraform {
  required_version = "1.14.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.99.1"
    }
  }
}

provider "aws" {
  profile                  = var.profile
  shared_credentials_files = ["~/.aws/credentials"]
  region                   = var.region
  default_tags {
    tags = {
      Terraform   = "true"
      Environment = var.environment
      APP         = var.app
    }
  }
}
