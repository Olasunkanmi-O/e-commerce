# create aws provider
provider "aws" {
  region = "eu-west-2"  
}

terraform {
  backend "s3" {
    bucket       = "ecommerce-project-1232"
    use_lockfile = true
    key          = "infra-build/kops.tfstate"
    region       = "eu-west-2"
    encrypt      = true

  }
}