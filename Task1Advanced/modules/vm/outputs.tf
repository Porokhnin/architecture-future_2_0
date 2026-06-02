output "instance_id" {
  value       = yandex_compute_instance.this.id
  description = "ID ВМ"
}

output "external_ip" {
  value       = yandex_compute_instance.this.network_interface[0].nat_ip_address
  description = "Публичный IP-адрес ВМ"
}

output "disk_id" {
  value       = yandex_compute_disk.this.id
  description = "ID подключаемого диска"
}