terraform {
  backend "s3" {
    bucket = "terraform-state"
    key    = "terraform_vault.tfstate"
    endpoints = {
      s3 = "https://example.com"
    }

    # Skip AWS related checks and validations
    region                      = "ru-central-1"
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    use_path_style              = true
  }
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 5.3.0"
    }
  }
}

provider "vault" {
  address = var.vault_url

  auth_login_token_file {
    filename = ".vault_token"
  }

  skip_tls_verify = var.vault_disable_tls
}
