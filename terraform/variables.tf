variable "node" {
  default = "pve"
}

variable "vmid" {
  default = 103
}

variable "hostname" {
  default = "ubuntu-tf"
}

variable "cores" {
  default = 2
}

variable "memory" {
  default = 1024
}

variable "disk_size" {
  default = 8
}

variable "pve_endpoint" {
  description = "URL da API do Proxmox, ex.: https://PVE_IP:8006/"
  type        = string
}
