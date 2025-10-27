terraform {
  backend "s3" {
    bucket = "terraform-state"
    key    = "terraform_harbor.tfstate"
    endpoints = {
      s3 = "https://example.com"
    }

    access_key = "" # Specify user here
    secret_key = "" # Specify pass here

    # Skip AWS related checks and validations
    region                      = "ru-central-1"
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    use_path_style              = true
  }
  required_providers {
    harbor = {
      source  = "goharbor/harbor"
      version = "~> 3.11.2"
    }
  }
}

provider "harbor" {
  url      = var.harbor_url
  username = var.harbor_user
  password = var.harbor_pass

  insecure = false
}
