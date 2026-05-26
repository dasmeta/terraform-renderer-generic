terraform {
  required_version = "~> 1.3"

  required_providers {
    deepmerge = {
      source  = "isometry/deepmerge"
      version = "~> 1.2"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}
