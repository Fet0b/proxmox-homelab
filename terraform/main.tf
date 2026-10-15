terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.84"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}

# Autenticação via variável de ambiente PROXMOX_VE_API_TOKEN
provider "proxmox" {
  endpoint = var.pve_endpoint
  insecure = true # somente laboratório: certificado autoassinado do PVE
}

resource "random_password" "root" {
  length  = 20
  special = false
}

resource "proxmox_virtual_environment_container" "ubuntu" {
  node_name     = var.node
  vm_id         = var.vmid
  unprivileged  = true
  started       = true
  start_on_boot = true

  features {
    nesting = true
  }

  operating_system {
    template_file_id = "local:vztmpl/ubuntu-24.04-standard_24.04-2_amd64.tar.zst"
    type             = "ubuntu"
  }

  cpu {
    cores = var.cores
  }

  memory {
    dedicated = var.memory
    swap      = 512
  }

  disk {
    datastore_id = "local-lvm"
    size         = var.disk_size
  }

  network_interface {
    name   = "eth0"
    bridge = "vmbr0"
  }

  initialization {
    hostname = var.hostname

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_account {
      password = random_password.root.result
      keys     = fileexists(pathexpand("~/.ssh/id_rsa.pub")) ? [trimspace(file(pathexpand("~/.ssh/id_rsa.pub")))] : []
    }
  }
}
