terraform {
  cloud {
    organization = "Satish_Terraform"

    workspaces {
      name = "Terraform_Final_updated"
    }
  }
}

provider "aws" {
  region = var.region
}