provider "proxmox" {
  pm_parallel     = var.proxmox_num_processes
  pm_tls_insecure = var.proxmox_allow_insecure
  pm_timeout      = var.proxmox_api_timeout

  pm_api_url  = "https://${var.proxmox_hostname}:${var.proxmox_port}/api2/json"
  pm_user     = var.proxmox_user
  pm_password = var.proxmox_password
}









