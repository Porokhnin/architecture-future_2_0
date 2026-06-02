terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }

  # Динамический S3-бэкенд без захардкоженных параметров окружений
  backend "s3" {}  
}

provider "yandex" {}


# Объявляем переменные верхнего уровня (те же, что в модуле)
variable "cores" { type = number }
variable "memory" { type = number }
variable "boot_disk_size" { type = number }
variable "subnet_id" { type = string }
variable "ssh_key" { type = string }

# Вызываем наш универсальный модуль
module "vm_module" {
  source = "../../modules/vm"

  cores     = var.cores
  memory    = var.memory
  subnet_id = var.subnet_id
  ssh_key   = var.ssh_key
  boot_disk_size = var.boot_disk_size
}

# Выводим данные наружу из модуля
output "env_vm_id" {
  value       = module.vm_module.instance_id
  description = "ID созданной виртуальной машины в окружении"
}

output "env_vm_external_ip" {
  value       = module.vm_module.external_ip
  description = "Публичный IP-адрес ВМ в окружении"
}

output "env_disk_id" {
  value       = module.vm_module.disk_id
  description = "ID подключаемого диска в окружении"
}