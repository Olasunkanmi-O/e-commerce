# create aws provider
provider "aws" {
  region = "eu-west-2"  
}

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 6.0"
    }
    
  }
  backend "s3" {
    bucket       = "ecommerce-project-1232"
    use_lockfile = true
    key          = "infra-build/kops.tfstate"
    region       = "eu-west-2"
    encrypt      = true
  
  }
  required_version = ">=1.13.1"
}