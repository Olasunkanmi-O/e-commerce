# create aws provider
provider "aws" {
  region = "eu-west-2"
  #profile = "pet-adoption"
}

terraform {
  backend "s3" {
    bucket       = "ecommerce-project-1232"
    use_lockfile = true
    key          = "jenkins/terraform.tfstate"
    region       = "eu-west-2"
    encrypt      = true
    #profile = "pet-adoption"
    
  }
}