terraform {
  required_version = ">= 1.9"

  required_providers {
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0"
    }
  }

  cloud {
    organization = "hashicorp-wwtfo-demo-platform-prod"
    workspaces {
      name = "hashicorp-packer-demo"
    }
  }
}