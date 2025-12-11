terraform {
  required_providers {
    nullplatform = {
      source  = "nullplatform/nullplatform"
      version = "0.0.74"
    }
  }
}

provider "nullplatform" {
  api_key = var.account_level_np_api_key
}
