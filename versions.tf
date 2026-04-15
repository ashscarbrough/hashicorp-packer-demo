terraform {
  required_version = ">= 1.9"

  required_providers {
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0"
    }
  }

  cloud {
    organization = "your-org-name"
    workspaces {
      name = "hcp-packer-build"
    }
  }
}