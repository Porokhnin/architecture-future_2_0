terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"

  backend "s3" {
    endpoints = {
      s3 = "https://storage.yandexcloud.net"
    }
    region = "ru-central1"
    bucket = "loa"
    key    = "terraform.tfstate"

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
    skip_s3_api_negotiation     = true
  }
}

provider "yandex" {
  token = var.provider_token
  cloud_id = var.provider_cloud_id
  folder_id = var.provider_folder_id
  zone = "ru-central1-a"
}