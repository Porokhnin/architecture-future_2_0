variable "provider_token" {
  description = "Токен"
  type        = string
}

variable "provider_cloud_id" {
  description = "ID облака"
  type        = string
  default     = "b1g4uhakpot917op49t4"
}

variable "provider_folder_id" {
  description = "ID папки"
  type        = string
  default     = "b1gpqj4rmksfv6qks5u4"
}

variable "bucket" {
  description = "Имя бакета"
  type        = string
  default     = "architecture-future-2.0"
}