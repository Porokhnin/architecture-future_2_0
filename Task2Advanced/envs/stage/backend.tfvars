endpoints = {
  s3 = "https://storage.yandexcloud.net"
}
bucket                      = "architecture-future-2.0"
region                      = "ru-central1"
key                         = "envs/stage/terraform.tfstate"

# Флаги совместимости с Yandex Object Storage
skip_region_validation      = true
skip_credentials_validation = true
skip_requesting_account_id  = true
use_path_style              = true