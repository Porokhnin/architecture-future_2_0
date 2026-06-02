variable "cores" {
  type        = number
  description = "Количество ядер"
  default     = 2
}

variable "memory" {
  type        = number
  description = "Объём RAM (в ГБ)"
  default     = 2
}

variable "boot_disk_size" {
  type        = number
  description = "Размер подключаемого диска (в ГБ)"
  default     = 4
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID"
}

variable "ssh_key" {
  type        = string
  description = "SSH-ключ (содержимое pub-файла)"
}
