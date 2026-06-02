data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2204-lts"
}

resource "yandex_compute_disk" "this" {
  name     = "vm-disk"
  type     = "network-ssd"
  zone     = "ru-central1-a"
  size     = var.boot_disk_size
  image_id = data.yandex_compute_image.ubuntu.image_id
}

resource "yandex_compute_instance" "this" {
  name        = "vm-instance"
  zone        = "ru-central1-a"
  platform_id = "standard-v3"

  resources {
    cores  = var.cores
    memory = var.memory
  }

  boot_disk {
    disk_id = yandex_compute_disk.this.id
  }

  network_interface {
    subnet_id = var.subnet_id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_key}"
  }
}
