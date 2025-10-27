terraform {
  backend "s3" {
    bucket = "terraform-state"
    key    = "terraform.tfstate"
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
    minio = {
      source  = "aminueza/minio"
      version = "~> 3.6.5"
    }
  }
}

provider "minio" {
  minio_server   = "example.com"
  minio_user     = var.minio_user
  minio_password = var.minio_pass

  minio_ssl      = var.minio_ssl
  minio_insecure = !var.minio_ssl
}
